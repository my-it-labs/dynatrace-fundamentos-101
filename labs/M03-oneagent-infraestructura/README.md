# M03 — OneAgent e infraestructura

[← Página anterior](../M02-arquitectura-smartscape/M02-02-entidades-naming.md) · [Siguiente página →](M03-01-oneagent-compose.md)

> [!NOTE]
> **Cómo funciona este módulo.** Teoría → laboratorios paso a paso.

## Qué aprenderás

- Desplegar **OneAgent** en el host Docker del Codespace (contenedor privilegiado).
- Validar que Dynatrace recibe datos de hosts, procesos y contenedores del lab.
- Localizar Postgres, Redis y `demo-api` en vistas de infraestructura.
- Interpretar métricas básicas y líneas base (baselines).

## Teoría

### ¿Qué es OneAgent?

**OneAgent** es el componente de ingestión de Dynatrace instalado cerca de la carga monitorizada. Descubre procesos, instrumenta aplicaciones y envía métricas, trazas y logs al tenant SaaS.

En este curso usamos **full-stack monitoring** sobre Docker sin orquestador: OneAgent corre como **contenedor privilegiado** en el host del Codespace y monitoriza el resto de contenedores Compose.

### Modos de despliegue (resumen)

| Enfoque | Cuándo | En este curso |
|---------|--------|---------------|
| OneAgent en host Linux | VM/bare metal | Equivalente vía contenedor OA |
| OneAgent como contenedor Docker | Docker sin K8s | **M03 — `scripts/oneagent-up.sh`** |
| Dynatrace Operator | Kubernetes | **M05** |
| Application-only (codemodules) | Sin acceso al host | No usamos |

### Flujo de datos

```text
loadgen → demo-web / demo-api → Postgres / Redis
                ↓
         OneAgent (host Codespace)
                ↓
         Tenant Dynatrace SaaS → Smartscape / Problems / Dashboards
```

> [!TIP]
> **ActiveGate** actúa como proxy/extension en entornos enterprise (K8s API, VMware, etc.). En el lab básico con SaaS trial **no es obligatorio**; lo verás en despliegues K8s avanzados.

### Tokens que necesitas

| Token | Uso |
|-------|-----|
| **PaaS** | OneAgent contenedor — **M03** (`ONEAGENT_PAAS_TOKEN`) |
| **Ingest** | Trazas OTel en demo-api — **M04** (`DYNATRACE_INGEST_TOKEN`, scope `openTelemetryTrace.ingest`) |
| API / Operator | **M05** (Kubernetes) |

> En Codespace OneAgent **no** instala nativo en el host. La instrumentación profunda de Flask en M04 usa **OpenTelemetry → OTLP** al tenant.

### Límite didáctico (Codespace)

OneAgent en contenedor observa **infra** (host, contenedores, nginx). **Deep monitoring** de `api.py` suele fallar por Docker anidado. M03-01 incluye un paso para **ver ese límite** antes de M04.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M03-01 | [OneAgent en Compose](M03-01-oneagent-compose.md) | PaaS token, despliegue y validación |
| M03-02 | [Procesos y bases de datos](M03-02-procesos-bases-datos.md) | Infra del lab en Dynatrace |

→ Empieza por **[M03-01 — OneAgent en Compose](M03-01-oneagent-compose.md)**.

Si el contenedor no arranca o el host no aparece en Dynatrace → **[TROUBLESHOOTING — OneAgent (M03)](../TROUBLESHOOTING.md#oneagent-no-arranca-o-reinicia-m03)**.
