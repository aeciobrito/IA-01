# Ajustes e Padronização do Modelo de Dados

1. **Relação Cliente-Hospedagem:**
   * **Adição da Chave Estrangeira `cliente_id` na Tabela `Hospedagens`**: O diagrama original mostra uma linha de relacionamento entre `Cliente` e `Hospedagem`, indicando que uma hospedagem pertence a um cliente. Para implementar isso no banco de dados de forma relacional, é essencial adicionar a coluna `cliente_id` na tabela `Hospedagens` como chave estrangeira (`FOREIGN KEY`) referenciando a tabela `Clientes(id)`. Sem essa coluna, seria impossível rastrear qual cliente contratou a hospedagem.

2. **Relação Chale-Hospedagem:**
   * **Adição da Chave Estrangeira `chale_id` na Tabela `Hospedagens`**: De forma similar à anterior, o diagrama conecta `Chale` a `Hospedagem`. Para que cada registro de hospedagem esteja associado ao chalé físico alocado, a coluna `chale_id` foi adicionada à tabela `Hospedagens` como chave estrangeira referenciando `Chales(id)`.

3. **Tabela Associativa `Hospedagem_Servicos` (Serviços Consumidos):**
   * **Adição da Coluna `data_servico`**: Foi incluída a coluna `data_servico` compondo a chave primária (`hospedagem_id`, `servico_id`, `data_servico`). Isso permite registrar o mesmo serviço (ex: "Café da Manhã no Quarto") várias vezes para a mesma hospedagem, contanto que seja em dias/horários diferentes. O diagrama original não previa essa granularidade temporal.
   * **Armazenamento de `valor_servico`**: A coluna `valor_servico` foi adicionada para registrar o preço unitário vigente do serviço no momento exato em que ele foi consumido. Isso garante a consistência histórica e financeira da hospedagem, protegendo o faturamento contra eventuais reajustes futuros no catálogo (`Servicos.valor`).

4. **Restrições de Integridade (`UNIQUE`):**
   * **RG Único para Cliente**: Foi adicionada uma restrição `UNIQUE` (`UQ_Clientes_RG`) na coluna `rg` da tabela `Clientes`. Essa regra de negócio é fundamental para impedir o cadastro duplicado de hóspedes com base em documento oficial.

---

## Padrão de Nomenclatura e Boas Práticas (Alinhamento com a UC4)

Para manter a coerência pedagógica com os demais projetos da unidade curricular (`Estacionamento` e `Pizzaria`) e com as aulas práticas:

* **Chaves Primárias (PK)**: Todas as tabelas de entidades utilizam exclusivamente a coluna `id` (`INT IDENTITY` / `INTEGER AUTOINCREMENT`).
* **Chaves Estrangeiras (FK)**: Padronizadas no formato `<tabela_no_singular>_id` (ex: `cliente_id`, `chale_id`, `servico_id`, `hospedagem_id`, `item_id`).
* **Estilo de Colunas**: Todas as colunas são grafadas em `snake_case`, eliminando prefixos ou sufixos redundantes com o nome da própria tabela (ex: `nome` em vez de `nomeCliente`, `rg` em vez de `rgCliente`).
* **Tabelas**: Plural em PascalCase para entidades (`Clientes`, `Telefones`, `Chales`, `Itens`, `Servicos`, `Hospedagens`) e tabelas associativas N:N no formato `Entidade_Entidade` (`Chale_Itens`, `Hospedagem_Servicos`).

### Mapeamento Completo de Nomes (Diagrama Original vs. Padrão UC4)

| Tabela | Nome Original (Diagrama) | Padrão Adotado (UC4) | Tipo de Coluna |
|---|---|---|---|
| **Clientes** | `codCliente` | `id` | Chave Primária |
| | `nomeCliente` | `nome` | Texto obrigatório |
| | `rgCliente` | `rg` | Texto obrigatório (`UNIQUE`) |
| | `enderecoCliente` | `endereco` | Texto |
| | `bairroCliente` | `bairro` | Texto |
| | `cidadeCliente` | `cidade` | Texto |
| | `estadoCliente` | `estado` | Sigla fixa (2 caracteres) |
| | `CEPCliente` | `cep` | Texto |
| | `nascimentoCliente` | `data_nascimento` | Data obrigatória |
| **Telefones** | `codCliente` | `cliente_id` | Chave Estrangeira / PK composta |
| | `telefone` | `telefone` | Texto obrigatório / PK composta |
| | `tipoTelefone` | `tipo` | Texto com padrão ('Celular') |
| **Chales** | `codChale` | `id` | Chave Primária |
| | `localizacao` | `localizacao` | Texto obrigatório |
| | `capacidade` | `capacidade` | Inteiro positivo |
| | `valorAltaEstacao` | `valor_alta_estacao` | Monetário positivo |
| | `valorBaixaEstacao` | `valor_baixa_estacao` | Monetário positivo |
| **Itens** | `nomeItem` | `id` | Chave Primária |
| | `nomeItem` | `nome` | Texto obrigatório (`UNIQUE`) |
| | `descricaoItem` | `descricao` | Texto descritivo |
| **Chale_Itens** | `codChale` | `chale_id` | Chave Estrangeira / PK composta |
| | `nomeItem` | `item_id` | Chave Estrangeira / PK composta |
| **Servicos** | `codServico` | `id` | Chave Primária |
| | `nomeServico` | `nome` | Texto obrigatório (`UNIQUE`) |
| | `valorServico` | `valor` | Monetário positivo |
| **Hospedagens** | `codHospedagem` | `id` | Chave Primária |
| | *(ausente)* | `cliente_id` | Chave Estrangeira |
| | `codChale` | `chale_id` | Chave Estrangeira |
| | `estado` | `estado` | Texto ('Aberta', 'Encerrada') |
| | `dataInicio` | `data_inicio` | Data/hora obrigatória |
| | `dataFim` | `data_fim` | Data/hora (`>= data_inicio`) |
| | `qtdPessoas` | `qtd_pessoas` | Inteiro positivo |
| | `desconto` | `desconto` | Percentual (0 a 100) |
| | `valorFinal` | `valor_final` | Monetário |
| **Hospedagem_Servicos** | `codHospedagem` | `hospedagem_id` | Chave Estrangeira / PK composta |
| | `codServico` | `servico_id` | Chave Estrangeira / PK composta |
| | `dataServico` | `data_servico` | Data/hora / PK composta |
| | `valorServico` | `valor_servico` | Preço congelado no consumo |

---

## 5. Evolução para Controle de Usuários e Autenticação (TPH)

Para habilitar a camada de Web API com autenticação JWT e auto-cadastro no frontend, os dados de identificação foram unificados na tabela `Usuarios` utilizando o padrão **Table-Per-Hierarchy (TPH)** com a coluna `discriminator`:
- **System**: Equipe de suporte e implantação com privilégios irrestritos (`perfil = 3`).
- **Gerente**: Gestão da pousada, governança e relatórios (`perfil = 2`).
- **Recepcionista**: Operação de recepção, check-in, check-out e atendimento (`perfil = 1`, `turno`).
- **Cliente**: Hóspede titular da reserva (`perfil = 0`, com `rg`, dados de endereço e data de nascimento).
- A tabela `Hospedagens` vincula o titular em `cliente_id` e registra o operador em `recepcionista_id`.

