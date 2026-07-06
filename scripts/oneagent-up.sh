#!/usr/bin/env bash
# =============================================================================
# oneagent-up.sh — Despliega OneAgent como contenedor Docker full-stack (M03–M04)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Instalar el agente Dynatrace en el *host* del Codespace (no dentro de cada
#   contenedor de app). El contenedor oficial dynatrace/oneagent descarga el
#   instalador desde el tenant usando PaaS token y monitoriza procesos/containers
#   del host gracias a --privileged, --pid=host y --network=host.
#
# DOCUMENTACIÓN OFICIAL:
#   https://docs.dynatrace.com/docs/ingest-from/setup-on-container-platforms/docker/set-up-dynatrace-oneagent-as-docker-container
#
# PRERREQUISITOS:
#   - infra/.env con ONEAGENT_PAAS_TOKEN y DYNATRACE_ENVIRONMENT_URL (o URL del
#     instalador explícita).
#   - Stack Docker del lab levantado (lab-up.sh) para tener algo que observar.
#
# USO:
#   ./scripts/oneagent-up.sh
#
# NOTAS (flags de docker run):
#   --privileged     → Acceso ampliado al host (requerido para full-stack monitoring).
#   --pid=host       → Ve todos los procesos del host, no solo los del contenedor.
#   --network=host   → Comparte stack de red del host (tráfico real de apps).
#   -v /:/mnt/root   → Monta filesystem raíz para deep monitoring / discovery.
#   ONEAGENT_ENABLE_VOLUME_STORAGE → Persiste binarios entre reinicios del contenedor.
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/infra/.env"
CONTAINER_NAME="dynatrace-oneagent"

# --- Validar que existe configuración local ------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Falta $ENV_FILE — copia .env.example y rellena tokens."
  exit 1
fi

# --- Cargar variables de entorno desde .env ----------------------------------
# set -a  → exporta automáticamente todas las variables que se definan después.
# source  → lee ONEAGENT_PAAS_TOKEN, DYNATRACE_ENVIRONMENT_URL, etc.
# set +a  → desactiva auto-export.
# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

# --- Comprobar token PaaS (permiso para descargar el instalador OneAgent) ------
if [[ -z "${ONEAGENT_PAAS_TOKEN:-}" ]]; then
  echo "ERROR: ONEAGENT_PAAS_TOKEN vacío en infra/.env"
  exit 1
fi

# --- Construir URL del instalador si no viene explícita en .env ----------------
# Dynatrace expone un endpoint REST que devuelve el script/binario más reciente
# para la arquitectura indicada (x86, flavor default).
if [[ -z "${ONEAGENT_INSTALLER_SCRIPT_URL:-}" ]]; then
  if [[ -z "${DYNATRACE_ENVIRONMENT_URL:-}" ]]; then
    echo "ERROR: Define ONEAGENT_INSTALLER_SCRIPT_URL o DYNATRACE_ENVIRONMENT_URL"
    exit 1
  fi
  # ${VAR%/} elimina barra final duplicada al concatenar /api/v1/...
  base="${DYNATRACE_ENVIRONMENT_URL%/}"
  ONEAGENT_INSTALLER_SCRIPT_URL="${base}/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default"
fi

# --- Idempotencia: no duplicar contenedor OneAgent -----------------------------
# docker ps -a → incluye contenedores parados.
# grep -qx → coincidencia exacta del nombre (evita falsos positivos en nombres parecidos).
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
    echo "OneAgent ya está en ejecución ($CONTAINER_NAME)."
    exit 0
  fi
  # Contenedor existe pero está Exited → lo removemos antes de recrear.
  echo "Eliminando contenedor OneAgent previo detenido..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

echo "Desplegando OneAgent (puede tardar 1–3 min en la primera descarga)..."

# En GitHub Codespaces el daemon Docker suele ser DinD: el volumen nombrado del
# instalador falla con "volume host path ... does not exist on the host".
# Ver labs/TROUBLESHOOTING.md — OneAgent (M03).
USE_VOLUME_STORAGE="${ONEAGENT_ENABLE_VOLUME_STORAGE:-auto}"
if [[ "$USE_VOLUME_STORAGE" == "auto" ]]; then
  if [[ -n "${CODESPACES:-}" || -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
    USE_VOLUME_STORAGE=false
    echo "Codespace detectado: almacenamiento persistente OneAgent desactivado."
  else
    USE_VOLUME_STORAGE=true
  fi
fi

DOCKER_VOLUME_ARGS=()
DOCKER_ENV_VOLUME=(-e "ONEAGENT_ENABLE_VOLUME_STORAGE=$USE_VOLUME_STORAGE")
if [[ "$USE_VOLUME_STORAGE" == "true" ]]; then
  docker volume create dynatrace_oneagent_storage >/dev/null 2>&1 || true
  DOCKER_VOLUME_ARGS=(-v dynatrace_oneagent_storage:/mnt/volume_storage_mount)
fi

# --- Arranque del contenedor OneAgent oficial ----------------------------------
docker run -d \
  --name "$CONTAINER_NAME" \
  --restart=unless-stopped \
  --privileged \
  --pid=host \
  --network=host \
  -v /:/mnt/root \
  "${DOCKER_VOLUME_ARGS[@]}" \
  "${DOCKER_ENV_VOLUME[@]}" \
  -e ONEAGENT_INSTALLER_SCRIPT_URL="$ONEAGENT_INSTALLER_SCRIPT_URL" \
  -e ONEAGENT_INSTALLER_DOWNLOAD_TOKEN="$ONEAGENT_PAAS_TOKEN" \
  dynatrace/oneagent

echo ""
echo "OneAgent arrancado. Comprueba logs:"
echo "  docker logs -f $CONTAINER_NAME"
echo ""
echo "En Dynatrace (2–5 min): Deployments → OneAgents → host del Codespace."
