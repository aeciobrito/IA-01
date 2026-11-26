"""
Solução Guia Corrigida - Revisão Pós-Aula 005 (Text-to-SQL na Pizzaria Bella Tito)
Melhorias aplicadas sobre solucao.py:
1. Caminho portável (/) para Windows e Linux/WSL2 + constantes centralizadas (OLLAMA_URL e MODELO)
2. Validação explícita do corpo JSON recebido (HTTP 400)
3. Função chamar_ollama() com try/except de rede/timeout (HTTP 503) e status HTTP (HTTP 502)
4. Few-Shot Prompting (conceito da Aula 003) em gerar_sql() + limpeza de blocos Markdown
5. Proteção para permitir apenas SELECT (HTTP 400) e tratamento de sqlite3.Error (HTTP 422)
6. Retorno estruturado em JSON (jsonify) facilitando depuração + rota GET /api/status
"""

import json
import sqlite3
import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_PATH = "_bancoDeDados/pizzaria/pizzaria.db"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:e4b"

SYSTEM_PROMPT = """Você é o TitoBot, assistente virtual inteligente e cordial da Pizzaria Bella Tito (localizada no Senac Lapa Tito).
Siga estritamente as informações oficiais abaixo:
- Endereço: Rua Tito, 54 - Lapa, São Paulo - SP.
- Horário de Atendimento: Terça a Domingo, das 18h às 23h30. Fechado às segundas-feiras.
- Entregas: Entregamos em um raio de 7km com taxa fixa de R$ 8,00.

Diretrizes de resposta:
1. Responda em português do Brasil com no máximo 3 frases claras e objetivas.
2. Nunca invente promoções ou dados que não estejam nos resultados reais retornados do banco de dados.
3. Se a lista de dados vier vazia, informe educadamente que não encontrou o item solicitado.
4. Se perguntarem algo fora do contexto da pizzaria, diga educadamente que só pode responder sobre a Bella Tito."""

SCHEMA = """
TABLE Usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil INTEGER NOT NULL, -- 0=Cliente, 1=Atendente, 2=Gerente, 3=System
    discriminator TEXT NOT NULL CHECK (discriminator IN ('Cliente', 'Atendente', 'Gerente', 'System', 'UsuarioSistema')),
    telefone TEXT UNIQUE,
    endereco TEXT,
    cpf TEXT UNIQUE,
    turno TEXT,
    setor TEXT
);

TABLE Pizzas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sabor TEXT NOT NULL UNIQUE,
    ingredientes TEXT,
    valor REAL NOT NULL CHECK (valor > 0),
    disponivel INTEGER NOT NULL DEFAULT 1 CHECK (disponivel IN (0, 1))
);

TABLE FormasPagamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

TABLE Pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    atendente_id INTEGER,
    forma_pagamento_id INTEGER NOT NULL,
    data_hora TEXT NOT NULL, -- Formato ISO8601: 'YYYY-MM-DD HH:MM:SS'
    status TEXT NOT NULL DEFAULT 'Em preparo',
    valor_total REAL DEFAULT 0.0,
    observacoes TEXT,
    CONSTRAINT fk_pedidos_clientes FOREIGN KEY (cliente_id) REFERENCES Usuarios (id) ON DELETE RESTRICT,
    CONSTRAINT fk_pedidos_atendentes FOREIGN KEY (atendente_id) REFERENCES Usuarios (id) ON DELETE SET NULL,
    CONSTRAINT fk_pedidos_formaspagamento FOREIGN KEY (forma_pagamento_id) REFERENCES FormasPagamento (id) ON DELETE RESTRICT
);

TABLE Pedido_Itens (
    pedido_id INTEGER NOT NULL,
    pizza_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    valor_unitario REAL NOT NULL CHECK (valor_unitario > 0),
    PRIMARY KEY (pedido_id, pizza_id),
    CONSTRAINT fk_itens_pedidos FOREIGN KEY (pedido_id) REFERENCES Pedidos (id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_pizzas FOREIGN KEY (pizza_id) REFERENCES Pizzas (id) ON DELETE RESTRICT
);
"""

# Exemplos Few-Shot (Aula 003) ensinando nomes exatos de colunas e padrão LIKE no SQLite
EXEMPLOS_FEW_SHOT = """Exemplos de como converter perguntas em SQL válido para este banco:

Pergunta: Quais pizzas estão disponíveis no cardápio?
SQL: SELECT sabor, ingredientes, valor FROM Pizzas WHERE disponivel = 1 ORDER BY sabor;

Pergunta: Quanto custa a pizza de Calabresa?
SQL: SELECT sabor, ingredientes, valor FROM Pizzas WHERE LOWER(sabor) LIKE '%calabresa%' AND disponivel = 1;

Pergunta: Qual é a pizza mais barata?
SQL: SELECT sabor, valor FROM Pizzas WHERE disponivel = 1 ORDER BY valor ASC LIMIT 1;

Pergunta: Quais formas de pagamento vocês aceitam?
SQL: SELECT nome FROM FormasPagamento WHERE ativo = 1 ORDER BY nome;
"""


def chamar_ollama(prompt: str, temperatura: float = 0.2):
    """Envia o prompt ao Ollama tratando falhas de rede, timeout e JSON inválido."""
    try:
        resp = requests.post(
            OLLAMA_URL,
            json={
                "model": MODELO,
                "prompt": prompt,
                "stream": False,
                "options": {"temperature": temperatura}
            },
            timeout=120
        )
    except requests.exceptions.Timeout:
        return None, {
            "etapa": "ollama",
            "erro": "Tempo limite (timeout) ao aguardar resposta do Ollama."
        }, 503
    except requests.exceptions.RequestException as e:
        return None, {
            "etapa": "ollama",
            "erro": f"Não foi possível conectar ao Ollama em {OLLAMA_URL}: {str(e)}"
        }, 503

    if resp.status_code != 200:
        return None, {
            "etapa": "ollama",
            "erro": f"O Ollama retornou HTTP {resp.status_code}. Verifique se o modelo '{MODELO}' está instalado.",
            "detalhes": resp.text
        }, 502

    try:
        texto = (resp.json().get("response") or "").strip()
    except ValueError:
        return None, {
            "etapa": "ollama",
            "erro": "A resposta do Ollama não veio em JSON válido."
        }, 502

    if not texto:
        return None, {
            "etapa": "ollama",
            "erro": "O Ollama retornou uma resposta vazia."
        }, 502

    return texto, None, 200


def gerar_sql(pergunta: str):
    """Gera uma consulta SQL SELECT usando Schema + Few-Shot Prompting."""
    instrucao = f"""Você é um tradutor de linguagem natural para SQL (SQLite).
Com base exclusivamente no esquema e nos exemplos abaixo, gere APENAS uma consulta SQL SELECT válida em uma única linha.
Não use blocos de código Markdown nem texto explicativo.

Esquema do Banco:
{SCHEMA}

{EXEMPLOS_FEW_SHOT}
Pergunta: {pergunta}
SQL:"""

    resposta, erro, status_http = chamar_ollama(instrucao, temperatura=0.1)
    if erro:
        return None, erro, status_http

    sql_limpo = resposta.replace("```sql", "").replace("```", "").strip()
    return sql_limpo, None, 200


def executar_consulta(sql: str):
    """Executa uma consulta SELECT no SQLite oficial da pizzaria."""
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(sql)
        return [dict(r) for r in cur.fetchall()]


@app.route("/api/status", methods=["GET"])
def status():
    return jsonify({
        "status": "ok",
        "app": "Pizzaria Bella Tito - Text-to-SQL API",
        "banco": DB_PATH,
        "modelo": MODELO
    }), 200


@app.route("/api/chat", methods=["POST"])
def rota_ollama():
    # 1. Validação dos dados enviados pelo cliente
    dados = request.get_json(silent=True) or {}
    pergunta = str(dados.get("pergunta", "")).strip()

    if not pergunta:
        return jsonify({
            "etapa": "validacao_entrada",
            "erro": "Envie um JSON válido com o campo 'pergunta' preenchido."
        }), 400

    # 2. Geração da query SQL pelo modelo usando Few-Shot
    sql_gerado, erro_sql_llm, status_http = gerar_sql(pergunta)
    if erro_sql_llm:
        return jsonify(erro_sql_llm), status_http

    # 3. Trava de segurança: apenas comandos de leitura (SELECT)
    if not sql_gerado.upper().startswith("SELECT"):
        return jsonify({
            "etapa": "validacao_sql",
            "erro": "Por segurança, apenas consultas SELECT são permitidas.",
            "sql_gerado": sql_gerado
        }), 400

    # 4. Execução no SQLite capturando erros de sintaxe, tabela ou coluna inexistente
    try:
        dados_banco = executar_consulta(sql_gerado)
    except sqlite3.Error as e:
        return jsonify({
            "etapa": "execucao_sqlite",
            "erro": "A query SQL gerada pelo modelo falhou ao ser executada no SQLite.",
            "sql_gerado": sql_gerado,
            "detalhes_sqlite": str(e)
        }), 422

    # 5. Formulação da resposta amigável com a persona do TitoBot
    dados_json = json.dumps(dados_banco, ensure_ascii=False)
    prompt_completo = (
        f"{SYSTEM_PROMPT}\n\n"
        f"Pergunta do cliente: {pergunta}\n"
        f"Dados reais retornados do banco: {dados_json}\n"
        f"Resposta:"
    )

    resposta_final, erro_resp_llm, status_http = chamar_ollama(prompt_completo, temperatura=0.2)
    if erro_resp_llm:
        erro_resp_llm["sql_executado"] = sql_gerado
        erro_resp_llm["dados_banco"] = dados_banco
        return jsonify(erro_resp_llm), status_http

    return jsonify({
        "pergunta": pergunta,
        "sql_executado": sql_gerado,
        "total_registros": len(dados_banco),
        "dados_banco": dados_banco,
        "resposta": resposta_final
    }), 200


if __name__ == "__main__":
    print(f"Iniciando API Pizzaria Bella Tito em http://localhost:5000 (Modelo: {MODELO})")
    app.run(host="0.0.0.0", port=5000, debug=True)