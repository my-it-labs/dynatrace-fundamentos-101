# M06-02 — Logs con DQL

[← Página anterior](M06-01-dashboards-notebooks.md) · [Siguiente página →](../../README.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

M06-01 hecho; dashboard guardado. OneAgent + tráfico reciente en el lab.

---

### Objetivo

Ejecutar una consulta DQL básica sobre logs del entorno de lab y correlacionar un evento con trazas o servicios.

### Prerrequisitos

- OneAgent activo (M03) con ingest de logs habilitado en tu tenant.
- Lab con tráfico reciente.

### En qué consiste

Abres el editor DQL, filtras logs del host/servicio del lab y relacionas una línea con actividad en Distributed traces.

### 1 — Abrir Logs / DQL

**Acción:** Abre la app **Logs** o **Notebooks** con editor **DQL** (nombre según versión UI).
**Por qué:** Grail unifica logs con otras señales bajo DQL.
**Resultado esperado:** Editor con consulta vacía o plantilla.

### 2 — Consulta introductoria

**Acción:** Ejecuta una consulta equivalente a (ajusta según autocompletado del editor):

```sql
fetch logs
| summarize registros = count(), by:{container.name}
```

Después quédate con los de demo-api:

```sql
fetch logs
| filter container.name == "infra-demo-api-1"
| sort timestamp desc
| limit 20
```

> En los logs, `host.name` es el identificador interno de la VM del Codespace, no el nombre
> `codespaces-…` que ves en Infrastructure. Por eso filtramos por **contenedor**.

**Por qué:** Acota resultados a un componente de tu lab.
**Resultado esperado:** Recuento por contenedor (`infra-demo-api-1`, `infra-demo-web-1`, `infra-postgres-1`…) y, en la segunda consulta, peticiones `GET /work`, `/fail`… de demo-api.

### 3 — Filtrar por contenido

**Acción:** Añade filtro por texto, p. ej. `demo-api`, `flask`, `error` o `GET`:

```sql
fetch logs
| filter matchesPhrase(content, "error") or matchesPhrase(content, "GET")
| sort timestamp desc
| limit 20
```

**Por qué:** Simula investigación de incidente post-problem M04.
**Resultado esperado:** Subconjunto acotado (puede estar vacío si logs de app no van a Grail — anota limitación).

### 4 — Correlacionar con trazas

**Acción:** Desde un log relevante (o desde Problems), abre **View related traces** / enlace equivalente, o busca en Distributed traces en el mismo timestamp.
**Por qué:** Associate valora correlación log ↔ trace.
**Resultado esperado:** Salto temporal coherente entre log y PurePath (cuando la plataforma lo permita).

### 5 — Segments (ubicación)

**Acción:** Abre **Settings → Environment segmentation → Segments**. Documenta qué segment crearías (p. ej. `lab-<tu-usuario>` filtrando por tu host) como harías en un entorno real para que cada equipo vea solo sus datos.
**Por qué:** Cierra el módulo operativo del curso básico.
**Resultado esperado:** Sabes dónde se crean los Segments y para qué sirven (aunque no lo apliques en trial individual).

## Comprueba tu entendimiento

**Cuándo DQL vs UI**
¿Cuándo usarías DQL en lugar de solo Distributed traces?
→ Casos como búsqueda masiva en logs, agregaciones, export — respuesta razonable.

## Reto

### 1 — Consulta guardada

Guarda la consulta del paso 3 como favorita o snippet en el editor para reutilizarla tras el curso.

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| Sin logs en Grail | Log ingest no activo / delay | Verifica ingest token y espera 10 min |
| Sintaxis DQL error | Versión UI distinta | Usa builder/autocomplete |
| Hostname incorrecto | Copia mal | Repite desde Infrastructure → Host |

## Cierre del curso

Has completado el recorrido **M01–M06**. Conserva tu **fork** en GitHub: incluye labs, infra, scripts y tu `.env` local (nunca en git) para seguir practicando con tu tenant trial.

**Siguientes pasos:** repite las consultas DQL de este lab fuera de la UI, por ejemplo con la API REST,
el CLI **dtctl** o un asistente de IA conectado por **MCP**. Ver
[M06 — Más allá de la UI](README.md#más-allá-de-la-ui-api-rest-dtctl-y-mcp).
