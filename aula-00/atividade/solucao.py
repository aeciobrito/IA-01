#!/usr/bin/env python3
"""
Diagnóstico e Validação do Ambiente Local de IA (Ollama + WSL2)
UC10 - Senac Lapa Tito
"""

import time
import json
import urllib.request
import urllib.error

OLLAMA_BASE_URL = "http://localhost:11434"
TEST_MODEL = "gemma4:12b"

def verificar_servico(url):
    """Verifica se a API do Ollama está ativa."""
    try:
        with urllib.request.urlopen(f"{url}/", timeout=3) as response:
            return response.status == 200
    except (urllib.error.URLError, TimeoutError):
        return False

def listar_modelos(url):
    """Consulta os modelos instalados localmente."""
    try:
        req = urllib.request.Request(f"{url}/api/tags")
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode("utf-8"))
            return [m["name"] for m in data.get("models", [])]
    except Exception as e:
        print(f"[ERRO] Falha ao listar modelos: {e}")
        return []

def testar_inferencia(url, modelo, prompt):
    """Envia uma requisição de geração de texto simples."""
    payload = {
        "model": modelo,
        "prompt": prompt,
        "stream": False
    }
    data_bytes = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        f"{url}/api/generate",
        data=data_bytes,
        headers={"Content-Type": "application/json"}
    )
    
    inicio = time.time()
    with urllib.request.urlopen(req, timeout=60) as response:
        duracao = time.time() - inicio
        resultado = json.loads(response.read().decode("utf-8"))
        return resultado.get("response", "").strip(), duracao

def main():
    print("=" * 55)
    print("   DIAGNÓSTICO DO AMBIENTE LOCAL DE IA - UC10")
    print("=" * 55)

    # 1. Teste de conectividade
    if not verificar_servico(OLLAMA_BASE_URL):
        print(f"[FALHA] Não foi possível conectar ao Ollama em {OLLAMA_BASE_URL}.")
        print("DICA: Certifique-se de executar 'ollama serve' no terminal do WSL2.")
        return

    print(f"[OK] Conexão com Ollama estabelecida em {OLLAMA_BASE_URL}")

    # 2. Listagem de modelos
    modelos = listar_modelos(OLLAMA_BASE_URL)
    if not modelos:
        print("[ALERTA] Nenhum modelo encontrado. Execute 'ollama pull llama3.2:1b'.")
        return

    print("[OK] Modelos disponíveis localmente:")
    for m in modelos:
        print(f"     - {m}")

    # Seleciona o modelo de teste disponível
    modelo_ativo = TEST_MODEL if any(TEST_MODEL in m for m in modelos) else modelos[0]
    prompt_teste = "Responda em uma única frase: o que é inteligência artificial?"

    print(f"Enviando prompt de teste para o modelo '{modelo_ativo}'...")
    try:
        resposta, tempo_gasto = testar_inferencia(OLLAMA_BASE_URL, modelo_ativo, prompt_teste)
        print(f"Resposta do modelo:\"{resposta}\"")
        print(f"Tempo de resposta: {tempo_gasto:.2f}s")
        print("[SUCESSO] Ambiente homologado e pronto para a UC10!")
    except Exception as e:
        print(f"[ERRO na inferência]: {e}")

    print("=" * 55)

if __name__ == "__main__":
    main()