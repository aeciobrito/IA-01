-- ============================================================================
-- PROJETO PIZZARIA BELLA TITO - SEED DE DADOS (SQL SERVER / T-SQL)
-- Carga inicial com usuários (System, Gerente, Atendente, Clientes), cardápio, 
-- formas de pagamento e pedidos com GETDATE()
-- Senha padrão para testes de todos os usuários: 'System@123'
-- Hash BCrypt ($2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga)
-- ============================================================================

USE PizzariaDB;
GO

SET NOCOUNT ON;

-- 1. Usuários (System, Gerente, Atendentes e Clientes)
INSERT INTO dbo.Usuarios (nome, email, senha_hash, perfil, discriminator, telefone, endereco, cpf, turno, setor) VALUES
-- System (Suporte e Implantação) - perfil=3
('Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, NULL, NULL, 'Implantação e Suporte'),

-- Gerente da Unidade - perfil=2
('Carlos Eduardo Gerente', 'carlos.gerente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, NULL, NULL, 'Operações e Atendimento'),

-- Atendentes de Caixa e Balcão - perfil=1
('Pedro Santos Atendente', 'pedro.atendente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Atendente', NULL, NULL, NULL, 'Noite', NULL),
('Ana Paula Atendente', 'ana.atendente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Atendente', NULL, NULL, NULL, 'Tarde', NULL),

-- Clientes Autenticados (com dados para entrega e identificação) - perfil=0
('Marcos Vinicius', 'marcos.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11988887777', 'Rua Tito, 120 - Lapa, São Paulo - SP', '111.222.333-44', NULL, NULL),
('Juliana Paes', 'juliana.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11977776666', 'Rua Clélia, 450 - Água Branca, São Paulo - SP', '222.333.444-55', NULL, NULL),
('Roberto Carlos', 'roberto.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11966665555', 'Av. Pompéia, 890 - Pompéia, São Paulo - SP', '333.444.555-66', NULL, NULL),
('Camila Pitanga', 'camila.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11955554444', 'Rua Aurélia, 230 - Vila Romana, São Paulo - SP', '444.555.666-77', NULL, NULL);
GO

-- 2. Formas de Pagamento
INSERT INTO dbo.FormasPagamento (nome, ativo) VALUES
('Dinheiro', 1),
('Cartão de Débito', 1),
('Cartão de Crédito', 1),
('Pix', 1);
GO

-- 3. Cardápio de Pizzas
INSERT INTO dbo.Pizzas (sabor, ingredientes, valor, disponivel) VALUES
('Mussarela', 'Molho de tomate artesanal, mussarela especial, rodelas de tomate e orégano', 48.00, 1),
('Calabresa', 'Molho de tomate, linguiça calabresa fatiada, cebola em rodelas e azeitonas pretas', 52.00, 1),
('Margherita', 'Molho de tomate, mussarela fresca, folhas de manjericão e azeite extra virgem', 56.00, 1),
('Quatro Queijos', 'Molho de tomate, mussarela, gorgonzola, provolone e requeijão cremoso', 64.00, 1),
('Frango com Catupiry', 'Molho de tomate, peito de frango desfiado temperado e requeijão cremoso', 58.00, 1),
('Portuguesa', 'Molho de tomate, presunto cozido, ovos, cebola, ervilha e mussarela', 60.00, 1);
GO

-- 4. Pedidos (Distribuídos temporalmente: 3 meses atrás, mês passado, ontem e hoje)
-- Clientes IDs: 5 (Marcos), 6 (Juliana), 7 (Roberto), 8 (Camila)
-- Atendentes IDs: 3 (Pedro), 4 (Ana)
INSERT INTO dbo.Pedidos (cliente_id, atendente_id, forma_pagamento_id, data_hora, status, valor_total, observacoes) VALUES
(5, 3, 1, DATEADD(MONTH, -3, GETDATE()), 'Entregue', 104.00, 'Entregar na portaria'),
(6, 4, 3, DATEADD(MONTH, -1, GETDATE()), 'Entregue', 64.00, 'Sem cebola'),
(7, 3, 4, DATEADD(DAY, -1, GETDATE()), 'Entregue', 114.00, 'Massa bem assada'),
(8, NULL, 4, GETDATE(), 'Em preparo', 58.00, 'Pedido realizado pelo site');
GO

-- 5. Itens do Pedido (Chave composta pedido_id, pizza_id com congelamento de preço)
INSERT INTO dbo.Pedido_Itens (pedido_id, pizza_id, quantidade, valor_unitario) VALUES
-- Pedido 1: Mussarela + Margherita
(1, 1, 1, 48.00),
(1, 3, 1, 56.00),

-- Pedido 2: Quatro Queijos
(2, 4, 1, 64.00),

-- Pedido 3: Calabresa + Portuguesa
(3, 2, 1, 52.00),
(3, 6, 1, 60.00),

-- Pedido 4: Frango com Catupiry
(4, 5, 1, 58.00);
GO

PRINT 'Seed de dados executado com sucesso para PizzariaDB.';
GO
