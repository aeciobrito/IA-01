# Projeto de Referência: Pizzaria "Bella Tito"

## 1. Visão Geral

Este projeto modela o ecossistema relacional e comercial da Pizzaria "Bella Tito", cobrindo autenticação e controle de perfis de usuários (Cliente, Atendente, Gerente e System), cardápio dinâmico de pizzas com controle de disponibilidade, formas de pagamento ativas e a emissão de pedidos com detalhamento de itens em relacionamento N:N. O projeto serve como referência completa para implementação relacional em SQLite e SQL Server.

---

## 2. Descrição do Sistema e Regras de Negócio

1. **Usuários (Perfis de Acesso em TPH)**:
   - Tabela unificada (`Usuarios`) com `discriminator` e `perfil` para representar perfis de acesso: System (suporte e implantação global), Gerente (gestão da unidade), Atendente (frente de balcão e despacho) e Cliente (pedidos e auto-cadastro).
   - Atributos universais: `nome`, `email` (`UNIQUE`) e `senha_hash` (criptografada via BCrypt).
   - Atributos especializados: `telefone` (`UNIQUE`), `endereco` e `cpf` para Clientes, `turno` para Atendentes e `setor` para Gerentes/System.
2. **Cardápio de Pizzas**:
   - Informações de cada pizza: `sabor` (`UNIQUE`), `ingredientes` descritivos, `valor` unitário positivo (`CHECK (valor > 0)`) e flag `disponivel`.
   - **Regra de Integridade**: Uma pizza não pode ser removida fisicamente do cardápio se fizer parte do histórico de algum pedido já realizado (`ON DELETE RESTRICT` / `NO ACTION`).
3. **Formas de Pagamento**:
   - Catálogo com `nome` (`UNIQUE`) e flag `ativo` (Dinheiro, Débito, Crédito, Pix).
4. **Pedidos**:
   - Entidade central gerada pelo cliente (`cliente_id` FK `Usuarios`), opcionalmente atendida/despachada por um atendente (`atendente_id` FK `Usuarios`) e liquidada por uma forma de pagamento (`forma_pagamento_id` FK `FormasPagamento`).
   - Um pedido contém `data_hora`, `status` ('Em preparo', 'A caminho', 'Entregue', 'Cancelado'), `valor_total` e `observacoes`.
5. **Itens do Pedido (Relacionamento N:N)**:
   - Tabela associativa entre `Pedidos` e `Pizzas`.
   - Armazena `quantidade` (`CHECK (quantidade > 0)`) e `valor_unitario` histórico congelado no momento da venda (o valor da pizza no cardápio pode sofrer reajuste futuro sem afetar o histórico financeiro dos pedidos já fechados).
   - Se um pedido for cancelado e excluído, todos os seus itens associados são excluídos automaticamente (`ON DELETE CASCADE`).

---

## 3. Implementações Disponíveis

| Ambiente / Dialeto | Caminho do Script | Descrição Técnica |
|---|---|---|
| **SQLite (DDL)** | [`sqlite/pizzaria_sqlite.sql`](sqlite/pizzaria_sqlite.sql) | DDL compatível com SQLite3, tipos dinâmicos, TPH com `CHECK (discriminator IN (...))`, chaves compostas e integridade referencial. |
| **SQLite (Seed)** | [`sqlite/seed_sqlite.sql`](sqlite/seed_sqlite.sql) | Script de seed populando perfil System, Gerente, Atendente, Clientes com senha criptografada BCrypt, cardápio, formas de pagamento e pedidos com datas relativas. |
| **SQL Server (DDL)** | [`sqlserver/pizzaria_sqlserver.sql`](sqlserver/pizzaria_sqlserver.sql) | DDL corporativo em T-SQL com `IDENTITY(1,1)`, constraints, TPH, índices filtrados e integridade referencial. |
| **SQL Server (Seed)** | [`sqlserver/seed_sqlserver.sql`](sqlserver/seed_sqlserver.sql) | Script de seed corporativo em T-SQL com perfil System, Gerente, Atendente, Clientes com senha BCrypt, cardápio, formas de pagamento e pedidos com datas relativas via `GETDATE()`. |

---

## 4. Padrões de Integridade e Modelagem Relacional

1. **Tabela de Usuários Única (Table-Per-Hierarchy - TPH)**:
   - Adotada para simplificar a herança de domínio no Entity Framework Core e centralizar o fluxo de autenticação JWT em um único endpoint `/api/Usuarios/autenticar`.
2. **Chave Primária Composta em `Pedido_Itens`**:
   - A chave primária é composta por `(pedido_id, pizza_id)`, garantindo a unicidade do item dentro do pedido sem necessidade de chave artificial redundante.
3. **Congelamento Histórico de Preço**:
   - A coluna `valor_unitario` em `Pedido_Itens` preserva o valor exato negociado na data da venda, garantindo a integridade dos relatórios financeiros históricos.
4. **Comportamento das Chaves Estrangeiras**:
   - `Pedido_Itens -> Pedidos`: Configurado com `ON DELETE CASCADE`.
   - `Pedido_Itens -> Pizzas`: Configurado com `ON DELETE RESTRICT` (`NO ACTION` no SQL Server), impedindo a quebra de integridade de vendas passadas.
   - `Pedidos -> Usuarios (Cliente)`: Configurado com `ON DELETE RESTRICT` / `NO ACTION`.
   - `Pedidos -> Usuarios (Atendente)`: Configurado com `ON DELETE SET NULL`.