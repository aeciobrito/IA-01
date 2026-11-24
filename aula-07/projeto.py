import sqlite3
import requests
from flask import Flask, request

app = Flask(__name__)

DB_PATH = "_bancoDeDados\pizzaria\pizzaria.db"
OLLAMA_URL = "http://localhost:11434/api/generate"

SYSTEM_PROMPT = """Você é o TitoBot, assistente virtual inteligente e cordial da Pizzaria Bella Tito (localizada no Senac Lapa Tito).
Siga estritamente as informações oficiais abaixo:
- Endereço: Rua Tito, 54 - Lapa, São Paulo - SP.
- Horário de Atendimento: Terça a Domingo, das 18h às 23h30. Fechado às segundas-feiras.
- Entregas: Entregamos em um raio de 7km com taxa fixa de R$ 8,00.

Diretrizes de resposta:
1. Responda em português do Brasil com no máximo 3 frases claras e objetivas.
2. Nunca invente promoções ou dados que não estão no banco de dados.
3. Se perguntarem algo fora do contexto da pizzaria, diga educadamente que só pode responder sobre a Bella Tito."""

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
    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedidos_atendentes
        FOREIGN KEY (atendente_id) REFERENCES Usuarios (id)
        ON DELETE SET NULL,
    CONSTRAINT fk_pedidos_formaspagamento
        FOREIGN KEY (forma_pagamento_id) REFERENCES FormasPagamento (id)
        ON DELETE RESTRICT
);

TABLE Pedido_Itens (
    pedido_id INTEGER NOT NULL,
    pizza_id INTEGER NOT NULL,
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    valor_unitario REAL NOT NULL CHECK (valor_unitario > 0),
    PRIMARY KEY (pedido_id, pizza_id),
    CONSTRAINT fk_itens_pedidos
        FOREIGN KEY (pedido_id) REFERENCES Pedidos (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_itens_pizzas
        FOREIGN KEY (pizza_id) REFERENCES Pizzas (id)
        ON DELETE RESTRICT
);
"""

@app.route("/api/chat", methods=['POST'])
def rota_ollama():
    dados = request.get_json()
    promptDoUsuario = dados.get("pergunta", "")

    sqlGerado = gerar_sql(promptDoUsuario)
    dadosDoBanco = executar_consulta(sqlGerado)

    prompt_completo = f"{SYSTEM_PROMPT}\n\n Pergunta do cliente: {promptDoUsuario} \n Dados: {dadosDoBanco}"

    respostaDoOllama = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "gemma4:e4b",
            "prompt": prompt_completo,
            "stream": False
        },
        timeout=120
        )

    respostaParaUsuario = respostaDoOllama.json().get("response")
    return f"O usuário enviou: {promptDoUsuario}, resposta do Ollama: {respostaParaUsuario}"

def gerar_sql(pergunta):
    instrucao = f"""Você é um tradutor de linguagem natural para SQL (SQLite).
    Com base exclusivamente no esquema abaixo, gere APENAS uma consulta SQL SELECT válida em uma única linha.
    Não use blocos de código Markdown nem texto explicativo."""
    
    prompt = f"{instrucao} \n {pergunta} \n {SCHEMA}"

    respostaDoOllama = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "gemma4:e4b",
            "prompt": prompt,
            "stream": False
        },
        timeout=120
        )
    
    respostaParaUsuario = respostaDoOllama.json().get("response")
    return respostaParaUsuario

def executar_consulta(sql: str):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(sql)
        return [dict(r) for r in cur.fetchall()]

if (__name__) == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)