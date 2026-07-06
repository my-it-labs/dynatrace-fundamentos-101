# M05 — Kubernetes con Dynatrace Operator

[← Página anterior](../M04-aplicaciones-trazas-problemas/M04-02-problems-davis.md) · [Siguiente página →](M05-01-kind-operator.md)

> [!NOTE]
> **Cómo funciona este módulo.** Teoría → laboratorios paso a paso.
>
> Requiere Codespace con **≥ 8 GB RAM** y tokens **API** + **Ingest** en `infra/.env`.

## Qué aprenderás

- Crear un clúster **kind** local en el Codespace.
- Instalar **Dynatrace Operator** y un **DynaKube**.
- Monitorizar pods y servicios Kubernetes del lab.

## Teoría

### Operator vs OneAgent “suelt”o

En Kubernetes no instalas OneAgent manualmente en cada nodo: el **Dynatrace Operator** observa el clúster y despliega OneAgent/ActiveGate según un CR **DynaKube**.

| Componente | Rol |
|------------|-----|
| **Operator** | Control loop en namespace `dynatrace` |
| **DynaKube** | CR con `apiUrl`, tokens, modo monitoring |
| **OneAgent** (cloudNativeFullStack) | Monitoriza pods y nodos kind |
| **ActiveGate** | Capacidades K8s API, routing, etc. |

### Tokens M05

| Token | Variable `.env` |
|-------|-----------------|
| API (platform) | `DYNATRACE_API_TOKEN` |
| Ingest (metrics/logs/traces) | `DYNATRACE_INGEST_TOKEN` |

Genera ambos desde la app **Kubernetes** → Add cluster → Other distributions, o Access tokens con scopes adecuados.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M05-01 | [kind y Operator](M05-01-kind-operator.md) | Clúster + DynaKube |
| M05-02 | [Workloads Kubernetes](M05-02-workloads-kubernetes.md) | Pods y servicios |

→ Empieza por **[M05-01](M05-01-kind-operator.md)**.
