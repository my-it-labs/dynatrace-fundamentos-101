# Laboratorios — cómo están organizados

Cada lab sigue la misma lógica:

1. **Punto de partida (starter)** — qué hay en el repo y qué ya deberías tener hecho.
2. **Pasos** — tú ejecutas acciones en terminal, ficheros o UI Dynatrace.
3. Por paso: **dónde** · **acción** · **para qué** · **validar** · **comprender**.
4. **Cierre** — preguntas para comprobar que entiendes, no solo que “sale verde”.

El código de aplicación (`api.py`, etc.) llega en versión **starter**. Los cambios (p. ej. OpenTelemetry en M04) **los haces tú** siguiendo el lab.

Si algo falla → [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (diagnóstico paso a paso; no adivinar).

## Ruta del alumno (orden real)

> Los números de módulo **no** coinciden con el orden de todos los labs. Sigue esta secuencia.

| Paso | Qué hacer | Validación local |
|------|-----------|------------------|
| 1 | [M01-01](M01-entorno-codespace-plataforma/M01-01-bootstrap-entorno.md) Bootstrap | `./scripts/validate-lab.sh` |
| 2 | [M01-02](M01-entorno-codespace-plataforma/M01-02-navegacion-ui.md) UI Dynatrace | — |
| 3 | [M02 README](M02-arquitectura-smartscape/README.md) — **solo teoría** | — |
| 4 | [M03](M03-oneagent-infraestructura/README.md) OneAgent | `./scripts/validate-lab.sh m03` |
| 5 | [M02 labs](M02-arquitectura-smartscape/M02-01-smartscape-recorrido.md) Smartscape | `./scripts/oneagent-status.sh` |
| 6 | [M04](M04-aplicaciones-trazas-problemas/README.md) OTel + Problems | `./scripts/validate-lab.sh m04` |
| 7 | [M05-01](M05-kubernetes-operator/M05-01-kind-operator.md) kind + Operator | `./scripts/validate-lab.sh m05-01` |
| 7b | [M05-02](M05-kubernetes-operator/M05-02-workloads-kubernetes.md) Workloads K8s | `./scripts/validate-lab.sh m05` |
| 8 | [M06](M06-dashboards-alertas-logs/README.md) Dashboards + DQL | — |

**Atascado en M04 (OTel)?** Red de seguridad: [labs/solutions/M04/](solutions/M04/) o `./scripts/apply-m04-otel-solution.sh`.

| Módulo | Labs | ¿Modificas código? |
|--------|------|-------------------|
| M01 | Bootstrap, UI | `.env` solo |
| M02 | Smartscape, naming | No (**después de M03**) |
| M03 | OneAgent, procesos | No (scripts del repo) |
| M04 | Trazas, Problems | **Sí** — OTel en `api.py` |
| M05 | kind, Operator | `.env` + scripts |
| M06 | Dashboards, DQL | No |
