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

**Acción:** Abre **Dashboards** → **Create dashboard**. Nombre sugerido: `Lab Dynatrace Fundamentos`.
**Por qué:** Centraliza lo que reutilizarás post-curso en tu fork.
**Resultado esperado:** Dashboard vacío editable.

### 2 — Tile response time

**Acción:** Añade tile **Service** o **Metric** con response time del servicio demo-api (últimos 30 min).
**Por qué:** Métrica clave para detectar regresiones como `/slow`.
**Resultado esperado:** Gráfico con datos si hubo tráfico reciente.

### 3 — Tile error rate

**Acción:** Añade tile de **failure rate** o conteo de errores HTTP del mismo servicio.
**Por qué:** Complementa M04-02 (Problems).
**Resultado esperado:** Pico visible si ejecutaste `/fail` recientemente.

### 4 — Tile infra host

**Acción:** Añade tile de CPU o memoria del **host** del Codespace.
**Por qué:** Correlaciona problemas de app con saturación de VM.
**Resultado esperado:** Uso de CPU > 0% con lab activo.

### 5 — Guardar y compartir

**Acción:** Guarda el dashboard. Opcional: genera enlace de compartición solo lectura (si tu tenant lo permite).
**Por qué:** Material reutilizable tras el curso.
**Resultado esperado:** Dashboard persistente en tu tenant.

## Comprueba tu entendimiento

**Tres tiles**
Enumera qué representa cada tile y qué acción tomarías si response time se duplica.
→ Interpretación coherente (investigar trazas, deployments, carga).

## Reto

### 1 — Maintenance window

Crea una **maintenance window** de 10 min sobre el host del lab. Observa si desaparecen alertas nuevas durante la ventana (si las hay configuradas).

<details>
<summary>Ver orientación</summary>

Settings → Maintenance windows → Add. Selecciona host del Codespace. No abuses en producción real.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| Tile sin datos | Sin tráfico reciente | generate-load.sh |
| No encuentro servicio | Nombre distinto | Busca por puerto 8081 o proceso Python |
| Dashboard no guarda | Permisos trial | Guarda en personal scope |
