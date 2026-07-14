apiVersion: v1
kind: Secret
metadata:
  name: dynatrace-lab-tokens
  namespace: dynatrace
type: Opaque
stringData:
  apiToken: "${DYNATRACE_API_TOKEN}"
  dataIngestToken: "${DYNATRACE_INGEST_TOKEN}"
---
apiVersion: dynatrace.com/v1beta3
kind: DynaKube
metadata:
  name: dynatrace-lab
  namespace: dynatrace
  annotations:
    feature.dynatrace.com/k8s-app-enabled: "true"
spec:
  apiUrl: "${DYNATRACE_ENVIRONMENT_URL}/api"
  tokens: dynatrace-lab-tokens
  oneAgent:
    # Codespace/kind (Docker-in-Docker): cloudNativeFullStack falla al resolver
    # volúmenes en /opt/dynatrace (mountinfo). classicFullStack + volumen off
    # es el equivalente al fix de M03 (ONEAGENT_ENABLE_VOLUME_STORAGE=false).
    classicFullStack:
      env:
        - name: ONEAGENT_ENABLE_VOLUME_STORAGE
          value: "false"
  activeGate:
    capabilities:
      - routing
      - kubernetes-monitoring
      - dynatrace-api
    resources:
      requests:
        cpu: 100m
        memory: 512Mi
      limits:
        cpu: 500m
        memory: 1Gi
