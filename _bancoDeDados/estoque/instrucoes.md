# Projeto de Referência: Armazém Tito (Controle de Estoque e Vendas)

## 1. Visão Geral

Este projeto modela o sistema corporativo de gestão comercial do Armazém Tito, integrando estoque de produtos, fornecedores parceiros, faturamento com contas a receber e movimentação de pedidos com perfis de acesso diferenciados (Cliente, Caixa e Gerente). O foco relacional está na modelagem de integridade referencial estrita, herança de entidades em tabela única (TPH), constraints financeiras e integridade de histórico contábil.

---

## 2. Descrição do Sistema e Regras de Negócio

1. **Usuários (Perfis de Acesso)**:
   - Tabela unificada (`Usuarios`) com `discriminator` e `perfil` para representar perfis de acesso: System (suporte e implantação global), Gerente, Caixa e Cliente.
   - Atributos universais: `nome`, `email` (`UNIQUE`) e `senha_hash`.
   - Atributos especializados: `cpf` para Clientes, `turno` para Caixas e `setor` para Gerentes.
2. **Fornecedores**:
   - Cadastro contendo `nome_fantasia` e `cnpj` (`UNIQUE`).
   - Bloqueio de exclusão física para fornecedores com produtos cadastrados (`ON DELETE RESTRICT` / `NO ACTION`).
3. **Produtos e Nível de Estoque**:
   - Produtos possuem `nome`, `preco` (`CHECK (preco >= 0)`), `quantidade_estoque` (`CHECK (quantidade_estoque >= 0)`) e vínculo com `fornecedor_id`.
   - Bloqueio de exclusão física para produtos vinculados a pedidos existentes (`ON DELETE RESTRICT` / `NO ACTION`).
4. **Formas de Pagamento**:
   - Catálogo com `nome` (`UNIQUE`) e flag `ativo`.
5. **Pedidos e Itens de Pedido**:
   - O pedido registra `cliente_id`, `forma_pagamento_id`, `data_pedido`, `status` e opcionalmente `caixa_id`.
   - Os itens do pedido (`ItensPedido`) armazenam `quantidade` (`CHECK (quantidade > 0)`), `preco_unitario` (`CHECK (preco_unitario >= 0)`) histórico congelado no ato da venda e referências a `pedido_id` e `produto_id`.
   - Exclusão em cascata configurada de Pedidos para seus Itens (`ON DELETE CASCADE`).
6. **Contas a Receber**:
   - Lançamentos financeiros com `descricao`, `valor` (`CHECK (valor >= 0)`), `data_vencimento`, `data_pagamento` e `status` ('Pendente', 'Pago', 'Cancelado').

---

## 3. Implementações Disponíveis

| Ambiente / Dialeto | Caminho do Script | Descrição Técnica |
|---|---|---|
| **SQLite (DDL)** | [`sqlite/estoque_sqlite.sql`](sqlite/estoque_sqlite.sql) | DDL para SQLite3, tipos de dados, chaves compostas e integridade referencial. |
| **SQLite (Seed)** | [`sqlite/seed_sqlite.sql`](sqlite/seed_sqlite.sql) | Script de seed populando perfil System, formas de pagamento, produtos e movimentações com datas relativas. |
| **SQL Server (DDL)** | [`sqlserver/estoque_sqlserver.sql`](sqlserver/estoque_sqlserver.sql) | DDL corporativo em T-SQL com `IDENTITY(1,1)`, constraints e integridade referencial. |
| **SQL Server (Seed)** | [`sqlserver/seed_sqlserver.sql`](sqlserver/seed_sqlserver.sql) | Script de seed corporativo em T-SQL com perfil System, formas de pagamento, produtos e movimentações com datas relativas. |

---

## 4. Padrões de Integridade e Modelagem Relacional

1. **Ações de Chave Estrangeira (`CASCADE` vs `RESTRICT`)**:
   - `ItensPedido -> Pedidos`: `CASCADE`, pois os itens existem exclusivamente no contexto do pedido que os agrega.
   - `Produtos -> Fornecedores`: `RESTRICT`, impedindo a remoção de fornecedores com produtos cadastrados.
   - `ItensPedido -> Produtos`: `RESTRICT`, preservando o histórico contábil e fiscal das vendas passadas.
2. **Restrições de Domínio (`CHECK`)**:
   - Validações em nível de banco para impedir preços ou quantidades negativas (`preco >= 0`, `quantidade_estoque >= 0`, `quantidade > 0`).
3. **Unicidade de Identificadores**:
   - Restrições `UNIQUE` em `Usuarios(email)`, `Fornecedores(cnpj)` e `FormasPagamento(nome)`.
