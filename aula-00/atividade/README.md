# Atividade Prática 000: Diagnóstico e Validação do Ambiente de IA Local

## 1. Contexto de Negócio
Uma empresa de varejo deseja implementar um assistente virtual local para operar sem dependência de internet ou envio de dados de clientes para provedores externos (em conformidade com a LGPD). Como técnico em IA, sua primeira missão é configurar o ambiente de desenvolvimento local e homologar a conectividade com o modelo de linguagem.

## 2. Requisitos da Atividade
1. Criar um script em Python denominado `diagnostico_ambiente.py`.
2. O script deve:
   - Verificar se o serviço do Ollama está respondendo na porta local (`http://localhost:11434`).
   - Consultar o endpoint `/api/tags` do Ollama e listar todos os modelos instalados no ambiente.
   - Enviar uma mensagem de teste simples via POST para `/api/generate` solicitando ao modelo: *"Responda em uma única frase: o que é inteligência artificial?"*.
   - Exibir no terminal o tempo de resposta (latência) da inferência em segundos.
   - Tratar exceções caso o Ollama não esteja rodando, orientando o usuário a inicializá-lo.

## 3. Resultado Esperado no Terminal
```text
==================================================
   DIAGNÓSTICO DO AMBIENTE LOCAL DE IA - UC10
==================================================
[OK] Conexão com Ollama estabelecida em http://localhost:11434
[OK] Modelos disponíveis localmente:
     - llama3.2:1b
     - nomic-embed-text:latest

Enviando prompt de teste para o modelo 'llama3.2:1b'...
Resposta do modelo:
"Inteligência Artificial é a capacidade de sistemas computacionais simularem o raciocínio humano para resolver problemas e tomar decisões."

Tempo de resposta: 1.42s
[SUCESSO] Ambiente homologado e pronto para a UC10!
==================================================
```

## 4. Critérios de Aceite
- O script não deve travar com traceback bruto caso o servidor esteja desligado.
- Os modelos devem ser listados dinamicamente via requisição HTTP.
- O tempo de inferência deve ser medido com a biblioteca `time`.
