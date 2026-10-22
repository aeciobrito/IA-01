# Atividade Prática 003: Parser Inteligente de Pedidos em JSON

## 1. Contexto de Negócio
No aplicativo de delivery da Bella Tito, os clientes costumam mandar mensagens em texto corrido pelo chat. O sistema de retaguarda (C# .NET 8) precisa receber um objeto JSON rígido para calcular o preço e encaminhar para a cozinha. Sua missão é criar o endpoint que recebe a mensagem livre e entrega o pedido estruturado.

## 2. Requisitos da Aplicação
1. Criar o endpoint `POST /api/parser-pedido`.
2. O endpoint deve receber: `{"texto": "Quero 1 pizza portuguesa sem azeitona e 2 cocas lata"}`.
3. Enviar prompt com Few-Shot e `format="json"` para o Ollama local (`llama3.2:1b`).
4. O JSON de resposta deve conter obrigatoriamente a seguinte estrutura:
   ```json
   {
     "intencao": "fazer_pedido",
     "itens": [
       {
         "produto": "Pizza Portuguesa",
         "quantidade": 1,
         "observacao": "sem azeitona"
       },
       {
         "produto": "Coca-Cola Lata",
         "quantidade": 2,
         "observacao": ""
       }
     ],
     "cliente_mencionou_endereco": false,
     "confianca": "alta"
   }
   ```
5. Caso o texto do usuário seja uma dúvida (ex: "Vocês aceitam Pix?"), o campo `intencao` deve ser `"duvida"` e a lista de `itens` deve vir vazia.

## 3. Critérios de Aceite
- A saída do endpoint deve ser um objeto JSON validado (usando `json.loads` antes de retornar).
- Se a IA gerar um JSON malformado, o código deve capturar o erro `json.JSONDecodeError` e retornar um fallback consistente com status 200.