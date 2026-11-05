-- ============================================================================
-- PROJETO ESTACIONAMENTO SEMPRE RÁPIDO - IMPLEMENTAÇÃO SQL SERVER / T-SQL
-- Compatível com SQL Server LocalDB, Express, Docker e SSMS
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'EstacionamentoDB')
BEGIN
    CREATE DATABASE EstacionamentoDB;
END
GO

USE EstacionamentoDB;
GO

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Limpeza preventiva de tabelas dependentes
IF OBJECT_ID('dbo.RegistrosEstacionamento', 'U') IS NOT NULL DROP TABLE dbo.RegistrosEstacionamento;
IF OBJECT_ID('dbo.Veiculos', 'U') IS NOT NULL DROP TABLE dbo.Veiculos;
IF OBJECT_ID('dbo.Vagas', 'U') IS NOT NULL DROP TABLE dbo.Vagas;
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Operador, 2=Gerente, 3=System
CREATE TABLE dbo.Usuarios (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil INT NOT NULL, -- 0=Cliente, 1=Operador, 2=Gerente, 3=System
    discriminator VARCHAR(50) NOT NULL,
    cpf VARCHAR(14) NULL,
    telefone VARCHAR(20) NULL,
    turno VARCHAR(50) NULL,
    setor VARCHAR(50) NULL,
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (email),
    CONSTRAINT CK_Usuarios_Discriminator CHECK (discriminator IN ('Cliente', 'Operador', 'Gerente', 'System', 'UsuarioSistema'))
);
GO

-- Índice único condicional para CPF de clientes quando informado
CREATE UNIQUE NONCLUSTERED INDEX UQ_Usuarios_CPF 
ON dbo.Usuarios (cpf) 
WHERE cpf IS NOT NULL;
GO

-- Tabela de Vagas
CREATE TABLE dbo.Vagas (
    id INT IDENTITY(1,1) NOT NULL,
    localizacao VARCHAR(50) NOT NULL,
    tipo VARCHAR(20) NOT NULL CONSTRAINT DF_Vagas_Tipo DEFAULT 'Média',
    CONSTRAINT PK_Vagas PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Vagas_Localizacao UNIQUE (localizacao),
    CONSTRAINT CK_Vagas_Tipo CHECK (tipo IN ('Pequena', 'Média', 'Grande'))
);
GO

-- Tabela de Veículos
CREATE TABLE dbo.Veiculos (
    id INT IDENTITY(1,1) NOT NULL,
    cliente_id INT NOT NULL,
    placa VARCHAR(10) NOT NULL,
    modelo VARCHAR(50) NULL,
    cor VARCHAR(30) NULL,
    CONSTRAINT PK_Veiculos PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Veiculos_Placa UNIQUE (placa),
    CONSTRAINT FK_Veiculo_Cliente 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

-- Tabela de Registros de Uso (Central)
CREATE TABLE dbo.RegistrosEstacionamento (
    id INT IDENTITY(1,1) NOT NULL,
    veiculo_id INT NOT NULL,
    vaga_id INT NOT NULL,
    operador_id INT NULL,
    data_hora_entrada DATETIME NOT NULL CONSTRAINT DF_Reg_Entrada DEFAULT GETDATE(),
    data_hora_saida DATETIME NULL,
    valor_total DECIMAL(10,2) NULL,
    CONSTRAINT PK_RegistrosEstacionamento PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_Registro_Veiculo 
        FOREIGN KEY (veiculo_id) REFERENCES dbo.Veiculos (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Registro_Vaga 
        FOREIGN KEY (vaga_id) REFERENCES dbo.Vagas (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Registro_Operador 
        FOREIGN KEY (operador_id) REFERENCES dbo.Usuarios (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
GO
