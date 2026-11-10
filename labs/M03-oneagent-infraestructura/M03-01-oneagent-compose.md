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

### Paso 1 — Qué te ofrece Dynatrace para instalar OneAgent

| | |
|-|-|
| **Dónde** | Dynatrace → dock → **Discovery & Coverage** → botón **+ Install** (arriba a la derecha) → **OneAgent** |
| **Acción** | Asistente **Install OneAgent** (4 pasos: sistema operativo y arquitectura · Configure agent · Download and setup · Install). Elige **Linux / x86** y recórrelo **sin ejecutar nada**: fíjate en el token PaaS, el comando de descarga (`wget … Dynatrace-OneAgent-Linux.sh`), el de instalación (`sudo /bin/sh Dynatrace-OneAgent-Linux.sh …`) y los parámetros opcionales (p. ej. `--set-host-group`) |
| **Para qué** | Es el camino estándar en una VM o servidor Linux: descargar el instalador desde **tu** tenant y ejecutarlo como root |
| **Validar** | Identificas las tres piezas: **URL del instalador**, **token PaaS** y **parámetros** |
| **Comprender** | En el Codespace **no** puedes usar ese instalador nativo: estás dentro de un contenedor, sin systemd y con Docker anidado. Usarás la variante oficial **OneAgent como contenedor Docker**, que necesita **las mismas tres piezas** |

> Si no encuentras el botón, <kbd>Ctrl</kbd>+<kbd>K</kbd> → `Discovery & Coverage`. Ojo: buscar `OneAgent`
> lleva a **Fleet Management** u **OneAgent Health** (gestión de agentes ya instalados), no al asistente.
> Documentación oficial: [OneAgent como contenedor Docker](https://docs.dynatrace.com/docs/ingest-from/setup-on-container-platforms/docker/set-up-dynatrace-oneagent-as-docker-container).

### Paso 2 — Desplegar OneAgent a mano

| | |
|-|-|
| **Dónde** | Terminal del Codespace, raíz del repo |
| **Acción** | Carga tus variables y construye la URL del instalador (las mismas piezas del paso 1) |
| **Para qué** | Ver de dónde sale cada valor antes de lanzar el agente |
| **Validar** | El `echo` muestra una URL de **tu** tenant y el prefijo del token no está vacío |

```bash
set -a; source infra/.env; set +a
INSTALLER_URL="${DYNATRACE_ENVIRONMENT_URL%/}/api/v1/deployment/installer/agent/unix/default/latest?arch=x86&flavor=default"
echo "$INSTALLER_URL"
echo "${ONEAGENT_PAAS_TOKEN:0:8}..."
```

**Acción:** Lanza el contenedor oficial `dynatrace/oneagent`:

```bash
docker run -d \
  --name dynatrace-oneagent \
  --restart=unless-stopped \
  --privileged \
  --pid=host \
  --network=host \
  -v /:/mnt/root \
  -e ONEAGENT_ENABLE_VOLUME_STORAGE=false \
  -e ONEAGENT_INSTALLER_SCRIPT_URL="$INSTALLER_URL" \
  -e ONEAGENT_INSTALLER_DOWNLOAD_TOKEN="$ONEAGENT_PAAS_TOKEN" \
  dynatrace/oneagent
```

| Flag / variable | Por qué la necesita OneAgent |
|-----------------|------------------------------|
| `--privileged` | Acceso ampliado al host (requisito de full-stack monitoring) |
| `--pid=host` | Ver **todos** los procesos del host, no solo los suyos |
| `--network=host` | Ver el tráfico de red real de las apps |
| `-v /:/mnt/root` | Acceder al sistema de ficheros del host para descubrir e instrumentar procesos |
| `ONEAGENT_INSTALLER_SCRIPT_URL` | De dónde descarga el instalador: **tu** tenant (paso 1) |
| `ONEAGENT_INSTALLER_DOWNLOAD_TOKEN` | Token **PaaS** que autoriza la descarga |
| `ONEAGENT_ENABLE_VOLUME_STORAGE=false` | Solo para el Codespace: el volumen persistente falla con Docker anidado |

**Validar:**

```bash
docker ps --filter name=dynatrace-oneagent
docker logs --tail 20 dynatrace-oneagent
```

Contenedor **Up** (no `Restarting`). La primera descarga tarda 1–3 min.

**Comprender:** Has hecho lo mismo que el asistente del paso 1, adaptado a contenedor: tenant +
token PaaS + instalador. En Kubernetes (M05), el **Operator** automatiza este mismo patrón.

> [!TIP]
> **¿Atascado?** `./scripts/oneagent-up.sh` hace exactamente lo mismo que este paso (léelo: está
> comentado línea a línea). Si el contenedor reinicia →
> [TROUBLESHOOTING](../TROUBLESHOOTING.md#oneagent-no-arranca-o-reinicia-m03).

### Paso 3 — Agente conectado

| | |
|-|-|
| **Dónde** | <kbd>Ctrl</kbd>+<kbd>K</kbd> → **OneAgent health** |
| **Acción** | Comprueba **1 agente** conectado |
| **Para qué** | Confirmar tenant ↔ Codespace antes de mirar métricas |
| **Validar** | Gráfica/tarta con agente activo |
| **Comprender** | Sin este paso, Infrastructure puede seguir vacío |

### Paso 4 — Host del lab

| | |
|-|-|
| **Dónde** | **Infrastructure** → host `codespaces-…` |
| **Acción** | Revisa pestañas **Overview**, **Containers**, **Info** |
| **Para qué** | Ver el Codespace como entidad Dynatrace |
| **Validar** | Contenedores `infra-demo-api`, `postgres`, `redis`, `nginx` |
| **Comprender** | OneAgent **descubre** Docker sin configuración manual |

![Containers del lab](../img/M03-01-host-containers.png)

### Paso 5 — Límite: deep monitoring

| | |
|-|-|
| **Dónde** | Mismo host → pestaña **Processes** |
| **Acción** | Localiza `api.py` / nginx · mira columna **Deep monitoring** |
| **Para qué** | Anticipar por qué M04 necesita OTel |
| **Validar** | `api.py`: *Not applicable* o *Failed*; nginx: *Restart required* (arrancó antes que OneAgent; lo reinicias en el paso 6) |
| **Comprender** | Infra **sí**, instrumentación profunda Flask **no garantizada** en Codespace |

![Deep monitoring](../img/M03-01-processes-deep-monitoring.png)

### Paso 6 — Trazas solo nginx

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
