# Explicação das Escolhas e Restrições (Constraints)

1. **`PRIMARY KEY` (PK - Chave Primária):**
   * Em tabelas de entidades (`Clientes`, `Chales`, `Itens`, `Servicos`, `Hospedagens`), foi utilizado o identificador universal `id` com autoincremento (`INT IDENTITY(1,1)` no SQL Server e `INTEGER AUTOINCREMENT` no SQLite). Esta é a convenção padrão da UC4 para simplificar a manipulação e integração via ORMs e Scaffolding.
   * Em tabelas associativas (`Chale_Itens` e `Hospedagem_Servicos`) e na entidade fraca `Telefones`, a chave primária é **composta**:
     * `Telefones`: `(cliente_id, telefone)`.
     * `Chale_Itens`: `(chale_id, item_id)`.
     * `Hospedagem_Servicos`: `(hospedagem_id, servico_id, data_servico)`. Isso garante a integridade e unicidade do histórico, permitindo que um mesmo hóspede usufrua do mesmo serviço em datas distintas.

2. **`FOREIGN KEY` (FK - Chave Estrangeira):**
   * Padronizadas com a sintaxe `<tabela_no_singular>_id` (`cliente_id`, `chale_id`, `item_id`, `servico_id`, `hospedagem_id`).
   * Asseguram a **integridade referencial** entre pais e filhos, impedindo registros órfãos.

3. **Ações de Chave Estrangeira (`ON DELETE` e `ON UPDATE`):**
   * **`ON DELETE CASCADE`**: Aplicado em `Telefones` e `Chale_Itens`. Se o cliente for removido, seus números de telefone são excluídos juntos. Se um chalé ou item for removido, suas associações em `Chale_Itens` são eliminadas automaticamente.
   * **`ON DELETE RESTRICT` / `NO ACTION`**: Aplicado em `Hospedagens` (em relação a `Clientes` e `Chales`) e em `Hospedagem_Servicos` (em relação a `Servicos`). Garante que nenhum cliente, chalé ou serviço que possua histórico de faturamento seja excluído acidentalmente.
   * **`ON UPDATE CASCADE`**: Propaga eventuais alterações cadastrais de chaves para as tabelas dependentes.

4. **Tipos de Dados e Domínio:**
   * **`INT` / `INTEGER`**: Para chaves primárias e chaves estrangeiras.
   * **`VARCHAR(n)` / `TEXT`**: Para textos com tamanhos controlados (nomes, logradouros, telefones).
   * **`CHAR(2)`**: Para a sigla da UF na tabela `Clientes`, validada para ter exatamente 2 caracteres.
   * **`DATE` / `DATETIME`**: Para instantes temporais (`data_nascimento`, `data_inicio`, `data_fim`, `data_servico`).
   * **`DECIMAL(10, 2)` / `REAL`**: Para valores monetários e tarifas diárias.
   * **`DECIMAL(5, 2)`**: Para percentuais de desconto (0.00 a 100.00).

5. **`UNIQUE` Constraints:**
   * **`UQ_Usuarios_Email`**: Garante a exclusividade de login/credencial para cada usuário.
   * **`UQ_Usuarios_RG`**: Impede o cadastro duplicado de um hóspede com o mesmo RG.
   * **`UQ_Itens_Nome`**: Garante que cada item/comodidade tenha nome exclusivo no catálogo.
   * **`UQ_Servicos_Nome`**: Garante exclusividade de nome para os serviços adicionais.

6. **`CHECK` Constraints:**
   * `CK_Chales_Capacidade`: `capacidade > 0`.
   * `CK_Chales_ValorAlta`: `valor_alta_estacao > 0`.
   * `CK_Chales_ValorBaixa`: `valor_baixa_estacao > 0`.
   * `CK_Servicos_Valor`: `valor >= 0`.
   * `CK_Hospedagens_QtdPessoas`: `qtd_pessoas > 0`.
   * `CK_Hospedagens_Datas`: `data_fim >= data_inicio`.
   * `CK_Hospedagens_Desconto`: `desconto >= 0.00 AND desconto <= 100.00`.
   * `CK_HospServ_Valor`: `valor_servico >= 0`.