# Atividade Prática 005: Consulta Inteligente ao Estacionamento com Text-to-SQL

## 1. Contexto de Negócio
O supervisor do **Estacionamento Sempre Rápido** precisa saber a qualquer momento quantos carros estão no pátio ou quais vagas estão ocupadas sem precisar abrir a tela do sistema legado em C#.

## 2. Requisitos da Atividade
1. Criar o script `app_estacionamento_sql.py`.
2. Conectar diretamente ao banco SQLite `_bancoDeDados/estacionamento/estacionamento.db`.
3. Injetar o esquema da tabela `Veiculos` e `RegistrosEstacionamento` no prompt do Ollama (`gemma4:12b`).
4. Executar a consulta gerada no SQLite e exibir o resultado formatado.
5. Regra de negócio: Veículos com `data_hora_saida IS NULL` estão atualmente no pátio.

## Solução Terminal
A solução a seguir é executada via terminal de comando, não é uma solução web. Com base na solução desenvolvida em sala de aula, implemente a versão web da solução:

```python
#!/usr/bin/env python3
"""
Solução da Atividade - Aula 005: Text-to-SQL no Estacionamento
Utiliza o banco oficial: _bancoDeDados/estacionamento/estacionamento.db
"""

import sqlite3
import requests

# Referência direta ao banco SQLite
DB_PATH = "_bancoDeDados/estacionamento/estacionamento.db"
OLLAMA_URL = "http://localhost:11434/api/generate"
MODELO = "gemma4:12b"

SCHEMA = """
Tabelas disponíveis:
1. Veiculos: id, placa, modelo, cor
2. RegistrosEstacionamento: id, veiculo_id, vaga_id, data_hora_entrada, data_hora_saida
Regra: Se data_hora_saida IS NULL, o veículo ainda está estacionado.
"""

def gerar_sql(pergunta):
    prompt = f"""Você é um assistente de banco de dados SQLite.
Gere APENAS a consulta SELECT correspondente à pergunta do usuário, em uma única linha, sem crases ou markdown.

{SCHEMA}

Pergunta: {pergunta}
SQL:"""

    try:
        resp = requests.post(OLLAMA_URL, json={
            "model": MODELO,
            "prompt": prompt,
            "stream": False
        }, timeout=10)
        sql = resp.json().get("response", "").strip()
        return sql.replace("```sql", "").replace("```", "").strip()
    except Exception:
        # Fallback offline
        return "SELECT v.placa, v.modelo FROM Veiculos v JOIN RegistrosEstacionamento r ON v.id = r.veiculo_id WHERE r.data_hora_saida IS NULL"

def consultar_estacionamento(sql):
    with sqlite3.connect(DB_PATH) as conn:
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(sql)
        return [dict(row) for row in cur.fetchall()]

def executar_pergunta(pergunta):
    print(f"\n>> Pergunta: {pergunta}")
    sql = gerar_sql(pergunta)
    print(f"   SQL: {sql}")
    try:
        linhas = consultar_estacionamento(sql)
        print(f"   Resultados ({len(linhas)}):")
        for linha in linhas:
            print(f"    * {linha}")
    except Exception as e:
        print(f"   Erro ao executar SQL: {e}")

if __name__ == "__main__":
    print("=" * 60)
    print("CONSULTA INTELIGENTE AO ESTACIONAMENTO (TEXT-TO-SQL)")
    print("=" * 60)
    executar_pergunta("Quais veículos estão estacionados no pátio agora?")
```