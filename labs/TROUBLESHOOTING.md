# Troubleshooting — Dynatrace Fundamentos

> Si un lab falla y la tabla rápida no basta, sigue la sección del módulo. Los pasos están pensados para que **tú** diagnostiques con comandos concretos.

## Stack Docker (M01)

| Problema | Solución |
|----------|----------|
| `demo-api FAIL` | `docker compose -f infra/docker-compose.yml logs demo-api` — suele ser Postgres aún no healthy |
| Puertos ocupados | `docker compose -f infra/docker-compose.yml down` y reintenta |
| Sin Docker | Espera `postCreate` del Codespace o reinicia el Codespace |

## Tokens y `.env` (M01)

| Problema | Solución |
|----------|----------|
| No encuentro Access tokens (gestión) | <kbd>Ctrl</kbd>+<kbd>K</kbd> → `Access tokens` (lista con **Generate new token**). No confundir con Settings → Environment segmentation → Access tokens (solo toggles de configuración) |
| URL incorrecta en `.env` | Solo `https://<id>.live.dynatrace.com` o `https://<id>.apps.dynatrace.com` — sin `/ui/...` |
| Perdí un token | Genera otro en Access tokens; actualiza `.env` (solo se muestra una vez) |
| Mezclé PaaS y API | Son tres tokens distintos — ver M01-01 pasos 2d y 2e |

## OneAgent no arranca o reinicia (M03)

Síntomas: `Restarting`, *Initialization procedure failed*, el host no aparece en Dynatrace.

### 1 — Estado y logs

```bash
./scripts/oneagent-status.sh
docker logs --tail 50 dynatrace-oneagent 2>&1
```

Anota la **primera línea con `Error:`** (no las de montaje de `/proc`).

### 2 — Error de volumen en Codespace

Si el log contiene:

`Cannot determine volume host path from /proc/self/mountinfo`

**Causa:** Docker-in-Docker del Codespace no soporta el volumen persistente del instalador.

**Solución:** Usa la versión actual de `scripts/oneagent-up.sh` (detecta Codespace/DinD y desactiva el volumen).
Si aún falla, fija en `infra/.env`:

```bash
ONEAGENT_ENABLE_VOLUME_STORAGE=false
```

O despliega manualmente:

```bash
./scripts/oneagent-down.sh
set -a && source infra/.env && set +a
docker run -d --name dynatrace-oneagent --restart=unless-stopped \
  --privileged --pid=host --network=host -v /:/mnt/root \
  -e ONEAGENT_ENABLE_VOLUME_STORAGE=false \
  -e ONEAGENT_INSTALLER_SCRIPT_URL="${DYNATRACE_ENVIRONMENT_URL%/}/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default" \
  -e ONEAGENT_INSTALLER_DOWNLOAD_TOKEN="$ONEAGENT_PAAS_TOKEN" \
  dynatrace/oneagent
```

### 3 — Probar descarga del instalador (URL + token)

Desde el Codespace (no pegues tokens en el chat):

```bash
set -a && source infra/.env && set +a
echo "URL=[$DYNATRACE_ENVIRONMENT_URL]  TOKEN_len=${#ONEAGENT_PAAS_TOKEN}"
curl -sI -H "Authorization: Api-Token $ONEAGENT_PAAS_TOKEN" \
  "${DYNATRACE_ENVIRONMENT_URL%/}/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default" \
  | head -1
```

| Resultado `curl` | Qué hacer |
|------------------|-----------|
| `Could not resolve host` | **ID mal copiado** — compara carácter a carácter con la URL del navegador |
| `HTTP/2 404` o `HTTP/1.1 404` | Prueba con dominio **`.live`**: `https://<id>.live.dynatrace.com` en `DYNATRACE_ENVIRONMENT_URL` (mismo `<id>` que en el navegador) |
| `HTTP/2 200` o `302` | URL y token OK — espera 3–5 min y repite `./scripts/oneagent-status.sh` |
| `401` / `403` | Regenera token **PaaS** y actualiza `ONEAGENT_PAAS_TOKEN` |

### 4 — Comprobar contenedor estable

```bash
docker inspect dynatrace-oneagent --format 'status={{.State.Status}} restarts={{.RestartCount}}'
```

`restarts` no debería subir cada minuto. Si sube tras corregir URL/token, revisa de nuevo el paso 3.

### 5 — Validar en Dynatrace

Tras contenedor **Up** estable (2–5 min):

1. <kbd>Ctrl</kbd>+<kbd>K</kbd> → **OneAgents** o **Infrastructure & Operations**
2. Busca el host de tu Codespace → estado **Connected** / **Monitoring**

| Problema | Solución |
|----------|----------|
| Token PaaS inválido | Regenera en Access tokens (plantilla **PaaS**); actualiza `.env` |
| Sin contenedores en UI | `lab-up.sh` activo + espera 5 min con OneAgent Connected |
| `--privileged` denegado | Poco habitual en Codespaces; revisa política del entorno o abre issue en el repo del curso |

## Kubernetes / Operator (M05)

Síntomas: DynaKube **Deploying** indefinido, pod `dynatrace-lab-oneagent-*` en **CrashLoopBackOff**, log:

`Cannot determine volume host path from /proc/self/mountinfo` … `opt/dynatrace/…`

**Causa:** **kind** dentro de **Docker-in-Docker** (Codespace). El modo **`cloudNativeFullStack`** (documentación genérica de Dynatrace) exige volúmenes en el nodo que DinD no resuelve — mismo tipo de límite que M03.

**Solución del curso:** `infra/k8s/dynakube.yaml.tpl` usa **`classicFullStack`** con:

```yaml
env:
  - name: ONEAGENT_ENABLE_VOLUME_STORAGE
    value: "false"
```

Reaplicar tras `git pull`:

```bash
kubectl -n dynatrace rollout status deployment/dynatrace-webhook --timeout=180s
set -a && source infra/.env && set +a
export DYNATRACE_ENVIRONMENT_URL="${DYNATRACE_ENVIRONMENT_URL%/}"
envsubst < infra/k8s/dynakube.yaml.tpl | kubectl apply -f -
kubectl -n dynatrace get dynakube,pods
```

Esperado: DynaKube **Running**, OneAgent **1/1 Ready** (5–10 min).

| Problema | Solución |
|----------|----------|
| Webhook connection refused al apply | Esperar webhook Ready antes de aplicar DynaKube |
| Secret / tokens vacíos | `source infra/.env` antes de `envsubst` |
| Sigue CrashLoop tras classicFullStack | Codespace &lt; 8 GB; Plan B: `applicationMonitoring` en DynaKube (sin DaemonSet en nodo) |

## OpenTelemetry / demo-api (M04)

| Problema | Solución |
|----------|----------|
| Sin spans `demo-api` | Regenera ingest token con `openTelemetryTrace.ingest`; comprueba sin caracteres extra al copiar |
| OTLP 401 | `docker exec infra-demo-api-1 python -c "..."` — ver paso 3 en OneAgent troubleshooting o M04-01 |
| Filtro `/work` en rojo | Usa **Service name** = `demo-api` y vista **Spans** |
| Solo nginx en tracing | Filtro Process group nginx ≠ demo-api; son dos fuentes distintas |
| Rebuild tras cambiar código | `docker compose -f infra/docker-compose.yml up -d --build demo-api` |

## Dynatrace UI

| Problema | Solución |
|----------|----------|
| UI distinta a capturas | Usa búsqueda global (<kbd>Ctrl</kbd>+<kbd>K</kbd>) por nombre de app |
| Sin datos recientes | Verifica zona horaria del tenant; genera carga con `./scripts/generate-load.sh` |
| Mezcla con otros entornos | Filtra por hostname del Codespace |

## Comandos útiles

```bash
./scripts/lab-up.sh
./scripts/lab-down.sh
./scripts/oneagent-up.sh
./scripts/oneagent-down.sh
./scripts/oneagent-status.sh
./scripts/generate-load.sh
./scripts/validate-lab.sh          # checkpoint m01|m03|m04|m05|all
./scripts/apply-m04-otel-solution.sh   # solo si M04 OTel bloqueado
docker compose -f infra/docker-compose.yml ps
docker logs -f dynatrace-oneagent
```
