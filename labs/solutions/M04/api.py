"""API mínima de lab: health + trabajo simulado para generar trazas y métricas."""
from __future__ import annotations

import logging
import os
import random
import time

import redis
from flask import Flask, jsonify
import psycopg2  # módulo, no la función: así la instrumentación OTel puede parchear connect

app = Flask(__name__)

_log = logging.getLogger(__name__)
_work_counter = None


def _configure_otel() -> None:
    global _work_counter

    base = os.environ.get("DYNATRACE_ENVIRONMENT_URL", "").strip().rstrip("/")
    token = os.environ.get("DYNATRACE_INGEST_TOKEN", "").strip()
    if not base or not token:
        return

    from opentelemetry import metrics, trace
    from opentelemetry._logs import set_logger_provider
    from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter
    from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
    from opentelemetry.instrumentation.redis import RedisInstrumentor
    from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
    from opentelemetry.sdk._logs.export import SimpleLogRecordProcessor
    from opentelemetry.sdk.metrics import MeterProvider
    from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import SimpleSpanProcessor

    headers = {"Authorization": f"Api-Token {token}"}
    resource = Resource.create({"service.name": "demo-api"})

    trace_exporter = OTLPSpanExporter(
        endpoint=f"{base}/api/v2/otlp/v1/traces",
        headers=headers,
    )
    trace_provider = TracerProvider(resource=resource)
    trace_provider.add_span_processor(SimpleSpanProcessor(trace_exporter))
    trace.set_tracer_provider(trace_provider)

    metric_reader = PeriodicExportingMetricReader(
        OTLPMetricExporter(
            endpoint=f"{base}/api/v2/otlp/v1/metrics",
            headers=headers,
        ),
        export_interval_millis=5000,
    )
    metrics.set_meter_provider(MeterProvider(resource=resource, metric_readers=[metric_reader]))
    _work_counter = metrics.get_meter("demo-api").create_counter(
        "demo_api.work.requests",
        description="Peticiones completadas en GET /work",
    )

    log_exporter = OTLPLogExporter(
        endpoint=f"{base}/api/v2/otlp/v1/logs",
        headers=headers,
    )
    logger_provider = LoggerProvider(resource=resource)
    logger_provider.add_log_record_processor(SimpleLogRecordProcessor(log_exporter))
    set_logger_provider(logger_provider)

    logging.getLogger().addHandler(LoggingHandler(level=logging.INFO, logger_provider=logger_provider))
    logging.getLogger().setLevel(logging.INFO)

    FlaskInstrumentor().instrument_app(app)
    Psycopg2Instrumentor().instrument()
    RedisInstrumentor().instrument()


_configure_otel()


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

    if _work_counter is not None:
        _work_counter.add(1)

    _log.info("GET /work ok hits=%s delay_ms=%s", hits, round(delay * 1000, 1))
    return jsonify(hits=int(hits), delay_ms=round(delay * 1000, 1))


@app.get("/slow")
def slow():
    """Endpoint para inducir latencia en M04 (Problems / Davis)."""
    delay = float(os.environ.get("LAB_SLOW_SECONDS", "3"))
    time.sleep(delay)
    _log.warning("GET /slow delay_seconds=%s", delay)
    return jsonify(status="slow", delay_seconds=delay)


@app.get("/fail")
def fail():
    """Endpoint para inducir errores HTTP en M04."""
    _log.error("GET /fail simulated failure")
    return jsonify(error="simulated failure"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8081)
