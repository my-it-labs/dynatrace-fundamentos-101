# M01-01 — Bootstrap del entorno

[← Página anterior](README.md) · [Siguiente página →](M01-02-navegacion-ui.md)

> Práctica del módulo. La teoría está en el [README del módulo](README.md).
> **¿Primera vez con Dynatrace?** Haz primero el paso **2** (tenant + tokens) aunque el Codespace
> aún no esté listo.

> **Formato del lab:** cada paso indica **dónde** actuar, **qué** hacer, **para qué**, **cómo validar** y **qué comprender**.

---

## Punto de partida (starter)

| Elemento | Estado |
|----------|--------|
| Repo | Fork de `dynatrace-fundamentos-101` sin personalizar |
| Codespace | Aún no creado o recién creado |
| `infra/.env` | Plantilla vacía (desde `.env.example`) |
| Dynatrace | Trial por crear o recién creado |
| Stack Docker | No levantada |

**Al terminar este lab:** `.env` con URL y tokens, `lab-up.sh` OK, `health-check` con demo-web y demo-api en verde.

---

### Objetivo

Dejar operativo tu fork, Codespace, tenant Dynatrace (URL + tokens en `.env`) y stack Docker del curso.

### Prerrequisitos

- Cuenta GitHub.
- Navegador (para crear el trial y copiar tokens).

### En qué consiste

Fork → Codespace → **crear tenant y tokens con calma** → rellenar `infra/.env` → levantar Compose →
validar con `health-check.sh`.

---

### 1 — Fork y Codespace

**Acción:** Haz fork de `my-it-labs/dynatrace-fundamentos-101`, abre **Code → Codespaces → Create codespace on main**.

**Por qué:** Trabajas en tu propia copia y conservas el material al finalizar.

**Resultado esperado:** Terminal en `/workspaces/dynatrace-fundamentos-101` (o nombre de tu fork).

---

### 2 — Tenant Dynatrace (trial)

**Acción:**

1. Abre [dynatrace.com/signup](https://www.dynatrace.com/signup/) y crea el trial (email + verificación).
2. Tras el registro, Dynatrace te lleva a tu **tenant** (interfaz web).
3. Mira la **barra de direcciones** del navegador. Anota:

| Qué anotar | Ejemplo | Variable `.env` |
|------------|---------|---------------|
| **URL del tenant** | `https://<tu-id>.live.dynatrace.com` (recomendado en `.env`) | `DYNATRACE_ENVIRONMENT_URL` |
| **Environment ID** | `<tu-id>` (prefijo antes de `.live` o `.apps`) | `DYNATRACE_ENVIRONMENT_ID` |

**Qué es esto:** El **tenant** es tu cuenta cloud. El **environment ID** es el identificador corto del
entorno de prácticas dentro de ese tenant.

**Por qué:** Los scripts del curso llaman a la API de **esa** URL; un carácter mal puesto falla en M03.

**Resultado esperado:**

- Puedes iniciar sesión y ves el **Launcher** (Getting started).
- Tienes copiados URL e ID en un gestor de contraseñas o borrador **local** (no en git, no en el chat).

> [!WARNING]
> **Formato correcto de URL**
> - ✅ En `infra/.env` usa **`https://<id>.live.dynatrace.com`** (aunque el navegador muestre `.apps.dynatrace.com`)
> - ✅ El `<id>` debe coincidir **carácter a carácter** con la barra de direcciones (un dígito mal → fallo en M03)
> - ❌ `https://<id>.apps.dynatrace.com/ui/apps/...` (eso es una **página**, no la URL base)
> - ❌ Barra final `/` al end

---

### 2b — Qué tokens necesitas (mapa del curso)

Un **token** es una contraseña larga que permite a scripts/agentes hablar con tu tenant **sin** usar tu
usuario/contraseña de login.

| Variable en `infra/.env` | Para qué sirve | ¿Cuándo lo usas? |
|--------------------------|----------------|------------------|
| `ONEAGENT_PAAS_TOKEN` | Instalar **OneAgent** en Docker | **M03** |
| `DYNATRACE_API_TOKEN` | **Operator** / API plataforma | **M05** |
| `DYNATRACE_INGEST_TOKEN` | Trazas **OTel** en demo-api + Operator M05 | **M04** y **M05** |

**En M01-01 genera los tres ya** y guárdalos en `.env`. Así no interrumpes el curso en M03/M05.
**Nadie los usa** hasta esos módulos, pero crear tokens requiere entender la UI — mejor hacerlo ahora.

> [!IMPORTANT]
> Cada token se muestra **completo una sola vez** al crearlo. Si lo pierdes, **genera otro** y
> actualiza `.env`.

---

### 2c — Llegar a «Access tokens» (ruta común)

**Acción** (elige una):

**Opción A — Búsqueda global (recomendada)**

1. <kbd>Ctrl</kbd>+<kbd>K</kbd> → escribe `Access tokens`.
2. Abre el resultado **Access tokens** bajo **Settings** (no confundir con «Personal Access Tokens» del
   usuario si solo quieres tokens de plataforma).

**Opción B — Menú Settings**

1. Abre la app **Settings** (dock o Launcher → Manage Dynatrace).
2. En el panel izquierdo: **Environment segmentation** → **Access control** → **Access tokens**.

**Resultado esperado:** Página **Access tokens** con botón **Generate new token** / **Generate token** (lista de tokens existentes).

> Si solo ves **toggles** de configuración (sin lista ni botón generar), estás en Settings →
> Environment segmentation. Usa <kbd>Ctrl</kbd>+<kbd>K</kbd> → `Access tokens` (app con lista AT).

![Settings → Access tokens](../img/M01-01-access-tokens.png)

---

### 2d — Crear `ONEAGENT_PAAS_TOKEN` (OneAgent / M03)

**Acción:**

1. En **Access tokens**, pulsa **Generate token** (o equivalente).
2. **Nombre sugerido:** `curso-oneagent-paas`
3. **Tipo / template:** elige **PaaS** (a veces aparece como tipo de instalación PaaS / OneAgent en
   contenedores). Si la UI ofrece plantillas, selecciona la relacionada con **OneAgent** o **PaaS**.
4. **Scopes / permisos:** acepta los que la plantilla PaaS marca por defecto (instalación de OneAgent).
5. Confirma y **copia el token** inmediatamente a tu gestor seguro.

**Qué es esto:** Autoriza al contenedor `dynatrace/oneagent` del curso a **descargar e instalar**
OneAgent en tu Codespace.

**Por qué:** Sin PaaS token, `scripts/oneagent-up.sh` falla en M03 aunque Docker esté bien.

**Resultado esperado:** Cadena larga (decenas de caracteres) guardada; pegarás en `.env` en el paso 3.

**Alternativa guiada:** Launcher → tarjeta **OneAgent** → **Set up** → **Linux** / **Docker** — el
asistente también muestra cómo generar el token PaaS (mismo valor).

---

### 2e — Crear `DYNATRACE_API_TOKEN` y `DYNATRACE_INGEST_TOKEN` (Operator / M05)

Tienes **dos caminos**. Usa **A** si prefieres que Dynatrace marque los scopes; **B** si quieres control manual.

#### Opción A — Asistente Kubernetes (recomendado para principiantes)

**Acción:**

1. Abre la app **Kubernetes** → **Add cluster**.
2. **Step 1 — Select distribution:** elige **Other distributions**.
3. **Step 2 — Select observability options:** deja **Full-Stack observability** (recomendado).
4. **Step 3 — Configure cluster:** pon un nombre (p. ej. `curso-lab-kind`); **Cluster size** → **Medium**.
5. **Step 4 — Install Dynatrace Operator** (pantalla de la captura):

| En la pantalla de Dynatrace | Qué haces | Variable en `infra/.env` |
|-----------------------------|-----------|--------------------------|
| **Dynatrace Operator token** | Pulsa **Generate token** → icono **copiar** | `DYNATRACE_API_TOKEN=` |
| **Data ingest token** | Pulsa **Generate token** → icono **copiar** | `DYNATRACE_INGEST_TOKEN=` |

6. Pega **inmediatamente** ambos valores en `infra/.env` (paso 3). **No cierres** el asistente hasta
   haberlos copiado: **solo se muestran una vez**.

> [!NOTE]
> **¿Y si no hay botón «Guardar» o «Continuar» claro?** Normal. Este asistente **no persiste tu
> progreso** como un formulario: es una guía de instalación. Lo único que importa para el curso en M01:
> **(1)** pulsar **Generate token** en cada fila, **(2)** copiar ambos valores a `infra/.env`.
> Después puedes **cerrar la pestaña** o salir del wizard — no tienes que ejecutar `kubectl` ni
> **Download dynakube.yaml** hasta **M05**.
>
> **Qué queda guardado en Dynatrace:** los tokens creados (revocables en **Settings → Access tokens**).
> **Qué debes guardar tú:** el texto del token en `.env` (Dynatrace **no** vuelve a mostrar el valor
> completo).

> [!WARNING]
> **No hace falta** pulsar **Download dynakube.yaml** ni ejecutar los comandos `kubectl` / Helm de
> esta pantalla para M01. El curso usa `scripts/operator-up.sh` y `infra/k8s/dynakube.yaml.tpl` en **M05**.
> Aquí solo necesitas **los dos tokens**.

![Kubernetes wizard — Step 4 tokens (valores redactados en captura)](../img/M01-01-kubernetes-tokens-wizard.png)

**Qué es cada uno:**

| Token del asistente | Variable `.env` |
|---------------------|-----------------|
| Dynatrace Operator token | `DYNATRACE_API_TOKEN` |
| Data ingest token | `DYNATRACE_INGEST_TOKEN` |

**Por qué:** El asistente crea tokens con scopes correctos para **Dynatrace Operator** y **Grail ingest**.

**Resultado esperado:** Dos tokens distintos guardados en `.env` (no uses el PaaS de 2d en su lugar).

#### Opción B — Manual en Access tokens

**Acción:** Genera **dos** tokens en **Access tokens** (lista con **Generate new token**, no la pantalla de toggles en Environment segmentation):

**Ingest (M04/M05):** nombre `curso-otel-ingest` → scope **`openTelemetryTrace.ingest`** (busca en el buscador de scopes).

**API (M05):** scopes `ReadConfig`, `WriteConfig` mínimo.

1. **`curso-operator-api`** — tipo **API** con scopes mínimos:
   - `ReadConfig`
   - `WriteConfig`
   - (si la UI lo ofrece) `ReadSettings`, `WriteSettings`
2. **`curso-ingest`** — tipo **Ingest** / API con scopes:
   - `metrics.ingest`
   - `logs.ingest`
   - `openTelemetryTrace.ingest`

**Resultado esperado:** Dos tokens distintos asignados a `DYNATRACE_API_TOKEN` y `DYNATRACE_INGEST_TOKEN`.

> [!TIP]
> Si solo ves un tipo «API» genérico, crea **dos tokens API** con scopes distintos (lista de arriba).
> Lo crítico es **no mezclar** PaaS con API/Ingest.

---

### 3 — Configurar `infra/.env`

**Acción:** En el Codespace (o localmente):

```bash
cp infra/.env.example infra/.env
nano infra/.env   # o el editor que prefieras
```

Rellena **como mínimo** (con tus valores reales):

```bash
DYNATRACE_ENVIRONMENT_URL=https://<TU-ID>.apps.dynatrace.com
DYNATRACE_ENVIRONMENT_ID=<TU-ID>
ONEAGENT_PAAS_TOKEN=dt0c01.xxxxx
DYNATRACE_API_TOKEN=dt0c01.xxxxx
DYNATRACE_INGEST_TOKEN=dt0c01.xxxxx
```

**Por qué:** Los scripts leen este fichero; `.env` está en `.gitignore` para no filtrar secretos.

**Resultado esperado:**

```bash
source infra/.env
echo "$DYNATRACE_ENVIRONMENT_URL"
echo "${ONEAGENT_PAAS_TOKEN:0:8}..."   # solo prefijo, no pegues el token en el chat
```

→ Muestra tu URL y un prefijo del token (comprueba que no está vacío).

---

### 4 — Levantar el lab

**Acción:** Desde la raíz del repo:

```bash
./scripts/lab-up.sh
./scripts/health-check.sh
```

**Por qué:** Despliega demo-web, demo-api, Postgres, Redis y loadgen. **Aún no** envían datos a Dynatrace
(hasta M03).

**Resultado esperado:** `demo-web :8080 OK` y `demo-api :8081 OK`.

---

## Comprueba tu entendimiento

**Stack en marcha**
Ejecuta `docker compose -f infra/docker-compose.yml ps`.
→ Cinco servicios `running` sin reinicios en bucle.

**Tokens preparados**
Abre `infra/.env` y verifica que **URL, ID y tres tokens** no están vacíos.
→ Listo para M03 y M05 sin volver a la UI (salvo regenerar un token revocado).

---

## Reto

### 1 — Identifica tu entorno

Anota (para ti) el environment ID y la URL pública del puerto **8080** que Codespaces reenvía al demo-web.

<details>
<summary>Ver orientación</summary>

El ID es el prefijo de la URL del tenant. El puerto 8080 aparece en la pestaña **Ports** del Codespace.

</details>

---

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `demo-api FAIL` | Postgres aún no healthy | Espera 30 s y repite health-check |
| Docker permission denied | Daemon no listo tras crear Codespace | Reabre terminal o espera postCreate |
| URL tenant incorrecta | Copiaste `/ui/...` o el ID no coincide | Usa `https://<id>.live.dynatrace.com`; si M03 falla, ver [TROUBLESHOOTING](../TROUBLESHOOTING.md) |
| No encuentro «Generate token» | Estás en Personal Access Tokens | Usa **Settings → Access tokens** (paso 2c) |
| Mezclé tokens | Mismo valor en PaaS y API | Genera tres tokens **distintos** (pasos 2d y 2e) |
| Perdí el token | Solo se muestra una vez al crear | Genera uno nuevo y actualiza `.env` |
| OneAgent fallará en M03 | Token no es tipo PaaS | Regenera con plantilla **PaaS** (paso 2d) |
| Operator fallará en M05 | API sin ReadConfig/WriteConfig | Regenera con asistente K8s o scopes del paso 2e |

---

## Qué sigue

→ **[M01-02 — Primera navegación](M01-02-navegacion-ui.md)** (mapa de la UI; ya tienes tenant y tokens).
