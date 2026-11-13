#!/usr/bin/env python3
"""
Exemplo do Professor - Aula 016: Guardrails de Segurança em API Flask
Domínio de Demonstração: Estacionamento Sempre Rápido (_bancoDeDados/estacionamento/estacionamento.db)
"""

import re
import sqlite3
import requests
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_PATH = "_bancoDeDados/estacionamento/estacionamento.db"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:12b"

# 1. Regras Regex de proteção anti-injeção e anti-desvio
PADROES_BLOQUEIO = [
    (r"ignore.*instru", "Tentativa de sobrescrita de instruções (Prompt Injection)."),
    (r"esque[çc]a.*regra", "Tentativa de ignorar regras do sistema."),
    (r"voc[eê]\s+agora\s+[eé]", "Tentativa de alteração de persona do assistente."),
    (r"de\s+gra[çc]a|valor\s+zero|0\s+rea", "Tentativa de adulteração de tarifa."),
    (r"dan\s+mode|jailbreak", "Tentativa de bypass de segurança (Jailbreak)."),
    (r"fale\s+sobre\s+pol[ií]tica", "Assunto fora do escopo do estacionamento.")
]

def validar_mensagem(texto):
    t = texto.lower()
    for padrao, motivo in PADROES_BLOQUEIO:
        if re.search(padrao, t):
            return False, motivo
    return True, "Mensagem segura."

@app.route("/api/status", methods=["GET"])
def status():
    return jsonify({
        "status": "ok",
        "app": "Estacionamento Sempre Rápido - API Protegida",
        "regras_guardrail": len(PADROES_BLOQUEIO)
    }), 200

@app.route("/api/chat", methods=["POST"])
def chat_seguro():
    dados = request.get_json() or {}
    mensagem = dados.get("mensagem", "").strip()

    if not mensagem:
        return jsonify({"erro": "Envie o campo 'mensagem' no corpo JSON."}), 400

    # Barreira de Entrada: executada antes de consultar o LLM
    aprovado, motivo = validar_mensagem(mensagem)
    if not aprovado:
        return jsonify({
            "bloqueado": True,
            "motivo": motivo,
            "resposta": "Desculpe, só posso responder dúvidas sobre vagas, tarifas e veículos do Estacionamento Sempre Rápido."
        }), 400

    with sqlite3.connect(DB_PATH) as conn:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*) FROM Vagas
            WHERE id NOT IN (SELECT vaga_id FROM RegistrosEstacionamento WHERE data_hora_saida IS NULL)
        """)
        vagas_livres = cur.fetchone()[0]

    prompt = f"""Você é o atendente do Estacionamento Sempre Rápido.
Responda de forma educada em até 2 frases com base nos dados oficiais:
- Vagas livres agora: {vagas_livres}
- Tolerância: 15 minutos grátis | 1ª hora: R$ 15,00 | Adicional: R$ 5,00/h | Diária: R$ 45,00.

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
        "vagas_livres": vagas_livres,
        "resposta": resposta_texto
    }), 200

if __name__ == "__main__":
    print(f"Iniciando API Protegida com Guardrails em http://localhost:5000 (Modelo: {MODELO})")
    app.run(host="0.0.0.0", port=5000, debug=True)
