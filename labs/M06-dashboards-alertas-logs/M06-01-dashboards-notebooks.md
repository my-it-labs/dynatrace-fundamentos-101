# M06-01 — Dashboards y notebooks

[← Página anterior](README.md) · [Siguiente página →](M06-02-logs-dql.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

M03–M04 con datos (host, spans `demo-api` si completaste OTel en M04-01).

---

### Objetivo

Crear un dashboard mínimo para monitorizar salud del demo-api y del host del Codespace.

### Prerrequisitos

- M03–M04 completados (datos de servicio e infraestructura).
- Carga reciente (`./scripts/generate-load.sh` opcional).

### En qué consiste

Añades tiles de métricas clave y guardas el dashboard en tu tenant.

### 1 — Crear dashboard

| | |
|-|-|
| **Dónde** | <kbd>Ctrl</kbd>+<kbd>K</kbd> → **Dashboards** |
| **Acción** | **New dashboard** (arriba a la derecha) → pulsa el título «Untitled dashboard» y renómbralo `Lab Dynatrace Fundamentos` |
| **Para qué** | Centralizar métricas del lab en una sola vista |
| **Validar** | Lienzo vacío «Start assembling your dashboard» y botón azul **+** |
| **Comprender** | Un dashboard es operación; un notebook es análisis ad hoc (M06 teoría) |

> En la app actual **todos los tiles son consultas DQL** (o asistentes Metrics/Logs que generan DQL).
> En cada paso: **+** → **DQL** → pega la consulta → **Run** → elige visualización.

### 2 — Tile tiempo de respuesta

| | |
|-|-|
| **Dónde** | Dashboard → **+** → **DQL** |
| **Acción** | Pega la consulta de abajo · timeframe **Last 30 minutes** · visualización **Line** |
| **Para qué** | Detectar regresiones como `/slow` de M04 |
| **Validar** | Línea con puntos si hubo tráfico reciente (`./scripts/generate-load.sh`) |
| **Comprender** | `duration` va en **nanosegundos** (800M ≈ 0,8 s). Sin tráfico el tile puede estar vacío — no es error del dashboard |

```sql
fetch spans
| filter service.name == "demo-api" and request.is_root_span == true
| makeTimeseries tiempo_medio = avg(duration), p90 = percentile(duration, 90), interval:1m
```

### 3 — Tile errores

| | |
|-|-|
| **Dónde** | Mismo dashboard → **+** → **DQL** |
| **Acción** | Pega la consulta · visualización **Bar** o **Line** |
| **Para qué** | Complementa M04-02 (Problems) |
| **Validar** | Pico si ejecutaste `/fail` en la última hora |
| **Comprender** | Correlaciona con Problems pero no lo sustituye |

```sql
fetch spans
| filter service.name == "demo-api" and request.is_root_span == true
| makeTimeseries errores = countIf(request.is_failed == true), interval:1m
```

### 4 — Tile CPU del host

| | |
|-|-|
| **Dónde** | Mismo dashboard → **+** → **DQL** |
| **Acción** | Pega la consulta · visualización **Line** |
| **Para qué** | Correlacionar saturación de VM con latencia de app |
| **Validar** | CPU > 0% con lab activo |
| **Comprender** | Host = raíz del árbol que viste en M03 |

```sql
timeseries cpu = avg(dt.host.cpu.usage), by:{dt.smartscape.host}
```

### 5 — Guardar y compartir

| | |
|-|-|
| **Dónde** | Barra superior del dashboard |
| **Acción** | Los cambios se guardan solos (icono de nube junto al título) · opcional: **Share** |
| **Para qué** | Reutilizar tras el curso en tu fork |
| **Validar** | Dashboard aparece en **All dashboards** al recargar |
| **Comprender** | Los dashboards viven en el tenant, no en el repo git |

## Comprueba tu entendimiento

**Tres tiles**
Enumera qué representa cada tile y qué acción tomarías si response time se duplica.
→ Interpretación coherente (investigar trazas, deployments, carga).

## Reto

### 1 — Maintenance window

Crea una **maintenance window** de 10 min sobre el host del lab. Observa si desaparecen alertas nuevas durante la ventana (si las hay configuradas).

<details>
<summary>Ver orientación</summary>

Settings → General → Environment management → Maintenance windows → Add (o busca `maintenance` en Search settings). Selecciona host del Codespace. No abuses en producción real.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| Tile sin datos | Sin tráfico reciente | generate-load.sh |
| No encuentro servicio | Nombre distinto | Busca por puerto 8081 o proceso Python |
| Dashboard no guarda | Permisos trial | Guarda en personal scope |
