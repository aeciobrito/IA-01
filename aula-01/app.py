import sqlite3
from flask import Flask, jsonify

app = Flask(__name__)
DB_NAME = "aula-01/pizzaria.db"

def dict_factory(cursor, linha):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = linha[idx]
    return d

# ENDPOINT PARA MOSTRAR TODAS AS PIZZAS
@app.route("/api/pizzas", methods=["GET"])
def get_pizzas():
    with sqlite3.connect(DB_NAME) as conn:
        conn.row_factory = dict_factory
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Pizzas")
        pizzas = cursor.fetchall()
        return jsonify(pizzas), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0",port=5001, debug=True)