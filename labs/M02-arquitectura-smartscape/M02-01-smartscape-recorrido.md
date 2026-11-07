# M02-01 — Recorrido Smartscape

[← Página anterior](README.md) · [Siguiente página →](M02-02-entidades-naming.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| M03-01 | Completado — OneAgent + contenedores visibles |
| Smartscape | Sin recorrer aún |
| `api.py` | Starter sin OTel |

**Validar antes de empezar:** Infrastructure muestra host `codespaces-…` con contenedores del lab.

---

### Objetivo

Recorrer la topología del laboratorio en Smartscape (o vista equivalente de mapa) de host a bases de datos.

### Prerrequisitos

- M03-01 completado; stack demo en marcha.

### En qué consiste

Navegas desde el host del Codespace hasta procesos y dependencias, identificando el camino que seguirá una petición antes de analizar trazas en M04.

### 1 — Abrir Smartscape

| | |
|-|-|
| **Dónde** | Dynatrace → <kbd>Ctrl</kbd>+<kbd>K</kbd> → `Smartscape` |
| **Acción** | Abre la app **Smartscape** → vista ready-made **Infrastructure overview** |
| **Para qué** | Smartscape muestra relaciones dinámicas, no solo listas aisladas |
| **Validar** | Grafo con un nodo de región (p. ej. `westeurope · 1 HOST`) |
| **Comprender** | Es la misma topología que verás en incidentes reales |

**Acción (continuación):** Haz doble clic en la región para expandirla hasta el **host**.

**Resultado esperado:** Nodo de host. Ojo: aquí aparece con el **identificador de la VM**
(`c498fdee-…`), no con el nombre `codespaces-…` que ves en **Infrastructure & Operations**.
Es la misma máquina: dos atributos distintos de la misma entidad.

### 2 — Contenedores y procesos del host

**Acción:** Abre **Infrastructure & Operations → Hosts →** tu host `codespaces-…` → pestaña **Containers** y luego **Processes**.
**Por qué:** Confirma que OneAgent mapea Docker al modelo de entidades Dynatrace.
**Resultado esperado:** Contenedores `infra-demo-api-1`, `postgres`, `redis`, `nginx` y procesos `api.py`, `Postgres`, `Redis`, `nginx`.

### 3 — ¿Y la dependencia demo-api → Postgres?

**Acción:** Abre **Smartscape → Service dependency graph**. Fíjate en qué servicios aparecen y si hay aristas entre ellos.
**Por qué:** En el Codespace la monitorización de red de OneAgent (NetTracer) está desactivada y Flask aún no está instrumentado, así que el mapa **no** dibuja la llamada a Postgres.
**Resultado esperado:** Servicios sueltos (`localhost:80`, …) sin aristas hacia la base de datos. La dependencia la verás en **M04** como span `SELECT` dentro de la traza `GET /work`.

### 4 — Correlacionar con tráfico

**Acción:** Ejecuta en terminal:

```bash
for i in $(seq 1 30); do curl -sf http://127.0.0.1:8081/work >/dev/null; done
```

Vuelve a la pestaña **Processes** del host y observa CPU de `api.py`, `Postgres` y `Redis`.
**Por qué:** Valida que la topología refleja carga real, no solo inventario estático.
**Resultado esperado:** Subida visible de CPU/red en esos procesos tras el bucle.

## Comprueba tu entendimiento

**Camino host → DB**
Describe en una frase el camino host → demo-api → PostgreSQL según `infra/docker-compose.yml` y lo que viste en Processes.
→ Secuencia lógica coherente con `infra/docker-compose.yml`.

## Reto

### 1 — Captura mental del mapa

Sin hacer screenshot, anota los tres nodos más importantes en una respuesta a incidente (host, servicio/proceso crítico, base de datos).

<details>
<summary>Ver orientación</summary>

Ejemplo: host Codespace → demo-api (Python) → PostgreSQL; Redis como dependencia lateral.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| Mapa vacío | OneAgent no conectado | Repite M03-01 |
| Sin aristas a Postgres | Normal en Codespace (sin NetTracer ni OTel aún) | Lo verás en M04 como span `SELECT` |
| Nombres `infra-*` confusos | Prefijo de proyecto Compose | Normal; filtra por `demo` o `postgres` |
