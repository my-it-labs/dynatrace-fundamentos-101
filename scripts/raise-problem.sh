#!/usr/bin/env bash
# =============================================================================
# raise-problem.sh — Abre un Problem en Dynatrace enviando un ERROR_EVENT (M04-02, plan B)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   En un tenant recién creado Davis aún no tiene baseline de demo-api y puede
#   no abrir ningún problem aunque /fail devuelva 500. Este script envía un
#   evento de error por la Events API v2 sobre el host del Codespace: Dynatrace
#   abre un Problem en ~30 s y puedes practicar Impact / Root cause / cierre.
#
# REQUISITOS:
#   infra/.env con DYNATRACE_ENVIRONMENT_URL y DYNATRACE_EVENTS_TOKEN
#   (token con scope events.ingest — ver M04-02, plan B).
#
# USO:
#   ./scripts/raise-problem.sh            # título por defecto
#   ./scripts/raise-problem.sh "Mi título"
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/infra/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Falta $ENV_FILE — copia infra/.env.example y rellena tokens."
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

if [[ -z "${DYNATRACE_EVENTS_TOKEN:-}" ]]; then
  echo "ERROR: DYNATRACE_EVENTS_TOKEN vacío. Crea un token con scope events.ingest (M04-02, plan B)."
  exit 1
fi

BASE="${DYNATRACE_ENVIRONMENT_URL%/}"
TITLE="${1:-Lab M04-02: demo-api devuelve HTTP 500}"

# entitySelector: el host del Codespace (nombre codespaces-…).
BODY=$(cat <<EOF
{
  "eventType": "ERROR_EVENT",
  "title": "$TITLE",
  "entitySelector": "type(HOST),entityName.startsWith(\"codespaces-\")",
  "properties": { "curso": "dynatrace-fundamentos-101", "endpoint": "/fail" }
}
EOF
)

echo "Enviando ERROR_EVENT a $BASE ..."
HTTP=$(curl -sS -o /tmp/raise-problem.out -w '%{http_code}' -X POST \
  "$BASE/api/v2/events/ingest" \
  -H "Authorization: Api-Token $DYNATRACE_EVENTS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "$BODY")

cat /tmp/raise-problem.out; echo
if [[ "$HTTP" != "201" ]]; then
  echo "ERROR: HTTP $HTTP (revisa URL y scope events.ingest del token)."
  exit 1
fi
echo "OK. En ~30 s verás el problem en Dynatrace → Problems."
