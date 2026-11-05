-- ============================================================================
-- PROJETO PIZZARIA BELLA TITO - SEED DE DADOS (SQLITE)
-- Carga inicial com usuários (System, Gerente, Atendente, Clientes), cardápio,
-- formas de pagamento e pedidos com datetime('now')
-- Senha padrão para testes de todos os usuários: 'System@123'
-- Hash BCrypt ($2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga)
-- ============================================================================

PRAGMA foreign_keys = ON;

-- 1. Usuários (System, Gerente, Atendentes e Clientes)
INSERT INTO Usuarios (id, nome, email, senha_hash, perfil, discriminator, telefone, endereco, cpf, turno, setor) VALUES
-- System (Suporte e Implantação) - perfil=3
(1, 'Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, NULL, NULL, 'Implantação e Suporte'),

-- Gerente da Unidade - perfil=2
(2, 'Carlos Eduardo Gerente', 'carlos.gerente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, NULL, NULL, 'Operações e Atendimento'),

-- Atendentes de Caixa e Balcão - perfil=1
(3, 'Pedro Santos Atendente', 'pedro.atendente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Atendente', NULL, NULL, NULL, 'Noite', NULL),
(4, 'Ana Paula Atendente', 'ana.atendente@pizzariabellatito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Atendente', NULL, NULL, NULL, 'Tarde', NULL),

-- Clientes Autenticados (com dados para entrega e identificação) - perfil=0
(5, 'Marcos Vinicius', 'marcos.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11988887777', 'Rua Tito, 120 - Lapa, São Paulo - SP', '111.222.333-44', NULL, NULL),
(6, 'Juliana Paes', 'juliana.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11977776666', 'Rua Clélia, 450 - Água Branca, São Paulo - SP', '222.333.444-55', NULL, NULL),
(7, 'Roberto Carlos', 'roberto.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11966665555', 'Av. Pompéia, 890 - Pompéia, São Paulo - SP', '333.444.555-66', NULL, NULL),
(8, 'Camila Pitanga', 'camila.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '11955554444', 'Rua Aurélia, 230 - Vila Romana, São Paulo - SP', '444.555.666-77', NULL, NULL);

-- 2. Formas de Pagamento
INSERT INTO FormasPagamento (id, nome, ativo) VALUES
(1, 'Dinheiro', 1),
(2, 'Cartão de Débito', 1),
(3, 'Cartão de Crédito', 1),
(4, 'Pix', 1);

-- 3. Cardápio de Pizzas
INSERT INTO Pizzas (id, sabor, ingredientes, valor, disponivel) VALUES
(1, 'Mussarela', 'Molho de tomate artesanal, mussarela especial, rodelas de tomate e orégano', 48.00, 1),
(2, 'Calabresa', 'Molho de tomate, linguiça calabresa fatiada, cebola em rodelas e azeitonas pretas', 52.00, 1),
(3, 'Margherita', 'Molho de tomate, mussarela fresca, folhas de manjericão e azeite extra virgem', 56.00, 1),
(4, 'Quatro Queijos', 'Molho de tomate, mussarela, gorgonzola, provolone e requeijão cremoso', 64.00, 1),
(5, 'Frango com Catupiry', 'Molho de tomate, peito de frango desfiado temperado e requeijão cremoso', 58.00, 1),
(6, 'Portuguesa', 'Molho de tomate, presunto cozido, ovos, cebola, ervilha e mussarela', 60.00, 1);

-- 4. Pedidos (Distribuídos temporalmente: 3 meses atrás, mês passado, ontem e hoje)
INSERT INTO Pedidos (id, cliente_id, atendente_id, forma_pagamento_id, data_hora, status, valor_total, observacoes) VALUES
(1, 5, 3, 1, datetime('now', '-3 month'), 'Entregue', 104.00, 'Entregar na portaria'),
(2, 6, 4, 3, datetime('now', '-1 month'), 'Entregue', 64.00, 'Sem cebola'),
(3, 7, 3, 4, datetime('now', '-1 day'), 'Entregue', 114.00, 'Massa bem assada'),
(4, 8, NULL, 4, datetime('now'), 'Em preparo', 58.00, 'Pedido realizado pelo site');

-- 5. Itens do Pedido (Chave composta pedido_id, pizza_id com congelamento de preço)
INSERT INTO Pedido_Itens (pedido_id, pizza_id, quantidade, valor_unitario) VALUES
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
