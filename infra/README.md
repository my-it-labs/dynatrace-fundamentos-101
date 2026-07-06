# Infraestructura de laboratorio

Stack de demo para **Dynatrace Fundamentos**: aplicaciones en Docker Compose monitorizadas desde un tenant **Dynatrace SaaS** (externo al Codespace).

## Arranque rápido

```bash
cp .env.example .env
# Edita .env con tu tenant y tokens (ver M01-01)
./scripts/lab-up.sh          # compose + health-check
./scripts/oneagent-up.sh     # M03 — OneAgent (requiere ONEAGENT_PAAS_TOKEN)
```

Comprobaciones:

```bash
./scripts/health-check.sh
./scripts/oneagent-status.sh
```

## Servicios (Compose)

| Servicio | Puerto | Rol |
|----------|--------|-----|
| `demo-web` | 8080 | Frontend nginx |
| `demo-api` | 8081 | API Flask (starter); en **M04** añades OTel → OTLP |
| `postgres` | 5432 | Base de datos del lab |
| `redis` | 6379 | Cache del lab |
| `loadgen` | — | Generador de carga periódica |

## Kubernetes (M05)

| Ruta | Uso |
|------|-----|
| `infra/kind/cluster-config.yaml` | Clúster kind de un nodo |
| `infra/k8s/dynakube.yaml.tpl` | Plantilla DynaKube (envsubst) |
| `infra/k8s/demo-workload.yaml` | nginx + loadgen en namespace `dynatrace-lab` |
| `scripts/kind-up.sh` / `kind-down.sh` | Crear/destruir clúster |
| `scripts/operator-up.sh` | Operator + DynaKube |
| `scripts/k8s-lab-up.sh` | Desplegar workloads K8s |

## Carga y problemas (M04)

| Script | Uso |
|--------|-----|
| `scripts/generate-load.sh` | Tráfico `/work`, `/slow`, `/fail` |

## Variables de entorno

Copia `infra/.env.example` → `infra/.env`. Nunca commitees tokens reales.

| Variable | Descripción |
|----------|-------------|
| `DYNATRACE_ENVIRONMENT_URL` | URL del tenant (`https://<env-id>.live.dynatrace.com`) |
| `DYNATRACE_API_TOKEN` | Token API plataforma (según labs) |
| `DYNATRACE_OPERATOR_TOKEN` | Token Operator (Kubernetes / M05) |
| `DYNATRACE_INGEST_TOKEN` | Ingest metrics/logs/traces |

## Requisitos

- Docker + Docker Compose v2 (incluido en Codespaces con `.devcontainer`)
- ~8 GB RAM recomendados (especialmente M05 con kind)
- Acceso HTTPS saliente al tenant Dynatrace
