-- ============================================================================
-- PROJETO ARMAZÉM TITO - SEED DE DADOS (SQLITE)
-- Carga inicial com datas relativas dinâmicas baseadas em datetime('now')
-- ============================================================================

PRAGMA foreign_keys = ON;

-- 1. Fornecedores
INSERT INTO Fornecedores (nome_fantasia, cnpj) VALUES
('Distribuidora Tito Alimentos Ltda', '12345678000199'),
('Bebidas & Cia Nacional', '98765432000188'),
('Laticínios da Serra', '11223344000155'),
('Moinho Paulista S.A.', '55667788000144');

-- 2. Usuários (System, Gerente, Caixa, Clientes)
INSERT INTO Usuarios (nome, email, senha_hash, perfil, discriminator, cpf, turno, setor) VALUES
('Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, 'Implantação e Suporte'),
('Carlos Gerente Comercial', 'carlos.gerente@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, 'Vendas e Estoque'),
('Pedro Oliveira Caixa', 'pedro.caixa@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Caixa', NULL, 'Manhã', NULL),
('Ana Costa Caixa', 'ana.caixa@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Caixa', NULL, 'Tarde', NULL),
('Mariana Silva Cliente', 'mariana@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '111.222.333-44', NULL, NULL),
('Carlos Eduardo Santos', 'carlos.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '555.666.777-88', NULL, NULL);

-- 3. Formas de Pagamento
INSERT INTO FormasPagamento (nome, ativo) VALUES
('Dinheiro', 1),
('Cartão de Débito', 1),
('Cartão de Crédito', 1),
('Pix', 1);

-- 4. Produtos
INSERT INTO Produtos (nome, preco, quantidade_estoque, fornecedor_id) VALUES
('Café Torrado Especial 500g', 18.50, 45, 1),
('Leite Integral 1L', 5.90, 80, 3),
('Arroz Tipo 1 Longo Fino 5kg', 28.00, 35, 1),
('Feijão Carioca 1kg', 8.90, 50, 1),
('Azeite de Oliva Extra Virgem 500ml', 38.00, 20, 1),
('Refrigerante Guaraná 2L', 9.50, 60, 2),
('Farinha de Trigo Especial 1kg', 4.80, 70, 4);

-- 5. Pedidos (Histórico: 1 ano atrás, 6 meses atrás, mês passado e hoje)
INSERT INTO Pedidos (data_pedido, status, cliente_id, caixa_id, forma_pagamento_id) VALUES
(datetime('now', '-1 year', '+2 month'), 'Fechado', 5, 3, 1),
(datetime('now', '-6 month', '+5 day'), 'Fechado', 5, 3, 2),
(datetime('now', '-1 month', '-10 day'), 'Fechado', 6, 4, 3),
(datetime('now', '-2 day'), 'Fechado', 6, 3, 4),
(datetime('now'), 'Aberto', 5, NULL, 4);

-- 6. Itens de Pedido
INSERT INTO ItensPedido (quantidade, preco_unitario, pedido_id, produto_id) VALUES
(2, 18.50, 1, 1),
(4, 5.90, 1, 2),
(1, 28.00, 2, 3),
(2, 8.90, 2, 4),
(1, 38.00, 3, 5),
(3, 9.50, 3, 6),
(2, 18.50, 4, 1),
(1, 9.50, 5, 6);

-- 7. Contas a Receber (Passadas quitadas, vencidas e futuras a vencer)
INSERT INTO ContasReceber (descricao, valor, data_vencimento, data_pagamento, status, cliente_id) VALUES
('Mensalidade Convênio Anterior', 150.00, datetime('now', '-30 day'), datetime('now', '-28 day'), 'Pago', 5),
('Fatura Comercial Vencida', 89.90, datetime('now', '-5 day'), NULL, 'Pendente', 5),
('Fornecimento Programado Quinzenal', 210.00, datetime('now', '+15 day'), NULL, 'Pendente', 6),
('Parcela 01/02 - Compra Faturada', 350.00, datetime('now', '+30 day'), NULL, 'Pendente', 6),
('Parcela 02/02 - Compra Faturada', 350.00, datetime('now', '+60 day'), NULL, 'Pendente', 6);
