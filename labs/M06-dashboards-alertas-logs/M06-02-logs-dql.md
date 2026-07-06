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
| filter dt.entity.host.name == "<hostname-codespace>"
| sort timestamp desc
| limit 20
```

Sustituye `<hostname-codespace>` por el hostname visto en M02/M03.

**Por qué:** Acota resultados a tu VM de lab.
**Resultado esperado:** Lista de eventos de log recientes del host.

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

### 5 — Management zone (ubicación)

**Acción:** Abre **Settings → Management zones**. Documenta en qué zona está tu host y si crearías una zona `lab` en un tenant compartido.
**Por qué:** Cierra el módulo operativo del curso básico.
**Resultado esperado:** Sabes crear/asignar reglas de zona (aunque no la apliques en trial individual).

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
