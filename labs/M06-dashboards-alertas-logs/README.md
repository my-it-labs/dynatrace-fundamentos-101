# M06 — Dashboards, logs y operación básica

[← Página anterior](../M05-kubernetes-operator/M05-02-workloads-kubernetes.md) · [Siguiente página →](M06-01-dashboards-notebooks.md)

> [!NOTE]
> **Cómo funciona este módulo.** Teoría → laboratorios paso a paso.

## Qué aprenderás

- Montar un **dashboard** operativo del lab (Compose + opcional K8s).
- Investigar **logs** con **DQL** introductorio.
- Configurar **maintenance window** y ubicar **Segments**.

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
| filter container.name == "infra-demo-api-1"
| limit 20
```

La sintaxis exacta puede variar según versión; usa el editor con autocompletado.

### Operación

- **Segments** — filtros reutilizables por equipo/entorno (sustituyen a las antiguas *management zones*, que no existen en tenants nuevos).
- **Maintenance windows** — suprimen alertas durante cambios planificados.

### Más allá de la UI: API REST, dtctl y MCP

Todo lo que haces en este módulo (consultas DQL, dashboards, problemas) también es accesible sin
navegador. Son tres formas de hablar con el mismo tenant:

| Interfaz | Para quién | Ejemplo de uso |
|----------|------------|----------------|
| **API REST** | Scripts e integraciones | Lanzar una consulta DQL desde un pipeline CI/CD |
| **dtctl** | Personas en terminal (estilo `kubectl`) | Consultar logs o gestionar dashboards desde la shell |
| **MCP server** | Asistentes de IA (Claude, Copilot, Cursor…) | Preguntar en lenguaje natural «¿qué problemas abiertos hay?» |

Las tres se autentican con **tokens** (como los de M01) o OAuth, y respetan los mismos permisos.
No forman parte de los labs de este curso básico: son el siguiente paso natural para automatizar
la operación. Proyectos de referencia: [Dynatrace/dtctl](https://github.com/Dynatrace/dtctl)
y [dynatrace-oss/dynatrace-mcp](https://github.com/dynatrace-oss/dynatrace-mcp).

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M06-01 | [Dashboards y notebooks](M06-01-dashboards-notebooks.md) | Vista operativa |
| M06-02 | [Logs con DQL](M06-02-logs-dql.md) | Consulta básica |

→ Empieza por **[M06-01](M06-01-dashboards-notebooks.md)**.
