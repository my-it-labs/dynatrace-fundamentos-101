#!/usr/bin/env bash
# =============================================================================
# operator-up.sh — Instala Dynatrace Operator + DynaKube en kind (M05)
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Automatizar el flujo de M05: desplegar el Operator de Dynatrace en K8s,
#   esperar que esté Ready y aplicar un recurso DynaKube (CRD) que declara
#   cómo conectar el clúster al tenant SaaS y cómo inyectar OneAgent en pods.
#
# PRERREQUISITOS:
#   - ./scripts/kind-up.sh
#   - infra/.env con DYNATRACE_ENVIRONMENT_URL, DYNATRACE_API_TOKEN,
#     DYNATRACE_INGEST_TOKEN
#
# USO:
#   ./scripts/operator-up.sh
#
# FLUJO TÉCNICO:
#   1) Namespace dynatrace
#   2) Manifiesto upstream del Operator (GitHub releases)
#   3) Esperar deployment dynatrace-operator
#   4) Sustituir variables en dynakube.yaml.tpl → kubectl apply
#
# NOTAS:
#   - Operator vs OneAgent Docker: patrón GitOps/K8s nativo vs host monitoring.
#   - envsubst reemplaza ${DYNATRACE_*} del template antes de enviar a API server.
# =============================================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/infra/.env"
CTX="kind-dynatrace-lab"

# Versión pinneada del Operator; override con DYNATRACE_OPERATOR_VERSION en .env.
OPERATOR_VERSION="${DYNATRACE_OPERATOR_VERSION:-v1.6.0}"

# --- Validar .env ------------------------------------------------------------
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: Falta $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

# Bucle sobre nombres de variables requeridas; ${!var} es indirect expansion.
for var in DYNATRACE_ENVIRONMENT_URL DYNATRACE_API_TOKEN DYNATRACE_INGEST_TOKEN; do
  if [[ -z "${!var:-}" ]]; then
    echo "ERROR: $var vacío en infra/.env"
    echo "  → M01-01 paso 2e: Kubernetes wizard → Generate token (Operator + Ingest)"
    echo "  → Pega DYNATRACE_API_TOKEN antes de continuar M05"
    exit 1
  fi
done

# Contexto del clúster kind creado en kind-up.sh.
kubectl config use-context "$CTX"

# --- Namespace para componentes Dynatrace ------------------------------------
# create --dry-run=client -o yaml | apply → patrón idempotente "ensure exists".
echo "Instalando Dynatrace Operator ${OPERATOR_VERSION}..."
kubectl create namespace dynatrace --dry-run=client -o yaml | kubectl apply -f -

# Manifiesto oficial publicado en GitHub Releases (CRDs, RBAC, Deployment operator).
kubectl apply -f "https://github.com/Dynatrace/dynatrace-operator/releases/download/${OPERATOR_VERSION}/kubernetes.yaml"

# --- Esperar que el Operator y el webhook estén operativos --------------------
# DynaKube pasa por validating webhook; si aplica antes de que escuche :443 → connection refused.
echo "Esperando operator..."
kubectl -n dynatrace rollout status deployment/dynatrace-operator --timeout=180s
echo "Esperando webhook..."
kubectl -n dynatrace rollout status deployment/dynatrace-webhook --timeout=180s

# --- Aplicar DynaKube (custom resource) ----------------------------------------
# dynakube.yaml.tpl contiene placeholders ${DYNATRACE_ENVIRONMENT_URL}, tokens, etc.
# envsubst los sustituye desde el entorno exportado por source .env.
echo "Aplicando DynaKube..."
export DYNATRACE_ENVIRONMENT_URL="${DYNATRACE_ENVIRONMENT_URL%/}"
envsubst < "$ROOT/infra/k8s/dynakube.yaml.tpl" | kubectl apply -f -

echo ""
echo "Operator instalado. Comprueba:"
echo "  kubectl -n dynatrace get dynakube"
echo "  kubectl -n dynatrace get pods"
