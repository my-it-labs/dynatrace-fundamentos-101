#!/usr/bin/env bash
# =============================================================================
# kind-down.sh — Elimina el clúster kind del laboratorio (M05)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Destruir el clúster Kubernetes local "dynatrace-lab" y todos sus recursos
#   (pods, Operator, DynaKube, workloads de demo). Libera CPU/RAM en Codespaces.
#
# USO:
#   ./scripts/kind-down.sh
#
# NOTAS:
#   - kind delete cluster borra contenedores-nodo Docker; es irreversible.
#   - Tras esto hay que volver a ejecutar kind-up.sh + operator-up.sh + k8s-lab-up.sh.
#   - Contraste con lab-down.sh: aquí solo K8s; el stack Docker M01–M04 sigue vivo.
# =============================================================================

set -euo pipefail

CLUSTER_NAME="dynatrace-lab"

# Solo intentamos borrar si el clúster está registrado en kind.
if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
  # Elimina contenedores del control plane y workers asociados a este nombre.
  kind delete cluster --name "$CLUSTER_NAME"
  echo "Clúster $CLUSTER_NAME eliminado."
else
  echo "No hay clúster $CLUSTER_NAME."
fi
