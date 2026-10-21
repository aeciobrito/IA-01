import requests
from flask import Flask, jsonify, request

app = Flask(__name__)
OLLAMA_API_URL = "http://localhost:11434/api/generate"
MODELO_LLM = "gemma4:12b"

# ENDPOINT PÚBLICO, PARA VERIFICAR A API (HEALTHCHECK)
@app.route("/api/status", methods=["GET"])
def get_status():
    return jsonify({
        "status": "ok",
        "app": "Pizzaria Bella Tito API",
        "versao": "1.0.0",
        "owner": "Aecio Brito"
    }), 200

SYSTEM_PROMPT = """Você é o TitoBot, assistente virtual inteligente e cordial da Pizzaria Bella Tito (localizada no Senac Lapa Tito).
Siga estritamente as informações oficiais abaixo:
- Endereço: Rua Tito, 54 - Lapa, São Paulo - SP.
- Horário de Atendimento: Terça a Domingo, das 18h às 23h30. Fechado às segundas-feiras.
- Formas de Pagamento: Pix (com 5% de desconto), Cartões de Débito/Crédito e Dinheiro.
- Cardápio especial: Temos opções vegetarianas (Marguerita Especial, Quatro Queijos, Abobrinha Gratinada) e massas sem glúten (mediante reserva prévia).
- Entregas: Entregamos em um raio de 7km com taxa fixa de R$ 8,00.

Diretrizes de resposta:
1. Responda em português do Brasil com no máximo 3 frases claras e objetivas.
2. Nunca invente promoções ou dados não listados acima.
3. Se perguntarem algo fora do contexto da pizzaria, diga educadamente que só pode responder sobre a Bella Tito."""


@app.route("/api/chat", methods=["POST"])
def chat():
    dados = request.get_json()

    if not dados or "mensagem" not in dados:
        return jsonify({"erro": "O campo 'mensagem' é obrigatorio"}), 400
    
    mensagem_usuario = dados["mensagem"].strip()

    if not mensagem_usuario:
        return jsonify({"erro": "A 'mensagem' não pode ser vazia."}), 400

    prompt_completo = f"{SYSTEM_PROMPT}\n\n Pergunta do cliente: {mensagem_usuario}"

    pyaload_ollama = {
        "model": "gemma4:12b",
        "prompt": prompt_completo,
        "stream": False
    }

    response = requests.post(OLLAMA_API_URL, json=pyaload_ollama, timeout=90)
    resultado = response.json()
    return resultado.get("response", "").strip()

if __name__ == "__main__":
    print("Iniciando TitBot API em http://xxxzzz")
    app.run(host="0.0.0.0", port=5000, debug=True)