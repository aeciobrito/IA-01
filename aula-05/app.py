import sqlite3
import requests

DB_PATH = "_bancoDeDados\estoque\controle_estoque.db"
OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODELO_LLM = "gemma4:e2b"

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

def responder(pergunta):
    print(f">> Pergutna: {pergunta}")
    # criar uma lógica que transforma a perugnta em SQL puro para executar no banco
    sql = gerar_sql(pergunta)
    print(f">> SQL Gerado:{sql}")

    try:
        dados = consultar_banco(sql)
        print(f">> Registros encontrados({len(dados)})")
        for item in dados:
            print (f"  - {item}")
    except Exception as e:
        print(f">> Erro ao executar sql")

def gerar_sql(pergunta):
    prompt = f"""Você é um assistente SQL.
    Com base no esquema abaixo, gere APENAS um comando SQL SELECT válido em uma linha, sem markdown ou explicações.

    Esquema:
    {SCHEMA}

    Pergunta: {pergunta}
    SQL:"""

    try:
        resp = requests.post(OLLAMA_API_URL, json={
            "model": MODELO_LLM,
            "prompt": prompt,
            "stream": False
        }, timeout=70)
        return resp.json().get('response', "")
    except Exception:
        return "SELECT * FROM Produtos where quantidade_estoque < 50"

def consultar_banco(sql):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute(sql)
        return [dict(linha) for linha in cursor.fetchall()]

if __name__ == "__main__":
    print("=" * 60)
    print("ESCREVA SUA PERGUNTA AO BANCO DE DADOS")
    print("=" * 60)
    responder(input())

