#!/usr/bin/env bash
# =============================================================================
# kind-up.sh — Crea clúster Kubernetes local con kind (M05)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Provisionar un clúster K8s ligero dentro de Docker para el módulo M05
#   (Dynatrace Operator + inyección de OneAgent en pods). kind = "Kubernetes
#   IN Docker": nodos son contenedores, ideal para Codespaces sin VM extra.
#
# PRERREQUISITOS:
#   - kind instalado (kubectl suele venir junto en Codespaces).
#   - infra/kind/cluster-config.yaml define nº de nodos, puertos, etc.
#
# USO:
#   ./scripts/kind-up.sh
#
# IDEMPOTENCIA:
#   Si el clúster "dynatrace-lab" ya existe, no lo recrea (evita borrar estado).
#
# SIGUIENTE PASO EN EL CURSO:
#   ./scripts/operator-up.sh  → instala Dynatrace Operator en este clúster.
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Configuración declarativa del clúster (workers, port mappings, etc.).
CONFIG="$ROOT/infra/kind/cluster-config.yaml"

# Nombre fijo del clúster; debe coincidir con contexto kubectl kind-dynatrace-lab.
CLUSTER_NAME="dynatrace-lab"

# --- Comprobar que kind está en PATH -----------------------------------------
# command -v devuelve ruta del binario o nada; redirigimos stderr a /dev/null.
if ! command -v kind >/dev/null 2>&1; then
  echo "ERROR: kind no instalado. En Codespaces: ver M05 o instalar kind."
  exit 1
fi

# --- Crear clúster solo si no existe -----------------------------------------
# kind get clusters lista nombres; grep -qx exige coincidencia exacta de línea.
if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  echo "Clúster $CLUSTER_NAME ya existe."
else
  # --config aplica cluster-config.yaml (versión de K8s, nodos, extraPortMappings).
  kind create cluster --name "$CLUSTER_NAME" --config "$CONFIG"
fi

# --- Verificar conectividad con el API server --------------------------------
# El contexto kubectl por defecto de kind es kind-<nombre>.
kubectl cluster-info --context "kind-${CLUSTER_NAME}"

echo "kind listo. Instala Dynatrace Operator en M05."
