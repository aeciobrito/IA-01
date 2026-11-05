-- ============================================================================
-- PROJETO ARMAZÉM TITO (ESTOQUE E VENDAS) - IMPLEMENTAÇÃO SQL SERVER / T-SQL
-- Compatível com SQL Server LocalDB, Express e SSMS
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'ControleEstoqueDB')
BEGIN
    CREATE DATABASE ControleEstoqueDB;
END
GO

USE ControleEstoqueDB;
GO

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Limpeza preventiva de tabelas dependentes
IF OBJECT_ID('dbo.ContasReceber', 'U') IS NOT NULL DROP TABLE dbo.ContasReceber;
IF OBJECT_ID('dbo.ItensPedido', 'U') IS NOT NULL DROP TABLE dbo.ItensPedido;
IF OBJECT_ID('dbo.Pedidos', 'U') IS NOT NULL DROP TABLE dbo.Pedidos;
IF OBJECT_ID('dbo.FormasPagamento', 'U') IS NOT NULL DROP TABLE dbo.FormasPagamento;
IF OBJECT_ID('dbo.Produtos', 'U') IS NOT NULL DROP TABLE dbo.Produtos;
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID('dbo.Fornecedores', 'U') IS NOT NULL DROP TABLE dbo.Fornecedores;

-- Tabela de Fornecedores
CREATE TABLE dbo.Fornecedores (
    id INT IDENTITY(1,1) NOT NULL,
    nome_fantasia VARCHAR(100) NOT NULL,
    cnpj VARCHAR(14) NOT NULL,
    CONSTRAINT PK_Fornecedores PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Fornecedores_CNPJ UNIQUE (cnpj)
);
GO

-- Tabela de Usuários (TPH - Herança com Discriminator)
CREATE TABLE dbo.Usuarios (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil INT NOT NULL, -- 0=Cliente, 1=Caixa, 2=Gerente, 3=System
    discriminator VARCHAR(50) NOT NULL,
    cpf VARCHAR(14) NULL,
    turno VARCHAR(50) NULL,
    setor VARCHAR(50) NULL,
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (email),
    CONSTRAINT CK_Usuarios_Discriminator CHECK (discriminator IN ('Cliente', 'Caixa', 'Gerente', 'System', 'UsuarioSistema'))
);
GO

-- Tabela de Produtos
CREATE TABLE dbo.Produtos (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    quantidade_estoque INT NOT NULL,
    fornecedor_id INT NOT NULL,
    CONSTRAINT PK_Produtos PRIMARY KEY CLUSTERED (id),
    CONSTRAINT CK_Produtos_Preco CHECK (preco >= 0),
    CONSTRAINT CK_Produtos_Quantidade CHECK (quantidade_estoque >= 0),
    CONSTRAINT FK_Produtos_Fornecedores 
        FOREIGN KEY (fornecedor_id) REFERENCES dbo.Fornecedores (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- Tabela de Formas de Pagamento
CREATE TABLE dbo.FormasPagamento (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    ativo BIT NOT NULL CONSTRAINT DF_FormasPagamento_Ativo DEFAULT 1,
    CONSTRAINT PK_FormasPagamento PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_FormasPagamento_Nome UNIQUE (nome)
);
GO

-- Tabela de Pedidos
CREATE TABLE dbo.Pedidos (
    id INT IDENTITY(1,1) NOT NULL,
    data_pedido DATETIME NOT NULL CONSTRAINT DF_Pedidos_Data DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL CONSTRAINT DF_Pedidos_Status DEFAULT 'Aberto',
    cliente_id INT NOT NULL,
    caixa_id INT NULL,
    forma_pagamento_id INT NOT NULL,
    CONSTRAINT PK_Pedidos PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_Pedidos_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Pedidos_Caixas 
        FOREIGN KEY (caixa_id) REFERENCES dbo.Usuarios (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT FK_Pedidos_FormasPagamento 
        FOREIGN KEY (forma_pagamento_id) REFERENCES dbo.FormasPagamento (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- Tabela de Itens do Pedido (Relacionamento N:N)
CREATE TABLE dbo.ItensPedido (
    id INT IDENTITY(1,1) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    CONSTRAINT PK_ItensPedido PRIMARY KEY CLUSTERED (id),
    CONSTRAINT CK_ItensPedido_Quantidade CHECK (quantidade > 0),
    CONSTRAINT CK_ItensPedido_PrecoUnitario CHECK (preco_unitario >= 0),
    CONSTRAINT FK_ItensPedido_Pedidos 
        FOREIGN KEY (pedido_id) REFERENCES dbo.Pedidos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_ItensPedido_Produtos 
        FOREIGN KEY (produto_id) REFERENCES dbo.Produtos (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- Tabela de Contas a Receber
CREATE TABLE dbo.ContasReceber (
    id INT IDENTITY(1,1) NOT NULL,
    descricao VARCHAR(100) NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_vencimento DATETIME NOT NULL,
    data_pagamento DATETIME NULL,
    status VARCHAR(20) NOT NULL CONSTRAINT DF_ContasReceber_Status DEFAULT 'Pendente',
    cliente_id INT NOT NULL,
    CONSTRAINT PK_ContasReceber PRIMARY KEY CLUSTERED (id),
    CONSTRAINT CK_ContasReceber_Valor CHECK (valor >= 0),
    CONSTRAINT FK_ContasReceber_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO
