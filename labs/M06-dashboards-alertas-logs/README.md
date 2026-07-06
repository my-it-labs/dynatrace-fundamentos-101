# M06 — Dashboards, logs y operación básica

[← Página anterior](../M05-kubernetes-operator/M05-02-workloads-kubernetes.md) · [Siguiente página →](M06-01-dashboards-notebooks.md)

> [!NOTE]
> **Cómo funciona este módulo.** Teoría → laboratorios paso a paso.

## Qué aprenderás

- Montar un **dashboard** operativo del lab (Compose + opcional K8s).
- Investigar **logs** con **DQL** introductorio.
- Configurar **maintenance window** y ubicar **management zones**.

## Teoría

### Dashboards vs Notebooks

| Artefacto | Uso |
|-----------|-----|
| **Dashboard** | Vista fija para operación (tiles, gráficos, umbrales) |
| **Notebook** | Análisis ad hoc, narrativa, compartir investigación |

En el básico priorizamos un dashboard mínimo de salud del demo-api.

### DQL (Dynatrace Query Language)

Lenguaje unificado para logs, métricas y spans en Grail. Ejemplo introductorio:

```sql
fetch logs
| filter matchesPhrase(content, "demo-api")
| limit 20
```

La sintaxis exacta puede variar según versión; usa el editor con autocompletado.

### Operación

- **Management zones** — segmentan entidades por equipo/entorno.
- **Maintenance windows** — suprimen alertas durante cambios planificados.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M06-01 | [Dashboards y notebooks](M06-01-dashboards-notebooks.md) | Vista operativa |
| M06-02 | [Logs con DQL](M06-02-logs-dql.md) | Consulta básica |

→ Empieza por **[M06-01](M06-01-dashboards-notebooks.md)**.
