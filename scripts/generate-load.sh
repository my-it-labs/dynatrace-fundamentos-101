#!/usr/bin/env bash
# =============================================================================
# generate-load.sh — Genera tráfico sintético contra demo-api (M04)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Simular usuarios reales golpeando la API durante N segundos. Objetivo:
#   poblar Dynatrace con servicios, trazas, latencia variable y errores para
#   practicar Services, Problems, distributed traces y SLOs.
#
# USO:
#   ./scripts/generate-load.sh                          # defaults
#   ./scripts/generate-load.sh http://127.0.0.1:8081 300  # URL + 300 segundos
#
# ENDPOINTS DE demo-api (ver infra/demo-web/api.py):
#   /work  → Latencia aleatoria + hit a Redis/Postgres (trabajo "sano").
#   /slow  → Respuesta deliberadamente lenta (problemas de rendimiento).
#   /fail  → Devuelve error ~10% del tiempo (dispara Problems/alertas).
#
# NOTAS:
#   - ¿Por qué "|| true" en los curl? → No queremos abortar el bucle si /fail
#     devuelve 500; el error ES el dato que queremos generar.
#   - Tras ejecutar: ir a Dynatrace → Services → demo-api y Problems.
# =============================================================================

# --- Modo estricto (pero toleramos fallos HTTP puntuales con || true abajo) ---
set -euo pipefail

# --- Parámetros con valores por defecto --------------------------------------
# $1 → URL base de la API (host del Codespace o localhost).
# $2 → Duración en segundos del bucle de carga.
BASE="${1:-http://127.0.0.1:8081}"
DURATION="${2:-120}"

echo "Generando carga sobre $BASE durante ${DURATION}s..."

# SECONDS es variable especial de Bash: segundos desde que arrancó el shell.
# Calculamos timestamp de fin para el bucle while.
end=$((SECONDS + DURATION))

# --- Bucle principal de carga ------------------------------------------------
while [[ $SECONDS -lt $end ]]; do
  # Petición "normal": genera trazas con latencia variable.
  curl -sf "$BASE/work" >/dev/null || true

  # Petición lenta: empeora percentiles p95/p99 en Dynatrace.
  curl -sf "$BASE/slow" >/dev/null || true

  # ~1 de cada 10 iteraciones provoca un fallo HTTP (error rate > 0).
  # RANDOM % 10 == 0 → distribución pseudoaleatoria sin necesidad de bc/jq.
  if (( RANDOM % 10 == 0 )); then
    curl -sf "$BASE/fail" >/dev/null || true
  fi

  # Pausa 1 s entre rondas → ~2–3 req/s sostenidas (carga moderada para trial).
  sleep 1
done

echo "Listo. Revisa Services / Problems en Dynatrace."
