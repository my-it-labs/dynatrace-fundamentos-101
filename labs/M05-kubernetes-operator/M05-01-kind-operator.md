# M05-01 — kind y Operator

[← Página anterior](README.md) · [Siguiente página →](M05-02-workloads-kubernetes.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| `.env` | `DYNATRACE_API_TOKEN` + `DYNATRACE_INGEST_TOKEN` (distintos del PaaS M03) |
| Docker Compose | Puede seguir activo en paralelo |
| kind | No instalado aún |

---

### Objetivo

Levantar kind, instalar Dynatrace Operator y dejar un DynaKube en estado **Running**.

### Prerrequisitos

- `DYNATRACE_ENVIRONMENT_URL`, `DYNATRACE_API_TOKEN`, `DYNATRACE_INGEST_TOKEN` en `infra/.env`.
- Herramientas: `kubectl`, `kind`, `envsubst` (paquete `gettext`).

### En qué consiste

Instalas kind si falta, creas el clúster, aplicas Operator y DynaKube con los scripts del repo.

### 1 — Instalar kind (si hace falta)

**Acción:** Ejecuta `kind version`. Si falla, el Codespace debería haberlo instalado en `postCreate`; si no:

```bash
./scripts/setup-codespace.sh
kind version
```

**Por qué:** kind no siempre viene en la imagen base de Codespaces.
**Resultado esperado:** `kind version` responde OK.

### 2 — Crear clúster

**Acción:**

```bash
./scripts/kind-up.sh
kubectl get nodes
```

**Por qué:** Clúster aislado `dynatrace-lab` sin afectar Docker Compose del resto del curso.
**Resultado esperado:** Un nodo `Ready`.

### 3 — Rellenar tokens API e Ingest

**Acción:** En `infra/.env`, confirma tokens distintos del PaaS de M03:

- `DYNATRACE_API_TOKEN` — API platform
- `DYNATRACE_INGEST_TOKEN` — metrics.ingest, logs.ingest, openTelemetryTrace.ingest

**Por qué:** DynaKube los referencia vía Secret `dynatrace-lab-tokens`.
**Resultado esperado:** Variables no vacías.

### 4 — Instalar Operator

**Acción:**

```bash
./scripts/operator-up.sh
```

(Si `envsubst: command not found`, ejecuta `./scripts/setup-codespace.sh` primero.)

**Por qué:** Aplica manifest oficial del Operator y plantilla DynaKube del curso (modo **classicFullStack** adaptado a Codespace — ver teoría en [README](README.md)).
**Resultado esperado:** Pods `dynatrace-operator` y componentes OneAgent/ActiveGate arrancando.

### 5 — Validar DynaKube

**Acción:**

```bash
kubectl -n dynatrace get dynakube
kubectl -n dynatrace get pods
```

**Por qué:** Confirma reconciliación antes de desplegar apps.
**Resultado esperado:** DynaKube **Running**; pods OneAgent/ActiveGate sin CrashLoop prolongado (puede tardar 5–10 min).

Validación local:

```bash
./scripts/validate-lab.sh m05-01
```

(Aviso sobre workloads es normal hasta M05-02.)

## Comprueba tu entendimiento

**Namespace operator**
¿En qué namespace vive el Operator y el DynaKube?
→ Namespace `dynatrace`.

## Reto

### 1 — Versión Operator

Consulta la variable `DYNATRACE_OPERATOR_VERSION` (default `v1.6.0`) y localiza en GitHub releases de dynatrace-operator qué cambió en esa versión (lectura rápida).

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| OOM / kind lento | RAM insuficiente | Codespace 8 GB+; cierra procesos |
| DynaKube error tokens | Scopes incorrectos | Regenera API + Ingest desde app K8s |
| `envsubst: command not found` | Falta gettext | `apt install gettext-base` |
| apiUrl mal formada | URL con `/ui/` | Usa `https://<id>.live.dynatrace.com` |
| OneAgent CrashLoop + `volume host path` | `cloudNativeFullStack` en DinD | Repo usa `classicFullStack` + volumen off; `git pull` y `./scripts/operator-up.sh` |
| DynaKube **Deploying** > 15 min | OneAgent/ActiveGate no Ready | `kubectl -n dynatrace get pods` + logs |
| DynaKube webhook connection refused | Webhook aún no Ready | `kubectl -n dynatrace rollout status deployment/dynatrace-webhook` y re-aplica DynaKube |

## Referencia

- `scripts/operator-up.sh`
- `infra/k8s/dynakube.yaml.tpl`
