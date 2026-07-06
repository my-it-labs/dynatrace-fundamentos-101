# M03-02 — Procesos y bases de datos

[← Página anterior](M03-01-oneagent-compose.md) · [Siguiente página →](../M02-arquitectura-smartscape/M02-01-smartscape-recorrido.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| OneAgent | Conectado (M03-01) |
| Host | Visible con pestañas Overview / Containers / Processes |
| Tracing | Solo nginx hasta M04 |

---

### Objetivo

Localizar procesos de aplicación y tecnologías de infraestructura (PostgreSQL, Redis) monitorizadas por OneAgent y relacionarlas con la stack Compose.

### Prerrequisitos

- M03-01 completado (OneAgent connected, contenedores visibles).

### En qué consiste

Recorrer el host del lab en Dynatrace, identificar procesos clave, abrir métricas de bases de datos/cache y correlacionar nombres con `infra/docker-compose.yml`.

### 1 — Host del Codespace

**Acción:** En **Infrastructure → Hosts**, abre el host de tu Codespace. Revisa métricas de CPU, memoria, y número de procesos/contenedores.
**Por qué:** El host es la raíz del árbol de infraestructura en Smartscape.
**Resultado esperado:** Métricas activas coincidiendo con la carga de `loadgen`.

### 2 — Proceso demo-api

**Acción:** Desde el host, navega a contenedores/procesos hasta localizar **Python** / **demo-api** (servicio Flask del lab). Abre métricas de CPU y tráfico de red del proceso.
**Por qué:** M04 analizará este proceso como **servicio** instrumentado.
**Resultado esperado:** Proceso activo con actividad periódica (peticiones de loadgen cada ~3 s).

### 3 — PostgreSQL

**Acción:** Busca el proceso o contenedor **postgres**. Abre la vista de tecnología **PostgreSQL** si está disponible (metrics de conexiones, throughput).
**Por qué:** Dynatrace detecta bases de datos frecuentes automáticamente vía OneAgent.
**Resultado esperado:** Entidad PostgreSQL asociada al contenedor `postgres` del Compose.

### 4 — Redis

**Acción:** Localiza el contenedor/proceso **redis**. Compara su huella de CPU/memoria con Postgres bajo carga del lab.
**Por qué:** Refuerza lectura de infraestructura multi-componente antes de trazas en M04.
**Resultado esperado:** Redis visible; actividad acorde a `INCR`/`GET` del demo-api.

### 5 — Mapa mental vs Compose

**Acción:** Abre `infra/docker-compose.yml` en el Codespace y relaciona cada servicio con la entidad correspondiente en Dynatrace.
**Por qué:** Conecta definición declarativa (Compose) con observabilidad runtime.
**Resultado esperado:** Tabla mental: `demo-web` → nginx; `demo-api` → Python/Flask; `postgres` → DB; `redis` → cache; `loadgen` → tráfico sintético.

## Comprueba tu entendimiento

**Dependencia demo-api → Postgres**
En la ficha del proceso/servicio demo-api, identifica llamadas o conexiones hacia PostgreSQL (pestaña de conexiones, dependencias o Smartscape).
→ Dependencia visible hacia Postgres en el intervalo reciente.

**Carga periódica**
Genera tráfico extra manualmente:

```bash
for i in $(seq 1 20); do curl -sf http://127.0.0.1:8081/work; done
```

Vuelve a la métrica de throughput del proceso y confirma un pico.
→ Incremento visible en los últimos minutos.

## Reto

### 1 — Etiqueta operativa

Crea en Dynatrace un **host group** o convención de nombre (Settings → Monitoring → Host groups / naming), p. ej. prefijo `lab-`.

<details>
<summary>Ver orientación</summary>

En trial individual puede bastar renombrar el host o documentar el hostname del Codespace. En tenant compartido, host groups evitan mezclar entornos.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| No aparece PostgreSQL/Redis | Detección aún en curso | Espera 5–10 min; confirma contenedores UP |
| Proceso Python genérico | Sin nombre de servicio aún | Normal antes de M04; anota el PID/contenedor |
| Métricas planas | loadgen parado | `docker compose -f infra/docker-compose.yml ps` |
| Demasiados hosts | Tenant compartido sin grupos | Filtra por hostname del Codespace |

## Referencia

- Stack: `infra/docker-compose.yml`
- API de lab: `infra/demo-web/api.py` (endpoint `/work` toca Redis + Postgres)
