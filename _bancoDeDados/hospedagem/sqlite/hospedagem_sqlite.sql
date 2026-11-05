-- ============================================================================
-- PROJETO HOSPEDAGEM (POUSADA CHALÉS DA SERRA) - IMPLEMENTAÇÃO SQLITE
-- Compatível com SQLite3 / VS Code / EF Core SQLite Provider
-- Padrão de Nomenclatura: PK id, FKs com _id, colunas em snake_case
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Recepcionista, 2=Gerente, 3=System
CREATE TABLE IF NOT EXISTS Usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil INTEGER NOT NULL, -- 0=Cliente, 1=Recepcionista, 2=Gerente, 3=System
    discriminator TEXT NOT NULL CHECK (discriminator IN ('Cliente', 'Recepcionista', 'Gerente', 'System', 'UsuarioSistema')),
    rg TEXT UNIQUE,
    endereco TEXT,
    bairro TEXT,
    cidade TEXT,
    estado TEXT CHECK (estado IS NULL OR LENGTH(estado) = 2),
    cep TEXT,
    data_nascimento TEXT,
    turno TEXT,
    setor TEXT
);

-- Tabela de Telefones do Cliente (1:N)
CREATE TABLE IF NOT EXISTS Telefones (
    cliente_id INTEGER NOT NULL,
    telefone TEXT NOT NULL,
    tipo TEXT NOT NULL DEFAULT 'Celular',
    PRIMARY KEY (cliente_id, telefone),
    CONSTRAINT fk_telefones_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE CASCADE
);

-- Tabela de Chalés
CREATE TABLE IF NOT EXISTS Chales (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    localizacao TEXT NOT NULL,
    capacidade INTEGER NOT NULL CHECK (capacidade > 0),
    valor_alta_estacao REAL NOT NULL CHECK (valor_alta_estacao > 0),
    valor_baixa_estacao REAL NOT NULL CHECK (valor_baixa_estacao > 0)
);

-- Tabela de Comodidades dos Chalés (Itens)
CREATE TABLE IF NOT EXISTS Itens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    descricao TEXT
);

-- Tabela Associativa Chale_Itens (N:N)
CREATE TABLE IF NOT EXISTS Chale_Itens (
    chale_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    PRIMARY KEY (chale_id, item_id),
    CONSTRAINT fk_chaleitens_chales
        FOREIGN KEY (chale_id) REFERENCES Chales (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_chaleitens_itens
        FOREIGN KEY (item_id) REFERENCES Itens (id)
        ON DELETE CASCADE
);

-- Tabela de Serviços Adicionais (Catálogo)
CREATE TABLE IF NOT EXISTS Servicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL UNIQUE,
    valor REAL NOT NULL CHECK (valor >= 0)
);

-- Tabela de Hospedagens (Contrato Central)
CREATE TABLE IF NOT EXISTS Hospedagens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    chale_id INTEGER NOT NULL,
    recepcionista_id INTEGER,
    estado TEXT NOT NULL DEFAULT 'Aberta',
    data_inicio TEXT NOT NULL,
    data_fim TEXT NOT NULL,
    qtd_pessoas INTEGER NOT NULL CHECK (qtd_pessoas > 0),
    desconto REAL NOT NULL DEFAULT 0.00 CHECK (desconto >= 0.00 AND desconto <= 100.00),
    valor_final REAL,
    CONSTRAINT fk_hospedagens_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_hospedagens_recepcionistas
        FOREIGN KEY (recepcionista_id) REFERENCES Usuarios (id)
        ON DELETE SET NULL,
    CONSTRAINT fk_hospedagens_chales
        FOREIGN KEY (chale_id) REFERENCES Chales (id)
        ON DELETE RESTRICT
);

-- Tabela de Serviços Consumidos na Hospedagem (N:N com Histórico)
CREATE TABLE IF NOT EXISTS Hospedagem_Servicos (
    hospedagem_id INTEGER NOT NULL,
    servico_id INTEGER NOT NULL,
    data_servico TEXT NOT NULL,
    valor_servico REAL NOT NULL CHECK (valor_servico >= 0),
    PRIMARY KEY (hospedagem_id, servico_id, data_servico),
    CONSTRAINT fk_hospserv_hospedagens
        FOREIGN KEY (hospedagem_id) REFERENCES Hospedagens (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_hospserv_servicos
        FOREIGN KEY (servico_id) REFERENCES Servicos (id)
        ON DELETE RESTRICT
);
