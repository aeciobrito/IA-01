-- ============================================================================
-- PROJETO HOSPEDAGEM (POUSADA CHALÉS DA SERRA) - SEED DE DADOS (SQL SERVER)
-- População inicial com usuários (System, Gerente, Recepcionistas, Hóspedes),
-- chalés, comodidades, serviços e hospedagens com datas relativas via GETDATE()
-- Senha padrão para testes de todos os usuários: 'System@123'
-- Hash BCrypt ($2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga)
-- ============================================================================

USE HospedagemDB;
GO

SET NOCOUNT ON;

-- 1. Usuários (System, Gerente, Recepcionistas e Hóspedes/Clientes)
INSERT INTO dbo.Usuarios (nome, email, senha_hash, perfil, discriminator, rg, endereco, bairro, cidade, estado, cep, data_nascimento, turno, setor) VALUES
-- System (Suporte e Implantação) - perfil=3
('Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Implantação e Suporte'),

-- Gerente de Hotelaria e Governança - perfil=2
('Helena Vasconcelos Gerente', 'helena.gerente@pousadachales.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Hotelaria e Governança'),

-- Recepcionistas Operacionais (Check-in, Check-out e Lançamentos) - perfil=1
('Lucas Mendes Recepcionista', 'lucas.recepcao@pousadachales.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Recepcionista', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Manhã', NULL),
('Beatriz Lima Recepcionista', 'beatriz.recepcao@pousadachales.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Recepcionista', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Noite', NULL),

-- Hóspedes / Clientes - perfil=0
('Carlos Eduardo Silveira', 'carlos.silveira@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '12.345.678-9', 'Rua das Flores, 120', 'Jardins', 'São Paulo', 'SP', '01415-000', '1982-04-15', NULL, NULL),
('Mariana Souza Mendes', 'mariana.mendes@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '23.456.789-0', 'Av. Afonso Pena, 850', 'Centro', 'Belo Horizonte', 'MG', '30130-002', '1990-08-22', NULL, NULL),
('Roberto de Albuquerque', 'roberto.albuquerque@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '34.567.890-1', 'Rua Visconde de Pirajá, 300', 'Ipanema', 'Rio de Janeiro', 'RJ', '22410-002', '1975-11-03', NULL, NULL),
('Fernanda Lima Castro', 'fernanda.castro@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '45.678.901-2', 'Rua Marechal Deodoro, 45', 'Batel', 'Curitiba', 'PR', '80420-000', '1988-01-30', NULL, NULL),
('Luciano Prado Martins', 'luciano.martins@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '56.789.012-3', 'Av. Boa Viagem, 2100', 'Boa Viagem', 'Recife', 'PE', '51020-000', '1985-06-18', NULL, NULL),
('Juliana Paes Moreira', 'juliana.moreira@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '67.890.123-4', 'Rua Padre Chagas, 180', 'Moinhos de Vento', 'Porto Alegre', 'RS', '90570-080', '1993-12-12', NULL, NULL),
('Thiago Henrique Rocha', 'thiago.rocha@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '78.901.234-5', 'Rua Bahia, 560', 'Gonzaga', 'Santos', 'SP', '11060-450', '1995-03-25', NULL, NULL);
GO

-- 2. Telefones dos Clientes (IDs 5 a 11)
INSERT INTO dbo.Telefones (cliente_id, telefone, tipo) VALUES
(5, '(11) 98765-4321', 'Celular'),
(5, '(11) 3214-5500', 'Residencial'),
(6, '(31) 99123-4567', 'Celular'),
(7, '(21) 97654-3210', 'Celular'),
(7, '(21) 2512-8899', 'Comercial'),
(8, '(41) 98456-7890', 'Celular'),
(9, '(81) 99345-6789', 'Celular'),
(10, '(51) 98111-2233', 'Celular'),
(11, '(13) 99777-8899', 'Celular');
GO

-- 3. Chalés
INSERT INTO dbo.Chales (localizacao, capacidade, valor_alta_estacao, valor_baixa_estacao) VALUES
('Setor Bosque - Chalé 01 (Hortênsias)', 2, 450.00, 320.00),
('Setor Bosque - Chalé 02 (Pinheiros)', 4, 680.00, 480.00),
('Setor Montanha - Chalé 03 (Vista Panorâmica)', 2, 580.00, 410.00),
('Setor Vale - Chalé 04 (Vale Verde)', 6, 920.00, 650.00),
('Setor Lago - Chalé 05 (Pôr do Sol Master)', 4, 850.00, 590.00),
('Setor Montanha - Chalé 06 (Pedra Branca VIP)', 2, 750.00, 530.00);
GO

-- 4. Itens / Comodidades
INSERT INTO dbo.Itens (nome, descricao) VALUES
('Lareira Ecológica', 'Lareira a lenha/álcool para aquecimento na sala principal'),
('Banheira de Hidromassagem', 'Banheira dupla de hidromassagem com vista externa'),
('Ar-Condicionado Quente/Frio', 'Sistema split inverter silencioso com controle de temperatura'),
('Wi-Fi Fibra 500Mbps', 'Conexão de alta velocidade ideal para home office na serra'),
('Cafeteira Nespresso', 'Máquina de café em cápsulas com seleção de boas-vindas'),
('Cama King Size', 'Colchão ortopédico com enxoval em algodão egípcio 400 fios'),
('Varanda Panorâmica com Rede', 'Deck privativo de madeira voltado para a mata nativa'),
('Frigobar Completo', 'Frigobar abastecido com bebidas e petiscos regionais');
GO

-- 5. Chalé x Itens (Comodidades de cada chalé)
INSERT INTO dbo.Chale_Itens (chale_id, item_id) VALUES
-- Chalé 01
(1, 1), (1, 3), (1, 4), (1, 6), (1, 8),
-- Chalé 02
(2, 1), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8),
-- Chalé 03
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8),
-- Chalé 04
(4, 1), (4, 3), (4, 4), (4, 6), (4, 7), (4, 8),
-- Chalé 05
(5, 1), (5, 2), (5, 3), (5, 4), (5, 5), (5, 6), (5, 7), (5, 8),
-- Chalé 06
(6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (6, 6), (6, 7), (6, 8);
GO

-- 6. Serviços Adicionais
INSERT INTO dbo.Servicos (nome, valor) VALUES
('Café Colonial Especial no Chalé', 75.00),
('Cesta de Frutas e Vinho Fino da Serra', 180.00),
('Sessão de Massagem Relaxante (1h)', 160.00),
('Aluguel de Mountain Bike (Diária)', 50.00),
('Passeio a Cavalo com Guia (2h)', 120.00),
('Lenha Adicional para Lareira (Saco)', 35.00);
GO

-- 7. Hospedagens (Históricas, Vigentes e Futuras com datas relativas via GETDATE())
-- Hóspedes IDs: 5 a 11 | Recepcionistas IDs: 3 e 4
-- Hospedagem 1: Finalizada há 45 dias
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(5, 1, 3, 'Finalizada', DATEADD(DAY, -45, CAST(GETDATE() AS DATE)), DATEADD(DAY, -42, CAST(GETDATE() AS DATE)), 2, 0.00, 1035.00);

-- Hospedagem 2: Finalizada há 30 dias
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(6, 3, 4, 'Finalizada', DATEADD(DAY, -30, CAST(GETDATE() AS DATE)), DATEADD(DAY, -27, CAST(GETDATE() AS DATE)), 2, 5.00, 1856.25);

-- Hospedagem 3: Finalizada há 12 dias
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(7, 2, 3, 'Finalizada', DATEADD(DAY, -12, CAST(GETDATE() AS DATE)), DATEADD(DAY, -9, CAST(GETDATE() AS DATE)), 4, 10.00, 1944.00);

-- Hospedagem 4: Em andamento / Aberta (Iniciou ontem, termina em 3 dias)
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(8, 5, 4, 'Aberta', DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), DATEADD(DAY, 3, CAST(GETDATE() AS DATE)), 4, 0.00, NULL);

-- Hospedagem 5: Em andamento / Aberta (Iniciou hoje, termina em 2 dias)
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(9, 1, 3, 'Aberta', CAST(GETDATE() AS DATE), DATEADD(DAY, 2, CAST(GETDATE() AS DATE)), 2, 0.00, NULL);

-- Hospedagem 6: Futura confirmada (Inicia em 7 dias)
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(10, 6, 4, 'Aberta', DATEADD(DAY, 7, CAST(GETDATE() AS DATE)), DATEADD(DAY, 10, CAST(GETDATE() AS DATE)), 2, 0.00, NULL);

-- Hospedagem 7: Futura confirmada (Inicia em 20 dias)
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(11, 4, 3, 'Aberta', DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), DATEADD(DAY, 25, CAST(GETDATE() AS DATE)), 5, 5.00, NULL);

-- Hospedagem 8: Cancelada no passado
INSERT INTO dbo.Hospedagens (cliente_id, chale_id, recepcionista_id, estado, data_inicio, data_fim, qtd_pessoas, desconto, valor_final) VALUES
(5, 2, 4, 'Cancelada', DATEADD(DAY, -20, CAST(GETDATE() AS DATE)), DATEADD(DAY, -18, CAST(GETDATE() AS DATE)), 3, 0.00, 0.00);
GO

-- 8. Serviços Consumidos nas Hospedagens
INSERT INTO dbo.Hospedagem_Servicos (hospedagem_id, servico_id, data_servico, valor_servico) VALUES
-- Hospedagem 1 (Finalizada): Lenha + Café colonial
(1, 6, DATEADD(DAY, -44, CAST(GETDATE() AS DATE)), 35.00),
(1, 1, DATEADD(DAY, -43, CAST(GETDATE() AS DATE)), 75.00),

-- Hospedagem 2 (Finalizada): Cesta de frutas + Massagem
(2, 2, DATEADD(DAY, -30, CAST(GETDATE() AS DATE)), 180.00),
(2, 3, DATEADD(DAY, -29, CAST(GETDATE() AS DATE)), 160.00),

-- Hospedagem 3 (Finalizada): 2 Diárias bike + Lenha
(3, 4, DATEADD(DAY, -11, CAST(GETDATE() AS DATE)), 50.00),
(3, 4, DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), 50.00),
(3, 6, DATEADD(DAY, -11, CAST(GETDATE() AS DATE)), 35.00),

-- Hospedagem 4 (Aberta): Cesta de frutas na recepção
(4, 2, DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 180.00);
GO

PRINT 'Seed de dados executado com sucesso para HospedagemDB.';
GO
