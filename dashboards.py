import re
import requests
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:e2b"

# Interface web com painel lateral (prompt) e iframe (dashboard)
HTML_INTERFACE = """
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Gerador de Dashboards - Ollama</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: system-ui, sans-serif; }
        body { display: flex; height: 100vh; background: #0f172a; color: #f8fafc; }
        
        /* Painel Esquerdo */
        .sidebar {
            width: 340px;
            padding: 20px;
            background: #1e293b;
            border-right: 1px solid #334155;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        h2 { font-size: 1.1rem; color: #38bdf8; }
        textarea {
            width: 100%;
            height: 180px;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #475569;
            background: #0f172a;
            color: #fff;
            resize: none;
            font-size: 0.95rem;
        }
        button {
            padding: 12px;
            border: none;
            border-radius: 6px;
            background: #0284c7;
            color: white;
            font-weight: bold;
            cursor: pointer;
            transition: 0.2s;
        }
        button:hover { background: #0369a1; }
        button:disabled { background: #475569; cursor: wait; }
        #status { font-size: 0.85rem; color: #94a3b8; }

        /* Área do Iframe (Direita) */
        .preview { flex: 1; background: #ffffff; }
        iframe { width: 100%; height: 100%; border: none; }
    </style>
</head>
<body>

    <div class="sidebar">
        <h2>Gerador de Dashboard</h2>
        <textarea id="prompt" placeholder="Ex: Crie um dashboard de vendas de uma pizzaria com gráfico de barras para sabores mais vendidos e pizza para formas de pagamento."></textarea>
        <button id="btnGerar" onclick="gerarDashboard()">Gerar Dashboard</button>
        <div id="status">Pronto para gerar.</div>
    </div>

    <div class="preview">
        <iframe id="visor" srcdoc="<h3 style='font-family:sans-serif;color:#64748b;padding:40px;'>O dashboard aparecerá aqui...</h3>"></iframe>
    </div>

    <script>
        async function gerarDashboard() {
            const prompt = document.getElementById("prompt").value.trim();
            const btn = document.getElementById("btnGerar");
            const status = document.getElementById("status");
            const visor = document.getElementById("visor");

            if (!prompt) return;

            btn.disabled = true;
            status.innerText = "Gerando código com Ollama...";

            try {
                const resp = await fetch("/api/gerar", {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ prompt })
                });
                const dados = await resp.json();

                if (dados.html) {
                    visor.srcdoc = dados.html; // Injeta o HTML direto no iframe
                    status.innerText = "Dashboard atualizado!";
                } else {
                    status.innerText = "Erro: " + (dados.erro || "Falha na resposta");
                }
            } catch (e) {
                status.innerText = "Erro de conexão com o servidor.";
            } finally {
                btn.disabled = false;
            }
        }
    </script>
</body>
</html>
"""

@app.route("/")
def index():
    return render_template_string(HTML_INTERFACE)

@app.route("/api/gerar", methods=["POST"])
def rota_gerar():
    dados = request.get_json()
    prompt_usuario = dados.get("prompt", "")

    # Instrução para forçar o modelo a devolver apenas código válido com Chart.js
    prompt_sistema = f"""
    Você é um desenvolvedor frontend especialista em dashboards.
    Crie um documento HTML5 completo, moderno e responsivo (com CSS interno e dados fictícios realistas se não forem informados) para atender ao pedido abaixo.
    
    REGRAS OBRIGATÓRIAS:
    1. Importe o Chart.js via CDN: <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    2. Use CSS limpo (Grid ou Flexbox) para organizar os cards e gráficos.
    3. Retorne APENAS o código HTML completo (começando com <!DOCTYPE html> e terminando com </html>). Não escreva explicações antes ou depois.

    Pedido do usuário: {prompt_usuario}
    """

    try:
        resposta = requests.post(
            OLLAMA_URL,
            json={
                "model": MODELO,
                "prompt": prompt_sistema,
                "stream": False
            },
            timeout=120
        )
        texto_bruto = resposta.json().get("response", "")
        
        # Remove marcadores ```html e ``` caso o modelo insira
        html_limpo = re.sub(r"^```html\s*|```$", "", texto_bruto.strip(), flags=re.MULTILINE)
        
        return jsonify({"html": html_limpo})
    
    except Exception as e:
        return jsonify({"erro": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)