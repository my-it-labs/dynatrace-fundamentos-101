"""API mínima de lab: health + trabajo simulado para generar trazas y métricas."""
from __future__ import annotations

import os
import random
import time

import redis
from flask import Flask, jsonify
import psycopg2  # módulo, no la función: así la instrumentación OTel puede parchear connect

app = Flask(__name__)


def _redis_client() -> redis.Redis:
    return redis.from_url(os.environ.get("REDIS_URL", "redis://redis:6379/0"))


@app.get("/health")
def health():
    return jsonify(status="ok", service="demo-api")


@app.get("/work")
def work():
    delay = random.uniform(0.05, 0.4)
    time.sleep(delay)

    hits = _redis_client().incr("lab:hits")

    db_url = os.environ.get("DATABASE_URL", "postgres://lab:lab@postgres:5432/lab")
    with psycopg2.connect(db_url) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()

    return jsonify(hits=int(hits), delay_ms=round(delay * 1000, 1))


@app.get("/slow")
def slow():
    """Endpoint para inducir latencia en M04 (Problems / Davis)."""
    delay = float(os.environ.get("LAB_SLOW_SECONDS", "3"))
    time.sleep(delay)
    return jsonify(status="slow", delay_seconds=delay)


@app.get("/fail")
def fail():
    """Endpoint para inducir errores HTTP en M04."""
    return jsonify(error="simulated failure"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
