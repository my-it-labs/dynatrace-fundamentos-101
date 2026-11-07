# M04-01 — Servicios y trazas (OneAgent + OpenTelemetry)

[← Página anterior](README.md) · [Siguiente página →](M04-02-problems-davis.md)

> **Formato del lab:** cada paso indica **dónde** actuar, **qué** hacer, **para qué**, **cómo validar** y **qué comprender**. Tú implementas el código; el repo solo trae el **starter**.

---

## Punto de partida (starter)

Tras M03 deberías tener:

| Elemento | Estado |
|----------|--------|
| OneAgent contenedor | Conectado; host y contenedores visibles en Infrastructure |
| `infra/demo-web/api.py` | Flask **sin** OpenTelemetry |
| Distributed Tracing | Trazas de **nginx** (Service `localhost:80`), no de Flask |
| `infra/.env` | `DYNATRACE_INGEST_TOKEN` con scope `openTelemetryTrace.ingest` |

**No es un error** si Services está vacío o solo ves nginx: es el límite que descubriste en M03.

---

## Parte A — Confirmar el límite de OneAgent

### Paso 1 — Trazas nginx (OneAgent)

| | |
|-|-|
| **Dónde** | Dynatrace → <kbd>Ctrl</kbd>+<kbd>K</kbd> → **Distributed Tracing** → **Explorer** |
| **Acción** | Faceta **Service** = `localhost:80` · timeframe **Last 30 minutes** |
| **Para qué** | Ver qué observa OneAgent **sin** tocar código |
| **Validar** | Filas con Service `localhost:80`, Endpoint `/` |
| **Comprender** | Es tráfico loadgen → demo-web; **1 span** = solo capa nginx |

![Tracing nginx](../img/M04-01-tracing-nginx.png)

### Paso 2 — Comprobar que Flask no aparece

| | |
|-|-|
| **Dónde** | Mismo Explorer; quita filtros |
| **Acción** | Filtro **Service name** = `demo-api` → **Change to spans** |
| **Para qué** | Contrastar antes/después de instrumentar |
| **Validar** | **Sin filas** (o solo ruido ajeno al lab) |
| **Comprender** | OneAgent en Codespace **no** deep-monitors `api.py` |

---

## Parte B — Instrumentar demo-api con OpenTelemetry

### Paso 3 — Verificar token ingest (creado en M01-01)

| | |
|-|-|
| **Dónde** | `infra/.env` en el Codespace |
| **Acción** | Confirma que `DYNATRACE_INGEST_TOKEN` **no está vacío** y tiene scope `openTelemetryTrace.ingest` (lo generaste en M01-01 paso 2e). Si lo perdiste, regenera en **Access tokens** con nombre `curso-otel-ingest`. |
| **Para qué** | Autorizar OTLP desde la app al tenant |
| **Validar** | `source infra/.env && test -n "$DYNATRACE_INGEST_TOKEN" && echo OK` |
| **Comprender** | **PaaS** = OneAgent · **Ingest** = OTel (tokens distintos) |

### Paso 4 — Dependencias Python

| | |
|-|-|
| **Dónde** | `infra/demo-web/requirements.txt` |
| **Acción** | Añade al final del fichero: |

```text
opentelemetry-api>=1.27
opentelemetry-sdk>=1.27
opentelemetry-exporter-otlp-proto-http>=1.27
opentelemetry-instrumentation-flask>=0.48b0
opentelemetry-instrumentation-psycopg2>=0.48b0
opentelemetry-instrumentation-redis>=0.48b0
```

| **Para qué** | SDK + export OTLP + auto-instrumentación Flask/Redis/Postgres |
| **Validar** | Fichero guardado con las 6 líneas nuevas |
| **Comprender** | Instrumentación **en la app**, no otro OneAgent en el contenedor |

### Paso 5 — Código OTel en `api.py`

| | |
|-|-|
| **Dónde** | `infra/demo-web/api.py` |
| **Acción** | Justo **después** de `app = Flask(__name__)` pega la función y su llamada: |

```python
def _configure_otel() -> None:
    base = os.environ.get("DYNATRACE_ENVIRONMENT_URL", "").strip().rstrip("/")
    token = os.environ.get("DYNATRACE_INGEST_TOKEN", "").strip()
    if not base or not token:
        return

    from opentelemetry import trace
    from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
    from opentelemetry.instrumentation.flask import FlaskInstrumentor
    from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
    from opentelemetry.instrumentation.redis import RedisInstrumentor
    from opentelemetry.sdk.resources import Resource
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import SimpleSpanProcessor

    exporter = OTLPSpanExporter(
        endpoint=f"{base}/api/v2/otlp/v1/traces",
        headers={"Authorization": f"Api-Token {token}"},
    )
    provider = TracerProvider(resource=Resource.create({"service.name": "demo-api"}))
    provider.add_span_processor(SimpleSpanProcessor(exporter))
    trace.set_tracer_provider(provider)

    FlaskInstrumentor().instrument_app(app)
    Psycopg2Instrumentor().instrument()
    RedisInstrumentor().instrument()


_configure_otel()
```

| **Para qué** | Enviar spans **directo al tenant** (`/api/v2/otlp/v1/traces`) |
| **Validar** | `_configure_otel()` está **antes** de las rutas `@app.get` |
| **Comprender** | `SimpleSpanProcessor` exporta al vuelo (mejor para el lab que batch) |

### Paso 6 — Variables en Compose

| | |
|-|-|
| **Dónde** | `infra/docker-compose.yml` → servicio `demo-api` → `environment` |
| **Acción** | **Comprueba** que ya existen (el repo las trae preconfiguradas): |

```yaml
      DYNATRACE_ENVIRONMENT_URL: ${DYNATRACE_ENVIRONMENT_URL:-}
      DYNATRACE_INGEST_TOKEN: ${DYNATRACE_INGEST_TOKEN:-}
      OTEL_SERVICE_NAME: demo-api
```

| **Para qué** | Pasar tenant y token al contenedor sin commitear secretos |
| **Validar** | `DATABASE_URL`, `REDIS_URL` y las tres líneas OTel presentes |
| **Comprender** | `.env` del host → variables del contenedor `demo-api` |

### Paso 7 — Dockerfile (sin doble instrumentación)

| | |
|-|-|
| **Dónde** | `infra/demo-web/Dockerfile.api` — última línea |
| **Acción** | **Mantén** (no cambies a `opentelemetry-instrument`): |

```dockerfile
CMD ["python", "api.py"]
```

| **Para qué** | `_configure_otel()` del paso 5 ya instrumenta Flask/Redis/Postgres |
| **Validar** | `COPY requirements.txt api.py .` presente; **no** uses `opentelemetry-instrument` junto con el paso 5 (doble instrumentación) |
| **Comprender** | Wrapper CLI **o** código manual — en este lab usamos **solo** el código manual |

### Paso 8 — Rebuild y comprobar ingest

| | |
|-|-|
| **Dónde** | Terminal del Codespace |
| **Acción** | |

```bash
docker compose -f infra/docker-compose.yml up -d --build --force-recreate demo-api
for i in $(seq 1 30); do curl -s http://127.0.0.1:8081/work >/dev/null; done
```

| **Para qué** | Imagen nueva con OTel + tráfico |
| **Validar** | `curl http://127.0.0.1:8081/work` devuelve JSON con `hits` |
| **Comprender** | Sin `--build` los cambios de código **no** entran en la imagen |

Si ingest falla (401): regenera token — ver [TROUBLESHOOTING](../TROUBLESHOOTING.md).

---

## Parte C — Validar y interpretar en Dynatrace

### Paso 9 — Spans de demo-api

| | |
|-|-|
| **Dónde** | **Distributed Tracing** → **Explorer** → **Change to spans** |
| **Acción** | Filtro **Service name** = `demo-api` |
| **Para qué** | OTel aparece como **spans**, no siempre como Requests |
| **Validar** | Filas **GET /work** (Span kind `server`, status Ok) |
| **Comprender** | Filtros son **clave = valor**; `/work` suelto en rojo = inválido |

![Spans demo-api](../img/M04-01-spans-demo-api.png)

### Paso 10 — Waterfall de `/work`

| | |
|-|-|
| **Dónde** | Clic en una fila **GET /work** |
| **Acción** | Expande el waterfall y el panel derecho |
| **Para qué** | Ver cadena app → dependencias |
| **Validar** | Hijos **INCRBY** (Redis) y **SELECT** (Postgres) |
| **Comprender** | Cada barra = un **span**; el tiempo se reparte entre hops |

![Waterfall GET /work](../img/M04-01-waterfall-get-work.png)

| Panel | Qué mirar |
|-------|-----------|
| Waterfall | Jerarquía y duración |
| Span details | HTTP 200, `demo-api:8081` |
| Logs | Puede estar vacío en M04 — normal |

### Paso 11 — Comparar `/slow`

| | |
|-|-|
| **Dónde** | Terminal + Spans |
| **Acción** | `curl -s http://127.0.0.1:8081/slow` · busca **GET /slow** |
| **Para qué** | Latencia visible en observabilidad |
| **Validar** | Duration ≈ **3 s** vs `/work` < 1 s |
| **Comprender** | Mismo servicio, distinto comportamiento = distinta señal |

---

## Cierre del lab

| Pregunta | Respuesta esperada |
|----------|-------------------|
| ¿Qué ve OneAgent sin OTel? | nginx, infra |
| ¿Qué añade OTel? | Spans Flask + Redis + Postgres |
| ¿Dónde se busca? | Spans → Service `demo-api` |
| ¿Qué token usa OTel? | Ingest, no PaaS |

→ Siguiente: **[M04-02 — Problems Davis](M04-02-problems-davis.md)**

---

## Si te atascas

<details>
<summary>Checklist rápida</summary>

1. `DYNATRACE_ENVIRONMENT_URL` con **`.live.dynatrace.com`**
2. Ingest token sin basura al copiar
3. `docker compose ... up -d --build demo-api`
4. Vista **Spans**, no solo Requests
5. [TROUBLESHOOTING — OTel](../TROUBLESHOOTING.md#opentelemetry--demo-api-m04)
6. Último recurso: `./scripts/apply-m04-otel-solution.sh` (ver [labs/solutions/M04/](../solutions/M04/))

</details>
