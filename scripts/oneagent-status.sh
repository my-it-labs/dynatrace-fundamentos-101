#!/usr/bin/env bash
# =============================================================================
# oneagent-status.sh — Estado y logs recientes del contenedor OneAgent
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Herramienta de troubleshooting cuando OneAgent no aparece en la UI de
#   Dynatrace o tarda más de lo esperado. Muestra si el contenedor está Up y
#   las últimas líneas del log (descarga instalador, conexión al tenant, errores
#   de token, etc.).
#
# USO:
#   ./scripts/oneagent-status.sh
#
# NOTAS:
#   - ¿Qué buscar en los logs? → "Connected", errores 401 (token), download OK.
#   - Latencia normal hasta ver el host en Deployments → OneAgents: 2–5 minutos.
# =============================================================================

set -euo pipefail

CONTAINER_NAME="dynatrace-oneagent"

echo "== OneAgent status =="

if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  # Tabla con STATE (Up/Exited), STATUS (healthy), PORTS.
  docker ps -a --filter "name=$CONTAINER_NAME"

  echo ""
  echo "Últimas líneas del log:"
  # --tail 20 → solo lo reciente; 2>&1 mezcla stderr (donde suelen ir errores).
  # "|| true" → si el contenedor está corrupto, no abortar el script entero.
  docker logs --tail 20 "$CONTAINER_NAME" 2>&1 || true
else
  echo "OneAgent no desplegado. Ejecuta: ./scripts/oneagent-up.sh"
fi
