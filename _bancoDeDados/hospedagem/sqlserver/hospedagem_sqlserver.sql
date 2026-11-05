-- ============================================================================
-- PROJETO HOSPEDAGEM (POUSADA CHALÉS DA SERRA) - IMPLEMENTAÇÃO SQL SERVER / T-SQL
-- Compatível com SQL Server LocalDB, Express, Docker e SSMS
-- Padrão de Nomenclatura: PK id, FKs com _id, colunas em snake_case
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HospedagemDB')
BEGIN
    CREATE DATABASE HospedagemDB;
END
GO

USE HospedagemDB;
GO

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Limpeza preventiva de tabelas dependentes
IF OBJECT_ID('dbo.Hospedagem_Servicos', 'U') IS NOT NULL DROP TABLE dbo.Hospedagem_Servicos;
IF OBJECT_ID('dbo.Hospedagens', 'U') IS NOT NULL DROP TABLE dbo.Hospedagens;
IF OBJECT_ID('dbo.Chale_Itens', 'U') IS NOT NULL DROP TABLE dbo.Chale_Itens;
IF OBJECT_ID('dbo.Itens', 'U') IS NOT NULL DROP TABLE dbo.Itens;
IF OBJECT_ID('dbo.Servicos', 'U') IS NOT NULL DROP TABLE dbo.Servicos;
IF OBJECT_ID('dbo.Chales', 'U') IS NOT NULL DROP TABLE dbo.Chales;
IF OBJECT_ID('dbo.Telefones', 'U') IS NOT NULL DROP TABLE dbo.Telefones;
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Recepcionista, 2=Gerente, 3=System
CREATE TABLE dbo.Usuarios (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil INT NOT NULL, -- 0=Cliente, 1=Recepcionista, 2=Gerente, 3=System
    discriminator VARCHAR(50) NOT NULL,
    rg VARCHAR(20) NULL,
    endereco VARCHAR(150) NULL,
    bairro VARCHAR(60) NULL,
    cidade VARCHAR(60) NULL,
    estado CHAR(2) NULL,
    cep VARCHAR(10) NULL,
    data_nascimento DATE NULL,
    turno VARCHAR(50) NULL,
    setor VARCHAR(50) NULL,
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (email),
    CONSTRAINT CK_Usuarios_Discriminator CHECK (discriminator IN ('Cliente', 'Recepcionista', 'Gerente', 'System', 'UsuarioSistema'))
);
GO

-- Índice único condicional para RG de clientes quando informado
CREATE UNIQUE NONCLUSTERED INDEX UQ_Usuarios_RG 
ON dbo.Usuarios (rg) 
WHERE rg IS NOT NULL;
GO

-- Tabela de Telefones do Cliente (Entidade Fraca / 1:N)
CREATE TABLE dbo.Telefones (
    cliente_id INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL CONSTRAINT DF_Telefones_Tipo DEFAULT 'Celular',
    CONSTRAINT PK_Telefones PRIMARY KEY CLUSTERED (cliente_id, telefone),
    CONSTRAINT FK_Telefones_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

-- Tabela de Chalés
CREATE TABLE dbo.Chales (
    id INT IDENTITY(1,1) NOT NULL,
    localizacao VARCHAR(100) NOT NULL,
    capacidade INT NOT NULL CONSTRAINT CK_Chales_Capacidade CHECK (capacidade > 0),
    valor_alta_estacao DECIMAL(10,2) NOT NULL CONSTRAINT CK_Chales_ValorAlta CHECK (valor_alta_estacao > 0),
    valor_baixa_estacao DECIMAL(10,2) NOT NULL CONSTRAINT CK_Chales_ValorBaixa CHECK (valor_baixa_estacao > 0),
    CONSTRAINT PK_Chales PRIMARY KEY CLUSTERED (id)
);
GO

-- Tabela de Itens / Comodidades do Chalé
CREATE TABLE dbo.Itens (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    descricao VARCHAR(200) NULL,
    CONSTRAINT PK_Itens PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Itens_Nome UNIQUE (nome)
);
GO

-- Tabela Associativa N:N (Chale_Itens)
CREATE TABLE dbo.Chale_Itens (
    chale_id INT NOT NULL,
    item_id INT NOT NULL,
    CONSTRAINT PK_Chale_Itens PRIMARY KEY CLUSTERED (chale_id, item_id),
    CONSTRAINT FK_ChaleItens_Chales 
        FOREIGN KEY (chale_id) REFERENCES dbo.Chales (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_ChaleItens_Itens 
        FOREIGN KEY (item_id) REFERENCES dbo.Itens (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

-- Tabela de Serviços Adicionais
CREATE TABLE dbo.Servicos (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(60) NOT NULL,
    valor DECIMAL(10,2) NOT NULL CONSTRAINT CK_Servicos_Valor CHECK (valor >= 0),
    CONSTRAINT PK_Servicos PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Servicos_Nome UNIQUE (nome)
);
GO

-- Tabela de Hospedagens (Contrato Central)
CREATE TABLE dbo.Hospedagens (
    id INT IDENTITY(1,1) NOT NULL,
    cliente_id INT NOT NULL,
    chale_id INT NOT NULL,
    recepcionista_id INT NULL,
    estado VARCHAR(20) NOT NULL CONSTRAINT DF_Hospedagens_Estado DEFAULT 'Aberta',
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NOT NULL,
    qtd_pessoas INT NOT NULL CONSTRAINT CK_Hospedagens_QtdPessoas CHECK (qtd_pessoas > 0),
    desconto DECIMAL(5,2) NOT NULL CONSTRAINT DF_Hospedagens_Desconto DEFAULT 0.00,
    valor_final DECIMAL(10,2) NULL,
    CONSTRAINT PK_Hospedagens PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_Hospedagens_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Hospedagens_Recepcionistas 
        FOREIGN KEY (recepcionista_id) REFERENCES dbo.Usuarios (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT FK_Hospedagens_Chales 
        FOREIGN KEY (chale_id) REFERENCES dbo.Chales (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT CK_Hospedagens_Datas CHECK (data_fim >= data_inicio),
    CONSTRAINT CK_Hospedagens_Desconto CHECK (desconto >= 0.00 AND desconto <= 100.00)
);
GO

-- Tabela de Serviços Consumidos na Hospedagem (N:N com Histórico de Data e Preço)
CREATE TABLE dbo.Hospedagem_Servicos (
    hospedagem_id INT NOT NULL,
    servico_id INT NOT NULL,
    data_servico DATETIME NOT NULL,
    valor_servico DECIMAL(10,2) NOT NULL CONSTRAINT CK_HospServ_Valor CHECK (valor_servico >= 0),
    CONSTRAINT PK_Hospedagem_Servicos PRIMARY KEY CLUSTERED (hospedagem_id, servico_id, data_servico),
    CONSTRAINT FK_HospServ_Hospedagens 
        FOREIGN KEY (hospedagem_id) REFERENCES dbo.Hospedagens (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_HospServ_Servicos 
        FOREIGN KEY (servico_id) REFERENCES dbo.Servicos (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO
