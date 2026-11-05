-- ============================================================================
-- PROJETO ESTACIONAMENTO SEMPRE RÁPIDO - SEED DE DADOS (SQLITE)
-- Carga inicial com usuários (System, Gerente, Operador, Clientes), veículos,
-- vagas e fluxo com datetime('now')
-- Senha padrão para testes de todos os usuários: 'System@123'
-- Hash BCrypt ($2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga)
-- ============================================================================

PRAGMA foreign_keys = ON;

-- 1. Usuários (System, Gerente, Operadores e Clientes)
INSERT INTO Usuarios (id, nome, email, senha_hash, perfil, discriminator, cpf, telefone, turno, setor) VALUES
-- System (Suporte e Implantação) - perfil=3
(1, 'Administrador do Sistema (Suporte)', 'system@senactito.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 3, 'System', NULL, NULL, NULL, 'Implantação e Suporte'),

-- Gerente de Pátio e Operações - perfil=2
(2, 'Marcos Roberto Gerente', 'marcos.gerente@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 2, 'Gerente', NULL, NULL, NULL, 'Pátio e Operações'),

-- Operadores de Caixa e Guarita - perfil=1
(3, 'Renato Silva Operador', 'renato.operador@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Operador', NULL, NULL, 'Manhã', NULL),
(4, 'Camila Santos Operadora', 'camila.operadora@estacionamentosr.com.br', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 1, 'Operador', NULL, NULL, 'Tarde', NULL),

-- Clientes Mensalistas e Avulsos - perfil=0
(5, 'Alexandre Pires', 'alexandre.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '123.456.789-01', '11988881111', NULL, NULL),
(6, 'Beatriz Souza', 'beatriz.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '234.567.890-12', '11977772222', NULL, NULL),
(7, 'Cristiano Ramos', 'cristiano.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '345.678.901-23', '11966663333', NULL, NULL),
(8, 'Daniela Martins', 'daniela.cliente@email.com', '$2a$12$R9h/cIPz0gi.URNNGUQ2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUga', 0, 'Cliente', '456.789.012-34', '11955554444', NULL, NULL);

-- 2. Vagas
INSERT INTO Vagas (id, localizacao, tipo) VALUES
(1, 'Setor A-01', 'Pequena'),
(2, 'Setor A-02', 'Pequena'),
(3, 'Setor B-01', 'Média'),
(4, 'Setor B-02', 'Média'),
(5, 'Setor C-01', 'Grande'),
(6, 'Setor C-02', 'Grande');

-- 3. Veículos (vinculados aos Clientes IDs 5 a 8)
INSERT INTO Veiculos (id, cliente_id, placa, modelo, cor) VALUES
(1, 5, 'ABC1D23', 'Fiat Uno Mille', 'Prata'),
(2, 5, 'XYZ9E87', 'Chevrolet Onix', 'Preto'),
(3, 6, 'BRA2E19', 'Honda Civic', 'Branco'),
(4, 7, 'TTO4A56', 'Toyota Corolla Cross', 'Cinza'),
(5, 8, 'SPK7J89', 'Jeep Compass', 'Azul');

-- 4. Registros de Estacionamento (Histórico passado e ocupação ativa agora)
-- Operadores IDs: 3 (Renato) e 4 (Camila)
INSERT INTO RegistrosEstacionamento (id, veiculo_id, vaga_id, operador_id, data_hora_entrada, data_hora_saida, valor_total) VALUES
-- Saídas concluídas no passado (semana passada e ontem)
(1, 1, 1, 3, datetime('now', '-7 day', '-4 hour'), datetime('now', '-7 day'), 35.00),
(2, 2, 3, 4, datetime('now', '-3 day', '-2 hour'), datetime('now', '-3 day'), 20.00),
(3, 3, 4, 3, datetime('now', '-1 day', '-6 hour'), datetime('now', '-1 day'), 50.00),
-- Veículos atualmente estacionados no pátio (data_hora_saida e valor_total nulos)
(4, 4, 5, 4, datetime('now', '-2 hour'), NULL, NULL),
(5, 5, 6, 3, datetime('now', '-45 minute'), NULL, NULL);
