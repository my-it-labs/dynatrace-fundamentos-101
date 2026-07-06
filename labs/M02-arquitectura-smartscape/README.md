# M02 — Arquitectura y Smartscape

[← Página anterior](../M01-entorno-codespace-plataforma/M01-02-navegacion-ui.md) · [Siguiente página →](../M03-oneagent-infraestructura/README.md)

> [!NOTE]
> **Cómo funciona este módulo.** Teoría → laboratorios paso a paso.
>
> **Orden recomendado:** lee la teoría de M02, completa **M03** (OneAgent) y después vuelve a los labs M02-01 y M02-02 con datos reales en Smartscape.

## Qué aprenderás

- Describir arquitectura Dynatrace SaaS y componentes del camino de datos.
- Leer **Smartscape** y relaciones entre entidades.
- Diferenciar host, proceso, servicio, aplicación y dependencia.

## Teoría

### Componentes principales

| Componente | Función |
|------------|---------|
| **OneAgent** | Descubrimiento, instrumentación, envío de telemetría |
| **ActiveGate** | Puente/proxy opcional (K8s, DB remotas, routing) |
| **Grail** | Almacén analítico de logs, métricas, trazas, eventos |
| **Davis AI** | Detección de anomalías, problems, causa raíz |
| **Apps de plataforma** | Infrastructure, Distributed traces, Logs, Dashboards… |

### Entidades que verás en el lab

```text
Host (Codespace)
 ├── Container demo-api → Process python → Service demo-api
 ├── Container postgres → PostgreSQL
 ├── Container redis    → Redis
 └── Container demo-web → nginx
```

> [!IMPORTANT]
> **Servicio** y **aplicación** se consolidan cuando OneAgent instrumenta tráfico HTTP (profundizamos en **M04**). En M02–M03 el foco es **infraestructura y topología**.

### SaaS vs Managed (contexto)

| | SaaS (este curso) | Managed |
|---|-------------------|---------|
| Servidor Dynatrace | Alojado por Dynatrace | Instalado por el cliente |
| Trial | Sí | Normalmente no |
| Grail / funciones nuevas | Primero en SaaS | Dependiente de versión |

## Ahora practica tú

> Completa **M03-01** antes de empezar estos labs.

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M02-01 | [Recorrido Smartscape](M02-01-smartscape-recorrido.md) | Topología del entorno |
| M02-02 | [Entidades y naming](M02-02-entidades-naming.md) | Convenciones de nombre |

→ Tras M03-01, empieza por **[M02-01](M02-01-smartscape-recorrido.md)**.
