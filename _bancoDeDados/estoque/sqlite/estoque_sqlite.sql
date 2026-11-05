-- ============================================================================
-- PROJETO ARMAZÉM TITO (ESTOQUE E VENDAS) - IMPLEMENTAÇÃO SQLITE
-- Compatível com SQLite3 / VS Code
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

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
