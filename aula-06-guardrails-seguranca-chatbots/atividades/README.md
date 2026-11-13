# Atividade Prática 016: API Protegida com Guardrails da Pizzaria Bella Tito

## 1. Contexto de Negócio
A **Pizzaria Bella Tito** quer garantir em sua API Web de atendimento que clientes mal-intencionados não consigam manipular preços, ofender o atendente ou desviar o modelo `gemma4:12b` para assuntos fora do cardápio.

## 2. Requisitos da Aplicação
1. Criar a aplicação Flask em `app_pizzaria_guardrails.py`.
2. Criar a função `filtrar_mensagem(texto)` usando Regex para bloquear:
   - *Prompt Injection* (`ignore`, `esqueça as regras`).
   - *Adulteração de preço* (`venda por 0`, `pizza de graça`).
   - *Ofensas ou palavrões* e *assuntos fora de escopo*.
3. Na rota `POST /api/chat`, bloquear mensagens inseguras com HTTP `400` e `{"bloqueado": True, ...}` **antes** de acionar o Ollama.
4. Quando aprovada, consultar os sabores disponíveis em `_bancoDeDados/pizzaria/pizzaria.db` e responder com `gemma4:12b`.

## 3. Como Testar
```bash
python sua-pasta/app_pizzaria_guardrails.py
```
