#!/usr/bin/env python3
"""
Solução da Atividade - Aula 016: Guardrails Web da Pizzaria Bella Tito
Protege o acesso ao Ollama e consulta cardápio real em _bancoDeDados/pizzaria/pizzaria.db
"""

import re
import sqlite3
import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_PATH = "_bancoDeDados/pizzaria/pizzaria.db"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:12b"

REGRAS_BLOQUEIO = [
    (r"ignore\s+(todas\s+as\s+)?instru", "Tentativa de sobrescrita de instruções"),
    (r"esque[çc]a\s+as\s+regras", "Tentativa de reset de persona"),
    (r"venda\s+por\s+0|de\s+gra[çc]a", "Tentativa de adulteração de preço"),
    (r"palavr[aã]o|idiota|burro", "Linguagem imprópria detectada"),
    (r"pol[ií]tica|hackear", "Assunto fora de escopo do atendimento")
]

def filtrar_mensagem(texto):
    msg = texto.lower()
    for padrao, motivo in REGRAS_BLOQUEIO:
        if re.search(padrao, msg):
            return False, motivo
    return True, "Aprovado"

@app.route("/api/status", methods=["GET"])
def status():
    return jsonify({
        "status": "ok",
        "app": "Pizzaria Bella Tito - API com Guardrails",
        "regras_ativas": len(REGRAS_BLOQUEIO)
    }), 200

@app.route("/api/chat", methods=["POST"])
def chat_pizzaria():
    dados = request.get_json() or {}
    mensagem = dados.get("mensagem", "").strip()

    if not mensagem:
        return jsonify({"erro": "Envie o campo 'mensagem' no corpo JSON."}), 400

    valido, motivo = filtrar_mensagem(mensagem)
    if not valido:
        return jsonify({
            "bloqueado": True,
            "motivo": motivo,
            "resposta": f"[GUARDRAIL ATIVADO]: Mensagem rejeitada ({motivo}). Consulte apenas itens do nosso cardápio."
        }), 400

    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        cur.execute("SELECT sabor, valor FROM Pizzas WHERE disponivel = 1 ORDER BY sabor")
        cardapio = ", ".join([f"{sabor} (R$ {valor:.2f})" for sabor, valor in cur.fetchall()])

    prompt = f"""Você é o atendente da Pizzaria Bella Tito.
Responda em até 2 frases em português usando apenas o cardápio oficial abaixo:
Cardápio disponível: {cardapio}.

Pergunta do cliente: {mensagem}
Resposta:"""

    try:
        resp = requests.post(
            OLLAMA_URL,
            json={"model": MODELO, "prompt": prompt, "stream": False, "options": {"temperature": 0.2}},
            timeout=60
        )
        if resp.status_code != 200:
            return jsonify({"erro": "Falha no Ollama", "detalhes": resp.text}), 502

        resposta_texto = resp.json().get("response", "").strip()
    except requests.exceptions.RequestException as e:
        return jsonify({"erro": f"Erro de conexão com Ollama: {str(e)}"}), 503

    return jsonify({
        "bloqueado": False,
        "motivo": motivo,
        "resposta": resposta_texto
    }), 200

if __name__ == "__main__":
    print(f"Iniciando API Protegida Pizzaria Bella Tito em http://localhost:5000 (Modelo: {MODELO})")
    app.run(host="0.0.0.0", port=5000, debug=True)

