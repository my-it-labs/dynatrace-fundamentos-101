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

**Acción:** En Dynatrace, abre **Smartscape** (o **Topology** / mapa de entidades según tu versión de UI). Filtra o busca el **host** de tu Codespace.
**Por qué:** Smartscape muestra relaciones dinámicas, no solo listas aisladas.
**Resultado esperado:** Nodo de host visible con entidades hijas.

### 2 — Expandir contenedores

**Acción:** Expande el host hasta ver contenedores del Compose (`demo-api`, `postgres`, `redis`, `demo-web`).
**Por qué:** Confirma que OneAgent mapea Docker al modelo de entidades Dynatrace.
**Resultado esperado:** Al menos cuatro contenedores del lab bajo el mismo host.

### 3 — Seguir dependencia hacia Postgres

**Acción:** Desde el nodo de **demo-api** (proceso o contenedor), sigue la dependencia hacia **PostgreSQL** si aparece en el mapa.
**Por qué:** Anticipa el análisis de trazas de extremo a extremo en M04.
**Resultado esperado:** Arista o enlace demo-api → Postgres (puede tardar unos minutos con carga).

### 4 — Correlacionar con tráfico

**Acción:** Ejecuta en terminal:

```bash
for i in $(seq 1 30); do curl -sf http://127.0.0.1:8081/work >/dev/null; done
```

Refresca Smartscape y observa actividad en demo-api.
**Por qué:** Valida que el mapa refleja carga real, no solo inventario estático.
**Resultado esperado:** Indicador de actividad/reciente en demo-api tras el bucle.

## Comprueba tu entendimiento

**Camino host → DB**
Describe en una frase el camino que ves de host a PostgreSQL pasando por demo-api.
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
| Sin aristas a Postgres | Poca carga o delay | Ejecuta bucle curl y espera 3–5 min |
| Nombres `infra-*` confusos | Prefijo de proyecto Compose | Normal; filtra por `demo` o `postgres` |
