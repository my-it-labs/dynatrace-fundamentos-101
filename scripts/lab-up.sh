#!/usr/bin/env bash
# =============================================================================
# lab-up.sh — Arranca el stack Docker del laboratorio (M01–M04)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Punto de entrada principal dtú para levantar la infraestructura local
#   del curso: demo-web, demo-api, PostgreSQL y Redis. Tras el arranque,
#   ejecuta un health-check automático para confirmar que todo responde.
#
# PRERREQUISITOS:
#   - Docker y Docker Compose instalados (Codespaces los trae por defecto).
#   - Archivo infra/.env con tokens Dynatrace (se crea desde .env.example si
#     no existe, pero habrá que editarlo manualmente).
#
# USO:
#   ./scripts/lab-up.sh
#
# RELACIÓN CON DYNATRACE:
#   Los contenedores levantados aquí son los que OneAgent monitorizará una vez
#   desplegado con oneagent-up.sh. Sin este stack no hay tráfico ni métricas
#   que observar en la UI.
# =============================================================================

# --- Modo estricto de Bash ---------------------------------------------------
# set -e  → Si cualquier comando falla (exit != 0), el script se detiene.
#           Evita continuar con un stack a medias sin que tú se dé cuenta.
# set -u  → Tratar variables no definidas como error (evita typos silenciosos).
# set -o pipefail → En tuberías (cmd1 | cmd2), falla si cmd1 falla, no solo cmd2.
set -euo pipefail

# --- Resolver ruta raíz del repositorio --------------------------------------
# $(dirname "$0")     → Directorio donde vive este script (scripts/).
# cd ... && pwd       → Cambia ahí y devuelve la ruta absoluta.
# /..                 → Sube un nivel → raíz del repo dynatrace-fundamentos-101.
# Guardamos en ROOT para poder invocar otros scripts con rutas fiables.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Entrar al directorio de infraestructura ---------------------------------
# docker-compose.yml y .env viven en infra/; compose busca el YAML en el cwd.
cd "$ROOT/infra"

# --- Bootstrap del archivo de configuración ----------------------------------
# Si tú clona el repo por primera vez, infra/.env no existe todavía.
# Copiamos la plantilla .env.example para que sepa qué variables rellenar
# (DYNATRACE_ENVIRONMENT_URL, tokens API, etc.).
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Creado infra/.env desde .env.example — edítalo con tu tenant y tokens."
fi

# --- Levantar el stack Docker ------------------------------------------------
# docker compose up:
#   -d          → detached (segundo plano); el terminal queda libre.
#   --build     → Reconstruye imágenes si el Dockerfile cambió (útil tras git pull).
# Servicios típicos definidos en infra/docker-compose.yml:
#   demo-web (8080), demo-api (8081), postgres, redis.
docker compose up -d --build

# --- Verificación post-arranque ------------------------------------------------
# Delegamos en health-check.sh: comprueba tenant en .env, estado de contenedores
# y que demo-web (:8080) y demo-api (:8081/health) respondan por HTTP.
"$ROOT/scripts/health-check.sh"
