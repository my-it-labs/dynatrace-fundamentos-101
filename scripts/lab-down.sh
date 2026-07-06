#!/usr/bin/env bash
# =============================================================================
# lab-down.sh — Detiene y limpia el stack Docker del laboratorio (M01–M04)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Apagar ordenadamente todos los contenedores del lab y liberar volúmenes
#   persistentes (datos de PostgreSQL, Redis, etc.). Útil al final de la sesión
#   o antes de un reset limpio.
#
# USO:
#   ./scripts/lab-down.sh
#
# ATENCIÓN DIDÁCTICA:
#   La flag -v elimina volúmenes nombrados/anónimos asociados al compose.
#   Los datos de la base de datos del lab se pierden; en producción esto sería
#   una decisión con implicaciones — aquí es intencional para entornos efímeros.
# =============================================================================

set -euo pipefail

# Raíz del repo (misma técnica que lab-up.sh).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/infra"

# docker compose down:
#   - Detiene y elimina contenedores creados por este compose project.
#   -v → Borra también los volúmenes (reset completo del estado del lab).
docker compose down -v

echo "Stack Docker del lab detenido."
