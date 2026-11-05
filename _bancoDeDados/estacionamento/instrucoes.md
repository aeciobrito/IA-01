# Projeto de Referência: Sistema de Estacionamento "Sempre Rápido"

## 1. Visão Geral

Este projeto modela o sistema operacional e comercial do estacionamento "Sempre Rápido", integrando autenticação e perfis de acesso de usuários (Cliente/Mensalista, Operador de Pátio/Caixa, Gerente e System), controle dinâmico do fluxo de veículos, alocação de vagas por categoria e faturamento baseado no tempo de permanência com integridade referencial estrita.

---

## 2. Descrição do Sistema e Regras de Negócio

1. **Usuários (Perfis de Acesso em TPH)**:
   - Tabela unificada (`Usuarios`) com `discriminator` e `perfil` para representar perfis de acesso: System (suporte e implantação global), Gerente (operações de pátio), Operador (guarita, guichê e lançamento de entradas/saídas) e Cliente (mensalista, visualização de histórico e veículos).
   - Atributos universais: `nome`, `email` (`UNIQUE`) e `senha_hash` (criptografada via BCrypt).
   - Atributos especializados: `cpf` (`UNIQUE`) e `telefone` para Clientes, `turno` para Operadores e `setor` para Gerentes/System.
2. **Vagas**:
   - Vagas identificadas por `localizacao` única (ex: 'Setor A-01', 'Setor B-05') e categorizadas por `tipo` ('Pequena', 'Média', 'Grande').
   - **Regra de Integridade Referencial**: Uma vaga não pode ser removida fisicamente se houver qualquer registro de utilização histórico (`ON DELETE RESTRICT` / `NO ACTION`).
3. **Veículos**:
   - Cada veículo pertence a um cliente titular (`cliente_id` FK `Usuarios`).
   - Atributos: `placa` (`UNIQUE`), `modelo` e `cor`.
   - **Regra de Integridade Referencial**: A exclusão de um cliente remove em cascata seus veículos vinculados (`ON DELETE CASCADE`).
4. **Registro de Estacionamento (Entidade Central)**:
   - Toda entrada gera um registro associando veículo (`veiculo_id` FK `Veiculos`), vaga ocupada (`vaga_id` FK `Vagas`), operador responsável (`operador_id` FK `Usuarios`) e `data_hora_entrada`.
   - Na saída, o registro recebe `data_hora_saida` e `valor_total`.
   - **Regra de Integridade Referencial**: Bloqueio de exclusão para veículos ou vagas com registros históricos (`ON DELETE RESTRICT` / `NO ACTION`).
   - **Regra de Ocupação**: Uma vaga ocupada (com `data_hora_saida IS NULL`) não pode receber outro veículo ativo simultaneamente.

---

## 3. Implementações Disponíveis

| Ambiente / Dialeto | Caminho do Script | Descrição Técnica |
|---|---|---|
| **SQLite (DDL)** | [`sqlite/estacionamento_sqlite.sql`](sqlite/estacionamento_sqlite.sql) | DDL para SQLite3 com chaves estrangeiras, TPH, `ON DELETE CASCADE/RESTRICT/SET NULL` e constraints. |
| **SQLite (Seed)** | [`sqlite/seed_sqlite.sql`](sqlite/seed_sqlite.sql) | Script de seed populando perfil System, Gerente, Operadores, Clientes com senha BCrypt, veículos, vagas e movimentações com datas relativas via `datetime('now')`. |
| **SQL Server (DDL)** | [`sqlserver/estacionamento_sqlserver.sql`](sqlserver/estacionamento_sqlserver.sql) | DDL corporativo em T-SQL com `IDENTITY(1,1)`, constraints de unicidade, índices filtrados e integridade referencial. |
| **SQL Server (Seed)** | [`sqlserver/seed_sqlserver.sql`](sqlserver/seed_sqlserver.sql) | Script de seed corporativo em T-SQL com perfil System, Gerente, Operadores, Clientes com senha BCrypt, veículos, vagas e movimentações com datas relativas via `GETDATE()`. |

---

## 4. Padrões de Integridade e Modelagem Relacional

1. **Tabela de Usuários Única (Table-Per-Hierarchy - TPH)**:
   - Centraliza o controle de acesso e simplifica o fluxo de autenticação JWT, permitindo que qualquer ator do sistema se autentique pelo mesmo endpoint.
2. **Diferenciação de Ações Estrangeiras (`CASCADE` vs `RESTRICT` vs `SET NULL`)**:
   - `Veiculos -> Usuarios (Cliente)`: `CASCADE`, pois o veículo depende diretamente do cadastro de seu titular.
   - `RegistrosEstacionamento -> Veiculos / Vagas`: `RESTRICT`, impedindo que a exclusão física de um veículo ou de uma vaga destrua o histórico financeiro e fiscal do estabelecimento.
   - `RegistrosEstacionamento -> Usuarios (Operador)`: `SET NULL`, preservando o registro de estacionamento mesmo se o operador for desativado.
3. **Unicidade de Identificadores**:
   - Restrições `UNIQUE` em `Usuarios(email)`, `Usuarios(cpf)`, `Veiculos(placa)` e `Vagas(localizacao)`.
4. **Integridade de Registro**:
   - Chaves estrangeiras obrigatórias apontando para `Veiculos` e `Vagas`, assegurando consistência na entrada e na liquidação da cobrança.
