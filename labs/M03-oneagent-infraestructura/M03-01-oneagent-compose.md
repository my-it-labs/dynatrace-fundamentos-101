# M03-01 — OneAgent en Compose

[← Página anterior](README.md) · [Siguiente página →](M03-02-procesos-bases-datos.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**. El repo trae scripts y stack; **tú** despliegas el agente y validas en la UI.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| `infra/.env` | URL `.live.dynatrace.com` + `ONEAGENT_PAAS_TOKEN` |
| Stack Docker | `./scripts/lab-up.sh` OK (`demo-web` y `demo-api` :8080/:8081) |
| Dynatrace UI | Navegable (M01-02); **sin** datos propios del lab aún |
| `api.py` | Sin modificar — Flask sin OTel |

---

### Paso 1 — Desplegar OneAgent

| | |
|-|-|
| **Dónde** | Terminal, raíz del repo |
| **Acción** | `./scripts/oneagent-up.sh` luego `./scripts/oneagent-status.sh` |
| **Para qué** | Agente full-stack en contenedor privilegiado del Codespace |
| **Validar** | Contenedor `dynatrace-oneagent` **Up** (no `Restarting`) |
| **Comprender** | El script detecta Codespace y evita volumen Docker que falla en DinD |

Si falla → [TROUBLESHOOTING](../TROUBLESHOOTING.md#oneagent-no-arranca-o-reinicia-m03).

### Paso 2 — Agente conectado

| | |
|-|-|
| **Dónde** | <kbd>Ctrl</kbd>+<kbd>K</kbd> → **OneAgent health** |
| **Acción** | Comprueba **1 agente** conectado |
| **Para qué** | Confirmar tenant ↔ Codespace antes de mirar métricas |
| **Validar** | Gráfica/tarta con agente activo |
| **Comprender** | Sin este paso, Infrastructure puede seguir vacío |

### Paso 3 — Host del lab

| | |
|-|-|
| **Dónde** | **Infrastructure** → host `codespaces-…` |
| **Acción** | Revisa pestañas **Overview**, **Containers**, **Info** |
| **Para qué** | Ver el Codespace como entidad Dynatrace |
| **Validar** | Contenedores `infra-demo-api`, `postgres`, `redis`, `nginx` |
| **Comprender** | OneAgent **descubre** Docker sin configuración manual |

![Containers del lab](../img/M03-01-host-containers.png)

### Paso 4 — Límite: deep monitoring

| | |
|-|-|
| **Dónde** | Mismo host → pestaña **Processes** |
| **Acción** | Localiza `api.py` / nginx · mira columna **Deep monitoring** |
| **Para qué** | Anticipar por qué M04 necesita OTel |
| **Validar** | `api.py`: *Not applicable* o *Failed*; nginx: *Restart required* (arrancó antes que OneAgent; lo reinicias en el paso 5) |
| **Comprender** | Infra **sí**, instrumentación profunda Flask **no garantizada** en Codespace |

![Deep monitoring](../img/M03-01-processes-deep-monitoring.png)

### Paso 5 — Trazas solo nginx

| | |
|-|-|
| **Dónde** | Terminal, raíz del repo · luego **Distributed Tracing** → faceta **Service** = `localhost:80` |
| **Acción** | Reinicia nginx para que OneAgent lo instrumente: `docker compose -f infra/docker-compose.yml restart demo-web`. Espera 1–2 min y observa trazas `localhost:80` / `/` |
| **Para qué** | Prueba de que **algo** ya ingiere trazas (OneAgent) |
| **Validar** | Filas con Service `localhost:80`; en **Processes**, nginx ya no marca *Restart required* |
| **Comprender** | No confundir con demo-api; M04 instrumentará Flask |

---

## Cierre

| Pregunta | Respuesta |
|----------|-----------|
| ¿Host visible? | Sí |
| ¿Contenedores del lab? | Sí |
| ¿Flask en Services? | Aún no — normal |
| ¿Siguiente? | M03-02 → M04 (OTel en `api.py`) |

Validación local antes de seguir:

```bash
./scripts/validate-lab.sh m03
```

→ **[M03-02 — Procesos y bases de datos](M03-02-procesos-bases-datos.md)**

## Errores frecuentes

| Síntoma | Acción |
|---------|--------|
| `ONEAGENT_PAAS_TOKEN vacío` | Token PaaS en `.env` |
| Contenedor reinicia | [TROUBLESHOOTING](../TROUBLESHOOTING.md) |
| Services vacío | Normal hasta M04 |
