#!/usr/bin/env python3
import os
import sqlite3
import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, "_bancoDeDados", "estoque", "controle_estoque.db")

OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:12b"

SCHEMA = """
-- Tabela de Fornecedores
CREATE TABLE IF NOT EXISTS Fornecedores (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_fantasia TEXT NOT NULL,
    cnpj TEXT NOT NULL UNIQUE
);

-- Tabela de Usuários (TPH - Herança com Discriminator)
CREATE TABLE IF NOT EXISTS Usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil INTEGER NOT NULL, -- 0=Cliente, 1=Caixa, 2=Gerente, 3=System
    discriminator TEXT NOT NULL CHECK (discriminator IN ('Cliente', 'Caixa', 'Gerente', 'System', 'UsuarioSistema')),
    cpf TEXT UNIQUE,
    turno TEXT,
    setor TEXT
);

-- Tabela de Produtos
CREATE TABLE IF NOT EXISTS Produtos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    preco REAL NOT NULL CHECK (preco >= 0),
    quantidade_estoque INTEGER NOT NULL CHECK (quantidade_estoque >= 0),
    fornecedor_id INTEGER NOT NULL,
    CONSTRAINT fk_produtos_fornecedores
        FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores (id)
        ON DELETE RESTRICT
);

-- Tabela de Formas de Pagamento
CREATE TABLE IF NOT EXISTS FormasPagamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    ativo INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

-- Tabela de Pedidos
CREATE TABLE IF NOT EXISTS Pedidos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    data_pedido TEXT NOT NULL, -- Formato ISO: 'YYYY-MM-DD HH:MM:SS'
    status TEXT NOT NULL DEFAULT 'Aberto',
    cliente_id INTEGER NOT NULL,
    caixa_id INTEGER,
    forma_pagamento_id INTEGER NOT NULL,
    CONSTRAINT fk_pedidos_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_pedidos_caixas
        FOREIGN KEY (caixa_id) REFERENCES Usuarios (id)
        ON DELETE SET NULL,
    CONSTRAINT fk_pedidos_formaspagamento
        FOREIGN KEY (forma_pagamento_id) REFERENCES FormasPagamento (id)
        ON DELETE RESTRICT
);

-- Tabela de Itens do Pedido (Relacionamento N:N)
CREATE TABLE IF NOT EXISTS ItensPedido (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario REAL NOT NULL CHECK (preco_unitario >= 0),
    pedido_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    CONSTRAINT fk_itens_pedidos
        FOREIGN KEY (pedido_id) REFERENCES Pedidos (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_itens_produtos
        FOREIGN KEY (produto_id) REFERENCES Produtos (id)
        ON DELETE RESTRICT
);

-- Tabela de Contas a Receber
CREATE TABLE IF NOT EXISTS ContasReceber (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL,
    valor REAL NOT NULL CHECK (valor >= 0),
    data_vencimento TEXT NOT NULL,
    data_pagamento TEXT,
    status TEXT NOT NULL DEFAULT 'Pendente',
    cliente_id INTEGER NOT NULL,
    CONSTRAINT fk_contas_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE RESTRICT
);
"""

def executar_consulta(sql: str):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(sql)
        return [dict(r) for r in cur.fetchall()]

@app.route("/api/status", methods=["GET"])
def get_status():
    return jsonify({
        "status": "ok",
        "app": "Controle de Estoque NL-to-SQL API",
        "versao": "1.0.0",
        "owner": "Aecio Brito"
    }), 200

@app.route("/api/consulta-nl", methods=["POST"])
def consultar_nl():
    dados = request.get_json()

    if not dados or "pergunta" not in dados:
        return jsonify({"erro": "Envie o campo 'pergunta' no corpo da requisição."}), 400

    pergunta = dados["pergunta"].strip()
    if not pergunta:
        return jsonify({"erro": "O campo 'pergunta' não pode ser vazio."}), 400

    prompt = f"""Você é um tradutor de linguagem natural para SQL (SQLite).
Com base exclusivamente no esquema abaixo, gere APENAS uma consulta SQL SELECT válida em uma única linha.
Não use blocos de código Markdown nem texto explicativo.

{SCHEMA}

Pergunta: {pergunta}
SQL:"""

    try:
        resp = requests.post(
            OLLAMA_URL,
            json={
                "model": MODELO,
                "prompt": prompt,
                "stream": False,
                "options": {"temperature": 0.1}
            },
            timeout=60
        )

        if resp.status_code != 200:
            return jsonify({"erro": "Falha na resposta do Ollama", "detalhes": resp.text}), 502

        sql_gerado = resp.json().get("response", "").strip()
        sql_gerado = sql_gerado.replace("```sql", "").replace("```", "").strip()

    except requests.exceptions.RequestException as e:
        return jsonify({"erro": f"Erro de conexão com o Ollama: {str(e)}"}), 503

    # Validação de segurança básica pedagógica (apenas SELECT permitido)
    if not sql_gerado.upper().startswith("SELECT"):
        return jsonify({
            "erro": "Apenas comandos de consulta (SELECT) são permitidos por segurança.",
            "sql_gerado": sql_gerado
        }), 400

    try:
        resultados = executar_consulta(sql_gerado)
        return jsonify({
            "pergunta": pergunta,
            "sql_executado": sql_gerado,
            "total_registros": len(resultados),
            "dados": resultados
        }), 200
    except sqlite3.Error as e:
        return jsonify({
            "erro": "Falha de sintaxe ao executar SQL gerado.",
            "sql_gerado": sql_gerado,
            "detalhes": str(e)
        }), 422

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)