import sqlite3
import requests
from flask import Flask, request

app = Flask(__name__)

DB_PATH = "_bancoDeDados\pizzaria\pizzaria.db"
OLLAMA_URL = "http://localhost:11434/api/generate"

@app.route("/api/ola", methods=['POST'])
def rota_ola():
    dados = request.get_json()
    nome = dados.get("nome", "")
    local = dados.get("endereco", "")
    return f"Olá {nome}, vc mora em {local}"

@app.route("/api/chat",  methods=['POST']) # EXERCÍCIO 1
def rota_chat():
    jsonRecebido = request.get_json()
    nomeRecebido = jsonRecebido.get("nome", "")
    promptRecebido = jsonRecebido.get("prompt", "")
    return f"Olá, {nomeRecebido}. O seu PROMPT foi: {promptRecebido}"

@app.route("/api/consulta") # EXEMPLO
def rota_consulta():
    resultado = executar_consulta("SELECT * FROM FormasPagamento")
    return resultado

@app.route("/api/consulta_usuario", methods=['POST']) # EXERCÍCIO 2
def rota_consulta_usuario():
    dados = request.get_json()
    comando = dados.get("query", "")
    resultado = executar_consulta(comando)
    return resultado

@app.route("/api/pedidos")
def rota_pedidos():
    consulta = "SELECT * FROM Pedidos"
    return executar_consulta(consulta)

@app.route("/api/ollama", methods=['POST']) # EXERCÍCIO 3
def rota_ollama():
    dados = request.get_json()
    promptDoUsuario = dados.get("prompt", "")

    respostaDoOllama = requests.post(
        "http://localhost:11434/api/generate",
        json={
            "model": "gemma4:e2b",
            "prompt": promptDoUsuario,
            "stream": False
        },
        timeout=120
        )

    respostaParaUsuario = respostaDoOllama.json().get("response")
    return f"O usuário enviou: {promptDoUsuario}, resposta do Ollama: {respostaParaUsuario}"

def executar_consulta(sql: str):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(sql)
        return [dict(r) for r in cur.fetchall()]

if (__name__) == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)