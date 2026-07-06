#!/usr/bin/env bash
# =============================================================================
# oneagent-down.sh — Detiene y elimina el contenedor OneAgent (M03–M04)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Apagar el agente full-stack desplegado con oneagent-up.sh. El host deja de
#   reportar a Dynatrace; útil para demostrar "antes/después" o liberar recursos.
#
# USO:
#   ./scripts/oneagent-down.sh
#
# NOTA:
#   No borra el volumen dynatrace_oneagent_storage (cache del instalador).
#   Solo elimina el contenedor dynatrace-oneagent.
# =============================================================================

set -euo pipefail

CONTAINER_NAME="dynatrace-oneagent"

# Si existe (corriendo o parado), forzar eliminación.
# docker rm -f → stop + remove en un solo paso.
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  docker rm -f "$CONTAINER_NAME"
  echo "OneAgent detenido y contenedor eliminado."
else
  echo "No hay contenedor $CONTAINER_NAME."
fi
