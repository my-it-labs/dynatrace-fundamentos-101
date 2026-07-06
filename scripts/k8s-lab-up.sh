#!/usr/bin/env bash
# =============================================================================
# k8s-lab-up.sh — Despliega workloads de demo en el clúster kind (M05)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Tras tener kind + Operator, aplicar manifiestos YAML con una app de lab
#   (deployment lab-web, Service, etc.) en namespace dynatrace-lab. Esas pods
#   serán instrumentadas automáticamente por OneAgent vía Operator.
#
# PRERREQUISITOS:
#   - ./scripts/kind-up.sh ejecutado (contexto kind-dynatrace-lab disponible).
#   - Recomendable: ./scripts/operator-up.sh para que Dynatrace monitorice pods.
#
# USO:
#   ./scripts/k8s-lab-up.sh
#
# NOTAS:
#   - rollout status → espera a que el Deployment alcance mínimo de réplicas listas.
#   - Comparar con lab-up.sh: mismo concepto de demo-web pero empaquetado en K8s.
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Contexto kubectl que kind crea automáticamente: kind-<nombre-clúster>.
CTX="kind-dynatrace-lab"

# --- Asegurar que el clúster existe y kubectl apunta a él --------------------
# use-context falla si el contexto no está en kubeconfig → mensaje guiado.
kubectl config use-context "$CTX" 2>/dev/null || {
  echo "ERROR: clúster kind-dynatrace-lab no existe. Ejecuta ./scripts/kind-up.sh"
  exit 1
}

# --- Aplicar manifiestos del lab ---------------------------------------------
# infra/k8s/demo-workload.yaml define Namespace, Deployment, Service, etc.
# kubectl apply es idempotente: re-ejecutar actualiza sin duplicar recursos.
kubectl apply -f "$ROOT/infra/k8s/demo-workload.yaml"

# --- Esperar despliegue estable ------------------------------------------------
# -n dynatrace-lab        → namespace definido en el YAML.
# rollout status          → bloquea hasta Ready o timeout.
# --timeout=120s          → evita colgar el terminal indefinidamente.
kubectl -n dynatrace-lab rollout status deployment/lab-web --timeout=120s

# --- Resumen visual de recursos creados --------------------------------------
kubectl -n dynatrace-lab get pods,svc

echo "Workloads de lab desplegados en namespace dynatrace-lab."
