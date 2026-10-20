-- ============================================================================
-- PROJETO PIZZARIA BELLA TITO - IMPLEMENTAÇÃO SQLITE
-- Compatível com SQLite3 / VS Code / EF Core SQLite Provider
-- ============================================================================

-- Habilitar integridade de chave estrangeira no SQLite
PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Atendente, 2=Gerente, 3=System
CREATE TABLE IF NOT EXISTS Usuarios (
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

-- Tabela de Pizzas (Cardápio)
CREATE TABLE IF NOT EXISTS Pizzas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sabor TEXT NOT NULL UNIQUE,
    ingredientes TEXT,
    valor REAL NOT NULL CHECK (valor > 0),
    disponivel INTEGER NOT NULL DEFAULT 1 CHECK (disponivel IN (0, 1))
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

-- Tabela Associativa N:N (Itens do Pedido)
CREATE TABLE IF NOT EXISTS Pedido_Itens (
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
