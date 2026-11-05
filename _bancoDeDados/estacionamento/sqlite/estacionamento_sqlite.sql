-- ============================================================================
-- PROJETO ESTACIONAMENTO SEMPRE RÁPIDO - IMPLEMENTAÇÃO SQLITE
-- Compatível com SQLite3 / VS Code / EF Core SQLite Provider
-- ============================================================================

PRAGMA foreign_keys = ON;

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Operador, 2=Gerente, 3=System
CREATE TABLE IF NOT EXISTS Usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    senha_hash TEXT NOT NULL,
    perfil INTEGER NOT NULL, -- 0=Cliente, 1=Operador, 2=Gerente, 3=System
    discriminator TEXT NOT NULL CHECK (discriminator IN ('Cliente', 'Operador', 'Gerente', 'System', 'UsuarioSistema')),
    cpf TEXT UNIQUE,
    telefone TEXT,
    turno TEXT,
    setor TEXT
);

-- Tabela de Vagas
CREATE TABLE IF NOT EXISTS Vagas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    localizacao TEXT NOT NULL UNIQUE, -- Ex: 'Setor A-01', 'Setor B-05'
    tipo TEXT NOT NULL DEFAULT 'Média' CHECK (tipo IN ('Pequena', 'Média', 'Grande'))
);

-- Tabela de Veículos
CREATE TABLE IF NOT EXISTS Veiculos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cliente_id INTEGER NOT NULL,
    placa TEXT NOT NULL UNIQUE,
    modelo TEXT NOT NULL,
    cor TEXT,
    CONSTRAINT fk_veiculos_clientes
        FOREIGN KEY (cliente_id) REFERENCES Usuarios (id)
        ON DELETE CASCADE
);

-- Tabela de Registros de Estacionamento (Uso das Vagas)
CREATE TABLE IF NOT EXISTS RegistrosEstacionamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    veiculo_id INTEGER NOT NULL,
    vaga_id INTEGER NOT NULL,
    operador_id INTEGER,
    data_hora_entrada TEXT NOT NULL, -- Formato ISO: 'YYYY-MM-DD HH:MM:SS'
    data_hora_saida TEXT,
    valor_total REAL,
    CONSTRAINT fk_registros_veiculos
        FOREIGN KEY (veiculo_id) REFERENCES Veiculos (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_registros_vagas
        FOREIGN KEY (vaga_id) REFERENCES Vagas (id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_registros_operadores
        FOREIGN KEY (operador_id) REFERENCES Usuarios (id)
        ON DELETE SET NULL
);
