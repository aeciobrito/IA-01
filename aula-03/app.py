import json
import requests
from flask import Flask, request, jsonify

app = Flask(__name__)

OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODELO_LLM = "gemma4:e2b"

PROMPT_SISTEMA_PARSER = """Você é um extrator de dados de pedidos de pizzaria de alta precisão.
Sua função é analisar a mensagem do cliente e extrair estritamente um JSON no seguinte esquema:
{
  "intencao": "fazer_pedido" ou "duvida" ou "outro",
  "itens": [
    {
      "produto": "nome do item padronizado",
      "quantidade": número inteiro,
      "observacao": "observações como sem cebola, borda recheada, etc, ou vazio"
    }
  ],
  "cliente_mencionou_endereco": true ou false,
  "confianca": "alta" ou "media" ou "baixa"
}

Exemplo 1:
Entrada: "Me vê 2 pizzas de calabresa sem cebola e uma fanta uva"
Saída JSON:
{"intencao": "fazer_pedido", "itens": [{"produto": "Pizza Calabresa", "quantidade": 2, "observacao": "sem cebola"}, {"produto": "Fanta Uva", "quantidade": 1, "observacao": ""}], "cliente_mencionou_endereco": false, "confianca": "alta"}

Exemplo 2:
Entrada: "Vocês aceitam cartão de refeição Alelo?"
Saída JSON:
{"intencao": "duvida", "itens": [], "cliente_mencionou_endereco": false, "confianca": "alta"}

Mensagem a analisar: """

@app.route("/api/parser-pedido", methods=["POST"])
def parse_pedido():
    # ETAPA 1 - CAPUTRAR OS DADOS ENVIADOS PELO USUÁRIO #OK
    dados = request.get_json()    

    # ETAPA 2 - VERIFICAR OS DADOS ENVIADOS PELO USUÁRIO #OK
    if not dados or "texto" not in dados:
        return jsonify({"erro": "Envie o campo 'texto' com a mensagem do cliente."})
    
    texto_cliente = dados["texto"].strip()

    if not texto_cliente:
        return jsonify({"erro": "O campo 'texto' não pode ser vazio."})
    
    # ETAPA 3 - CONCATENAR OS DADOS COM O PROMPT_PARSER E ENVIAR PARA A LLM
    prompt_final = f"{PROMPT_SISTEMA_PARSER}\"{texto_cliente}\"\nSaída JSON: "

    payload = {
        "model": MODELO_LLM,
        "prompt": prompt_final,
        "format": "json",
        "stream": False,
        "options": {
            "temperature": 0.2
        }
    }

    try:
        response = requests.post(OLLAMA_API_URL, json=payload, timeout=45)
        if response.status_code != 200:
            return jsonify(
                {
                    "erro": "Falha na comunicação com o Ollama",
                    "detalhes": response.text
                }), 502
        
        raw_output = response.json().get("response", "{}")

        return raw_output

    except request.exceptions.RequestException as e:
        return jsonify({"erro": f"Erro ao acessar serviço local de IA: {str(e)}."}), 503

    # ETAPA 4 - DEVOLVER RESPOSTA AO USUÁRIO

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
