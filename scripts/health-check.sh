#!/usr/bin/env bash
# =============================================================================
# health-check.sh — Diagnóstico rápido del lab Docker + conectividad HTTP
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Script de "smoke test" que tú (o lab-up.sh) ejecuta para confirmar:
#     1) Que infra/.env existe y tiene el tenant Dynatrace configurado.
#     2) Que los contenedores Docker están UP.
#     3) Que las apps responden en localhost.
#
# USO:
#   ./scripts/health-check.sh
#
# NOTAS:
#   - ¿Por qué comprobamos el tenant aunque este script no llame a la API DT?
#     → Feedback temprano: si falta .env, OneAgent/Operator también fallarán.
#   - curl -sf: -s silencioso, -f falla en HTTP 4xx/5xx (no "éxito falso").
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/infra"

echo "== Dynatrace lab health check =="

# --- Comprobar configuración Dynatrace en .env -------------------------------
if [[ ! -f .env ]]; then
  # Sin .env el lab puede arrancar, pero no habrá ingest ni despliegue de agentes.
  echo "WARN: infra/.env no existe. Copia .env.example y rellena tokens."
else
  # Cargar variables del .env en el shell actual (DYNATRACE_ENVIRONMENT_URL, etc.).
  # shellcheck disable=SC1091  → SC1091 avisa de source de ruta relativa; aquí es OK.
  source .env

  # ${VAR:-} → Si VAR no existe, expande a cadena vacía (compatible con set -u).
  if [[ -z "${DYNATRACE_ENVIRONMENT_URL:-}" ]]; then
    echo "WARN: DYNATRACE_ENVIRONMENT_URL vacío en .env"
  else
    # Mostramos el tenant para que tú verifique que apunta al trial correcto.
    echo "OK: tenant configurado (${DYNATRACE_ENVIRONMENT_URL})"
  fi
fi

# --- Estado de contenedores según Docker Compose -----------------------------
# Lista nombre, estado (Up/Exit), puertos mapeados. Diagnóstico visual rápido.
docker compose ps

echo ""
echo "HTTP checks:"

# demo-web: frontend estático/simple en puerto 8080 del host.
# >/dev/null descarta el body; solo nos importa el código HTTP.
# && / || → Mensaje OK o FAIL según exit code de curl.
curl -sf "http://127.0.0.1:8080/" >/dev/null && echo "  demo-web :8080 OK" || echo "  demo-web :8080 FAIL"

# demo-api: endpoint /health diseñado para probes y comprobaciones de liveness.
curl -sf "http://127.0.0.1:8081/health" >/dev/null && echo "  demo-api :8081 OK" || echo "  demo-api :8081 FAIL"

echo ""
echo "Listo."
