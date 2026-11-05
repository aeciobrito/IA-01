-- ============================================================================
-- PROJETO PIZZARIA BELLA TITO - IMPLEMENTAÇÃO SQL SERVER / T-SQL
-- Compatível com SQL Server LocalDB, Express, Docker e SSMS
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'PizzariaDB')
BEGIN
    CREATE DATABASE PizzariaDB;
END
GO

USE PizzariaDB;
GO

-- ----------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (DDL)
-- ----------------------------------------------------------------------------

-- Limpeza preventiva de tabelas dependentes
IF OBJECT_ID('dbo.Pedido_Itens', 'U') IS NOT NULL DROP TABLE dbo.Pedido_Itens;
IF OBJECT_ID('dbo.Pedidos', 'U') IS NOT NULL DROP TABLE dbo.Pedidos;
IF OBJECT_ID('dbo.FormasPagamento', 'U') IS NOT NULL DROP TABLE dbo.FormasPagamento;
IF OBJECT_ID('dbo.Pizzas', 'U') IS NOT NULL DROP TABLE dbo.Pizzas;
IF OBJECT_ID('dbo.Usuarios', 'U') IS NOT NULL DROP TABLE dbo.Usuarios;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;

-- Tabela de Usuários (TPH - Herança com Discriminator)
-- Perfis: 0=Cliente, 1=Atendente, 2=Gerente, 3=System
CREATE TABLE dbo.Usuarios (
    id INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    perfil INT NOT NULL, -- 0=Cliente, 1=Atendente, 2=Gerente, 3=System
    discriminator VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NULL,
    endereco VARCHAR(255) NULL,
    cpf VARCHAR(14) NULL,
    turno VARCHAR(50) NULL,
    setor VARCHAR(50) NULL,
    CONSTRAINT PK_Usuarios PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (email),
    CONSTRAINT CK_Usuarios_Discriminator CHECK (discriminator IN ('Cliente', 'Atendente', 'Gerente', 'System', 'UsuarioSistema'))
);
GO

-- Índice único condicional para telefone de clientes quando informado
CREATE UNIQUE NONCLUSTERED INDEX UQ_Usuarios_Telefone 
ON dbo.Usuarios (telefone) 
WHERE telefone IS NOT NULL;
GO

-- Tabela de Pizzas (Cardápio)
CREATE TABLE dbo.Pizzas (
    id INT IDENTITY(1,1) NOT NULL,
    sabor VARCHAR(50) NOT NULL,
    ingredientes VARCHAR(MAX) NULL,
    valor DECIMAL(10, 2) NOT NULL,
    disponivel BIT NOT NULL CONSTRAINT DF_Pizzas_Disponivel DEFAULT 1,
    CONSTRAINT PK_Pizzas PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_Pizzas_Sabor UNIQUE (sabor),
    CONSTRAINT CK_Pizzas_Valor CHECK (valor > 0)
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
    cliente_id INT NOT NULL,
    atendente_id INT NULL,
    forma_pagamento_id INT NOT NULL,
    data_hora DATETIME NOT NULL CONSTRAINT DF_Pedidos_DataHora DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL CONSTRAINT DF_Pedidos_Status DEFAULT 'Em preparo',
    valor_total DECIMAL(10, 2) NOT NULL CONSTRAINT DF_Pedidos_ValorTotal DEFAULT 0.00,
    observacoes VARCHAR(255) NULL,
    CONSTRAINT PK_Pedidos PRIMARY KEY CLUSTERED (id),
    CONSTRAINT FK_Pedidos_Clientes 
        FOREIGN KEY (cliente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_Pedidos_Atendentes 
        FOREIGN KEY (atendente_id) REFERENCES dbo.Usuarios (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT FK_Pedidos_FormasPagamento 
        FOREIGN KEY (forma_pagamento_id) REFERENCES dbo.FormasPagamento (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

-- Tabela Associativa N:N (Itens do Pedido)
CREATE TABLE dbo.Pedido_Itens (
    pedido_id INT NOT NULL,
    pizza_id INT NOT NULL,
    quantidade INT NOT NULL CONSTRAINT DF_PedidoItens_Qtd DEFAULT 1,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_Pedido_Itens PRIMARY KEY CLUSTERED (pedido_id, pizza_id),
    CONSTRAINT FK_PedidoItens_Pedidos 
        FOREIGN KEY (pedido_id) REFERENCES dbo.Pedidos (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_PedidoItens_Pizzas 
        FOREIGN KEY (pizza_id) REFERENCES dbo.Pizzas (id)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT CK_PedidoItens_Quantidade CHECK (quantidade > 0),
    CONSTRAINT CK_PedidoItens_ValorUnitario CHECK (valor_unitario > 0)
);
GO
