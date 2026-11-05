-- ============================================================================
-- PROJETO ESTACIONAMENTO SEMPRE RÁPIDO - SEED DE DADOS (SQL SERVER / T-SQL)
-- Carga inicial com usuários (System, Gerente, Operador, Clientes), veículos,
-- vagas e fluxo com GETDATE()
-- Senha padrão para testes de todos os usuários: 'System@123'
-- Hash BCrypt ($2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga)
-- ============================================================================

USE EstacionamentoDB;
GO

SET NOCOUNT ON;

-- 1. Usuários (System, Gerente, Operadores e Clientes)
INSERT INTO dbo.Usuarios (nome, email, senha_hash, perfil, discriminator, cpf, telefone, turno, setor) VALUES
-- System (Suporte e Implantação) - perfil=3
('Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, NULL, 'Implantação e Suporte'),

-- Gerente de Pátio e Operações - perfil=2
('Marcos Roberto Gerente', 'marcos.gerente@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, NULL, 'Pátio e Operações'),

-- Operadores de Caixa e Guarita - perfil=1
('Renato Silva Operador', 'renato.operador@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Operador', NULL, NULL, 'Manhã', NULL),
('Camila Santos Operadora', 'camila.operadora@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Operador', NULL, NULL, 'Tarde', NULL),

-- Clientes Mensalistas e Avulsos - perfil=0
('Alexandre Pires', 'alexandre.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '123.456.789-01', '11988881111', NULL, NULL),
('Beatriz Souza', 'beatriz.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '234.567.890-12', '11977772222', NULL, NULL),
('Cristiano Ramos', 'cristiano.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '345.678.901-23', '11966663333', NULL, NULL),
('Daniela Martins', 'daniela.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '456.789.012-34', '11955554444', NULL, NULL);
GO

-- 2. Vagas
INSERT INTO dbo.Vagas (localizacao, tipo) VALUES
('Setor A-01', 'Pequena'),
('Setor A-02', 'Pequena'),
('Setor B-01', 'Média'),
('Setor B-02', 'Média'),
('Setor C-01', 'Grande'),
('Setor C-02', 'Grande');
GO

-- 3. Veículos (vinculados aos Clientes IDs 5 a 8)
INSERT INTO dbo.Veiculos (cliente_id, placa, modelo, cor) VALUES
(5, 'ABC1D23', 'Fiat Uno Mille', 'Prata'),
(5, 'XYZ9E87', 'Chevrolet Onix', 'Preto'),
(6, 'BRA2E19', 'Honda Civic', 'Branco'),
(7, 'TTO4A56', 'Toyota Corolla Cross', 'Cinza'),
(8, 'SPK7J89', 'Jeep Compass', 'Azul');
GO

-- 4. Registros de Estacionamento (Histórico passado e ocupação ativa agora)
-- Operadores IDs: 3 (Renato) e 4 (Camila)
INSERT INTO dbo.RegistrosEstacionamento (veiculo_id, vaga_id, operador_id, data_hora_entrada, data_hora_saida, valor_total) VALUES
-- Saídas concluídas no passado (semana passada e ontem)
(1, 1, 3, DATEADD(DAY, -7, DATEADD(HOUR, -4, GETDATE())), DATEADD(DAY, -7, GETDATE()), 35.00),
(2, 3, 4, DATEADD(DAY, -3, DATEADD(HOUR, -2, GETDATE())), DATEADD(DAY, -3, GETDATE()), 20.00),
(3, 4, 3, DATEADD(DAY, -1, DATEADD(HOUR, -6, GETDATE())), DATEADD(DAY, -1, GETDATE()), 50.00),
-- Veículos atualmente estacionados no pátio (data_hora_saida e valor_total nulos)
(4, 5, 4, DATEADD(HOUR, -2, GETDATE()), NULL, NULL),
(5, 6, 3, DATEADD(MINUTE, -45, GETDATE()), NULL, NULL);
GO

PRINT 'Seed de dados executado com sucesso para EstacionamentoDB.';
GO
