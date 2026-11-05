# Projeto de Referência: Pousada Chalés da Serra (Hospedagem)

## 1. Visão Geral

Este projeto modela o sistema operacional e comercial de uma pousada com chalés de montanha, integrando autenticação e perfis de acesso de usuários (Hóspede/Cliente, Recepcionista, Gerente e System), alocação de acomodações com tarifas sazonais, comodidades personalizadas, catálogo de serviços extras consumidos durante a estadia e histórico de reservas com integridade referencial estrita.

---

## 2. Descrição do Sistema e Regras de Negócio

1. **Usuários (Perfis de Acesso em TPH)**:
   - Tabela unificada (`Usuarios`) com `discriminator` e `perfil` para representar perfis de acesso: System (suporte e implantação global), Gerente (hotelaria e governança), Recepcionista (frente de recepção, check-in, check-out e lançamentos) e Cliente/Hóspede (reservas e auto-cadastro).
   - Atributos universais: `nome`, `email` (`UNIQUE`) e `senha_hash` (criptografada via BCrypt).
   - Atributos especializados: `rg` (`UNIQUE`), `endereco`, `bairro`, `cidade`, `estado`, `cep` e `data_nascimento` para Clientes/Hóspedes; `turno` para Recepcionistas; `setor` para Gerentes/System.
2. **Telefones dos Clientes**:
   - Um cliente pode possuir múltiplos telefones de contato (`Telefones`), com integridade `ON DELETE CASCADE` referenciando `cliente_id` FK `Usuarios(id)` (ao excluir o cliente, seus telefones são removidos).
3. **Chalés e Comodidades (Itens)**:
   - Chalés possuem `localizacao`, `capacidade` máxima e tarifas diferenciadas para Alta e Baixa Estação (`valor_alta_estacao` e `valor_baixa_estacao`).
   - Comodidades (lareira, banheira de hidromassagem, Wi-Fi) são modeladas em uma tabela associativa `Chale_Itens` (N:N), relacionando `chale_id` e `item_id`.
4. **Serviços Extras**:
   - Catálogo de serviços adicionais (`Servicos`), como café no quarto, passeios e massagens, com tarifário vigente (`valor`).
5. **Hospedagens e Serviços Consumidos (Entidade Central)**:
   - Registra o hóspede (`cliente_id` FK `Usuarios`), o chalé alocado (`chale_id` FK `Chales`), o recepcionista responsável pelo registro (`recepcionista_id` FK `Usuarios`), período (`data_inicio` a `data_fim`), quantidade de hóspedes (`qtd_pessoas`) e percentual de desconto concedido (`desconto`).
   - Os serviços consumidos durante a estadia são gravados na tabela associativa `Hospedagem_Servicos`, registrando `data_servico` e o preço congelado `valor_servico` no momento do consumo.
   - **Regra de Integridade**: Proibido excluir um cliente ou chalé que possua histórico de hospedagens realizadas (`ON DELETE RESTRICT` / `NO ACTION`).

---

## 3. Implementações Disponíveis

| Ambiente / Dialeto | Caminho do Script | Descrição Técnica |
|---|---|---|
| **SQL Server (DDL)** | [`sqlserver/hospedagem_sqlserver.sql`](sqlserver/hospedagem_sqlserver.sql) | DDL corporativo em T-SQL com `IDENTITY(1,1)`, constraints de validação, TPH com `CHECK` e índices filtrados. |
| **SQL Server (Seed)** | [`sqlserver/seed_sqlserver.sql`](sqlserver/seed_sqlserver.sql) | Script de seed corporativo em T-SQL com perfil System, Gerente, Recepcionistas, Hóspedes com senha BCrypt, chalés, serviços e hospedagens com datas relativas via `GETDATE()`. |
| **SQLite (DDL)** | [`sqlite/hospedagem_sqlite.sql`](sqlite/hospedagem_sqlite.sql) | DDL relacional em SQLite3 com tipos de dados, TPH, chaves compostas e integridade referencial. |
| **SQLite (Seed)** | [`sqlite/seed_sqlite.sql`](sqlite/seed_sqlite.sql) | Script de seed populando perfil System, Gerente, Recepcionistas, Hóspedes com senha BCrypt, chalés, comodidades, serviços e reservas com datas relativas via `datetime('now')`. |

---

## 4. Padrões de Integridade e Modelagem Relacional

1. **Tabela de Usuários Única (Table-Per-Hierarchy - TPH)**:
   - Unificação de perfis em `Usuarios` compatível com o mapeamento discriminatório do EF Core e o fluxo de autenticação JWT unificado.
2. **Chaves Estrangeiras e Unicidade**:
   - A tabela central `Hospedagens` vincula explicitamente `cliente_id` e `chale_id` (`ON DELETE NO ACTION`/`RESTRICT`), e `recepcionista_id` (`ON DELETE SET NULL`).
   - Na tabela `Hospedagem_Servicos`, a chave primária composta inclui `data_servico` (`hospedagem_id, servico_id, data_servico`) para permitir que o hóspede solicite o mesmo serviço em datas distintas.
3. **Validações Declarativas (`CHECK Constraints`)**:
   - Restrição temporal garantindo que `data_fim >= data_inicio`.
   - Validações garantindo que diárias, valores e capacidades sejam positivos (`> 0` ou `>= 0`).
4. **Congelamento de Histórico**:
   - A tabela associativa `Hospedagem_Servicos` armazena `valor_servico` no momento da solicitação, mantendo a integridade contábil diante de reajustes futuros do catálogo.
