# M04-02 — Problems Davis

[← Página anterior](M04-01-servicios-trazas.md) · [Siguiente página →](../M05-kubernetes-operator/README.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| M04-01 | Completado — OTel en `api.py`, spans `GET /work` visibles |
| Endpoints | `/fail` y `/slow` disponibles sin cambios de código |

---

### Objetivo

Provocar un problem en el lab, analizar impacto y causa raíz sugerida por Davis, y proponer acción correctiva.

### Prerrequisitos

- M04-01 completado.

### En qué consiste

Induces errores y latencia, monitorizas **Problems**, abres el detalle del problem y lo relacionas con trazas y servicio demo-api.

### 1 — Inducir fallos

**Acción:** Ejecuta durante 2–3 minutos:

```bash
for i in $(seq 1 60); do
  curl -sf http://127.0.0.1:8081/fail >/dev/null || true
  curl -sf http://127.0.0.1:8081/slow >/dev/null || true
  sleep 2
done
```

**Por qué:** `/fail` (HTTP 500) y `/slow` (latencia) son señales que Davis puede correlacionar.
**Resultado esperado:** Tráfico de error y latencia visible en el servicio.

### 2 — Abrir Problems

**Acción:** En Dynatrace, abre **Problems**. Filtra por timeframe reciente y estado **Open** o **Closed** (última hora).
**Por qué:** Problems es la vista operativa principal para incidentes automáticos.
**Resultado esperado:** Al menos un problem relacionado con demo-api, latencia o failure rate.

> [!IMPORTANT]
> **Tenant recién creado:** Davis necesita *baseline* del servicio y puede **no abrir ningún
> problem** aunque `/fail` devuelva 500 durante minutos (comprobado en un trial nuevo). Si a los
> 5 min sigues con «No matching problems», usa el **plan B**.

#### Plan B — Abrir un problem con un evento de error

1. **Access tokens → Generate new token**, nombre `curso-events`, Template **None**, busca y marca
   el scope **`events.ingest`** → **Generate token** → copia el valor.
2. Pégalo en `infra/.env` como `DYNATRACE_EVENTS_TOKEN=`.
3. Ejecuta:

```bash
./scripts/raise-problem.sh
```

**Resultado esperado:** `"status":"OK"` en la terminal y, en ~30 s, un problem
**«Lab M04-02: demo-api devuelve HTTP 500»** (categoría **Error**, afecta al host `codespaces-…`).
Sigue con los pasos 3–5 sobre ese problem.

### 3 — Analizar impacto

**Acción:** Abre el problem. Lee **Impact** (servicios/host afectados) y **Severity**.
**Por qué:** Priorizas según blast radius, no solo el síntoma.
**Resultado esperado:** demo-api (o servicio equivalente) listado como afectado.

### 4 — Root cause

**Acción:** Revisa la sección **Root cause** / **Cause** de Davis. Expande evidencias (métricas, trazas, eventos).
**Por qué:** Associate exige explicar *por qué* ocurrió, no solo *qué* falló.
**Resultado esperado:** Causa coherente (p. ej. aumento de response time o error rate en demo-api).

### 5 — Evidencia en trazas

**Acción:** Desde el problem, salta a **Related traces** o abre Distributed traces filtrando errores (`failed` / status 5xx).
**Por qué:** Cierras el ciclo Problem → PurePath → endpoint `/fail`.
**Resultado esperado:** Trazas con status 500 en `/fail`.

## Comprueba tu entendimiento

**Acción recomendada**
En una frase, ¿qué harías en producción si `/fail` fuera un bug real? (rollback, fix, scale…)
→ Respuesta operativa razonable vinculada al síntoma observado.

## Reto

### 1 — Cerrar el ciclo

Tras detener el bucle de errores, observa si el problem se **cierra** automáticamente tras unos minutos.
→ Problem pasa a resolved/closed cuando las métricas vuelven a baseline.

<details>
<summary>Ver orientación</summary>

Davis usa baselines; al cesar `/fail`, la tasa de error debería normalizarse y el problem cerrarse solo.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| No aparece problem | Baseline aún aprendiendo (tenant nuevo) | Plan B: `./scripts/raise-problem.sh` |
| Problem genérico | Mucho ruido en host | Filtra por servicio demo-api |
| Root cause vacía | Pocos datos | Mantén carga + espera ingest |
