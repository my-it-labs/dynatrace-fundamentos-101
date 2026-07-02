# M01-02 — Primera navegación en Dynatrace

[← Página anterior](M01-01-bootstrap-entorno.md) · [Siguiente página →](../M02-arquitectura-smartscape/README.md)

> Práctica del módulo. **Lee primero** la [teoría y el mapa de la UI](README.md#teoria) del README —
> este lab asume que nunca has abierto Dynatrace.

### Objetivo

Entender **qué es cada zona de la pantalla**, saber **moverte sin perderte** y localizar las apps
que usarás en el curso. **No** necesitas ver datos de tus aplicaciones todavía.

### Prerrequisitos

- M01-01 completado **o**, como mínimo, tenant trial creado y sesión iniciada en el navegador.
- No hace falta haber ejecutado `./scripts/lab-up.sh` para completar este lab (pero sí para M03).

### En qué consiste

Un recorrido guiado por la interfaz: primero orientación, luego Launcher, búsqueda, una app de
infraestructura, un vistazo a trazas/logs/servicios y, por último, Settings. Al terminar sabrás
**dónde ir** cuando en M03–M06 te pidan «abre Distributed Tracing» o «mira los hosts».

> [!TIP]
> **Si te bloqueas:** usa siempre la **búsqueda global** (<kbd>Ctrl</kbd>+<kbd>K</kbd>) y escribe
> el nombre en inglés que aparece en el curso (p. ej. `Infrastructure`, `Logs`, `Settings`).

---

### 0 — Abrir tu tenant y reconocer la pantalla

**Acción:**

1. Abre la URL de tu tenant en el navegador. Suele ser una de estas formas:
   - `https://<tu-id>.live.dynatrace.com`
   - `https://<tu-id>.apps.dynatrace.com`
2. Inicia sesión si te lo pide.
3. Sin hacer clic en nada todavía, identifica **tres zonas** (de izquierda a derecha):

| Zona | Dónde está | Para qué sirve |
|------|------------|----------------|
| **Dock** (barra lateral izquierda) | Iconos verticales | Acceso rápido a Launcher, búsqueda y apps frecuentes |
| **Contenido principal** | Centro / derecha | La app que tengas abierta (Launcher, Hosts, Logs…) |
| **Cabecera de la app** | Arriba del contenido | Título, pestañas (Explorer, Settings…) y acciones |

**Qué es esto:** Dynatrace no es «una sola pantalla»: es un **conjunto de apps** dentro del mismo
tenant. Piensa en el dock como el menú de inicio y en cada app como un módulo (Hosts, Logs, etc.).

**Por qué:** Si no ubicas dock vs contenido, cada paso posterior parece magia. Este paso evita eso.

**Resultado esperado:** Ves el dock a la izquierda y, en el centro, la página **Getting started**
o **Launcher** (pantalla de bienvenida con bloques «OneAgent», «Explore apps», etc.).

![Launcher — pantalla de inicio](../img/M01-02-launcher-hub.png)

> [!IMPORTANT]
> **¿Por qué no veo mis apps Docker del lab?** Porque aún **no has instalado OneAgent** (M03).
> Dynatrace solo muestra lo que recibe telemetría. Vacío u «onboarding» en M01-02 es **normal**.

---

### 1 — Volver al Launcher cuando te pierdas

**Acción:**

1. En el **dock**, haz clic en el icono superior (**logo Dynatrace** / «Open Dynatrace»).
2. Si no estás en Launcher, también puedes usar el enlace **«13 days left in trial»** o **Home**
   (según tu versión) en el dock.
3. En el contenido principal, localiza la sección **Explore apps** (o similar). Ahí aparecen
   accesos a **Infrastructure & Operations**, **Logs**, **Distributed Tracing**, **Services**, etc.

**Qué es esto:** El **Launcher** es la página de inicio del tenant: onboarding + accesos a apps.
En versiones recientes sustituye al antiguo «Hub».

**Por qué:** Siempre puedes volver aquí como «mapa» del curso.

**Resultado esperado:** Identificas al menos tres apps que volverás a usar: **Infrastructure &
Operations**, **Distributed Tracing** y **Logs** (nombres en inglés en la UI).

---

### 2 — Búsqueda global (tu GPS dentro de Dynatrace)

**Acción:**

1. En el dock, haz clic en **Search** (lupa) **o** pulsa <kbd>Ctrl</kbd>+<kbd>K</kbd>
   (<kbd>Cmd</kbd>+<kbd>K</kbd> en Mac).
2. Se abre un panel central. Escribe `Infrastructure` (en inglés).
3. En la columna izquierda del panel, mira las categorías: **Apps**, **Settings**, etc.
4. Selecciona **Infrastructure & Operations** (categoría Apps).
5. Pulsa **Open** o <kbd>Enter</kbd> para abrir la app.
6. Cierra el panel con <kbd>Esc</kbd> si sigue visible.

**Qué es esto:** La búsqueda global no busca solo logs: navega **apps, ajustes y entidades** del
tenant. Es la forma más fiable de llegar a un sitio cuando la UI cambia de nombre.

**Por qué:** En M04–M06 irás más rápido escribiendo el nombre de la app que recorriendo menús.

**Resultado esperado:** El panel muestra resultados agrupados; al elegir la app, ves detalle a la
derecha y puedes abrirla.

![Búsqueda global — escribe Infrastructure](../img/M01-02-busqueda-global.png)

**Prueba tú (30 s):** Repite la búsqueda con `Logs` y con `Distributed Tracing`. Solo abre y
cierra; no hace falta configurar nada.

---

### 3 — Infrastructure & Operations → Hosts (infraestructura vacía)

**Acción:**

1. Abre **Infrastructure & Operations** (desde búsqueda, dock o Launcher).
2. En la cabecera de la app, entra en **Explorer** si no estás ya ahí.
3. En el panel izquierdo interno, expande **Compute** y elige **Hosts**.
4. Lee el mensaje central.

**Qué es esto:**

| Término | Significado sencillo |
|---------|----------------------|
| **Host** | Máquina o nodo donde corre software (tu Codespace, un VM, un nodo K8s) |
| **Explorer** | Vista de listado/filtros de entidades (hosts, procesos, contenedores…) |
| **No data available** | «Aún no recibo telemetría de hosts» — no es un error de login |

**Por qué:** En **M03**, tras instalar OneAgent sobre Docker, **aquí** debería aparecer el host del
Codespace. Si en M01-02 ya ves datos, probablemente son demo del trial, no del lab.

**Resultado esperado:** Lista vacía, mensaje **No data available** o botón **Install** / **+ Install**.
Cualquiera de esos estados es válido en M01-02.

![Infrastructure & Operations — Hosts (vacío antes de M03)](../img/M01-02-infrastructure-hosts.png)

---

### 4 — Tres apps que usarás más adelante (solo orientación)

**Acción:** Abre cada app desde el **dock** o la búsqueda global. Mira la pantalla **10 segundos**
y vuelve al Launcher. **No pulses** «Add traces», «Add logs» ni despliegues de demo salvo curiosidad.

| App (dock / búsqueda) | Qué guardarás en la cabeza | Módulo del curso |
|-----------------------|----------------------------|------------------|
| **Distributed Tracing** | Trazas entre servicios (API → base de datos) | M04 |
| **Logs** | Consulta de logs centralizados (DQL en M06) | M06 |
| **Services** | Servicios detectados automáticamente | M04 |

**Qué es esto:** Pantallas de **onboarding** («Get data into Dynatrace») o preview con datos de
**demo del vendor**. No confundas eso con tu stack `demo-web` / `demo-api` hasta M03.

**Por qué:** El curso no memoriza menús; memoriza **nombres de capacidad** + búsqueda global.

**Resultado esperado:** Reconoces las tres apps y su propósito aunque no tengan tus datos.

![Distributed Tracing — onboarding](../img/M01-02-distributed-tracing.png)

![Logs — onboarding](../img/M01-02-logs.png)

![Services — vista explorer / demo del tenant](../img/M01-02-services.png)

---

### 5 — Settings y tu environment

**Acción:**

1. Abre **Settings** (búsqueda global → `Settings`, o icono en el dock / Launcher → Manage Dynatrace).
2. En el panel izquierdo de Settings, entra en **General** → **Environment management**
   (si no lo ves, busca `Environment management` en el buscador **Search settings** de esa app).
3. Opcional: en el dock, abre el menú de **usuario** (abajo) y localiza el **ID del environment**
   (cadena corta tipo `abc12345`).

**Qué es esto:**

| Término | Significado sencillo |
|---------|----------------------|
| **Environment** | Tu «espacio» aislado dentro del tenant trial (configuración + datos) |
| **Environment ID** | Prefijo de la URL (`https://<ID>.apps.dynatrace.com`) — lo usarás en `.env` |
| **Settings** | Configuración de la plataforma (tokens, ventanas de mantenimiento, reglas…) |

**Por qué:** En M05–M06 volverás a Settings para tokens, alertas y naming. Saber llegar ahora evita
bloqueos después.

**Resultado esperado:** Ves la sección **Environment management** (p. ej. External requests,
Maintenance windows) y conoces tu **Environment ID**.

![Settings — General → Environment management](../img/M01-02-settings-environment.png)

---

## Comprueba tu entendimiento

**Mapa mental**
Sin mirar las capturas, responde (para ti):

1. ¿Dónde vuelves cuando te pierdes? → **Launcher** (icono Dynatrace en el dock).
2. ¿Cómo abres una app sin cazar menús? → **Búsqueda global** (<kbd>Ctrl</kbd>+<kbd>K</kbd>).
3. ¿Por qué Hosts está vacío? → **Falta OneAgent** (llega en M03).

**Apps clave**
Nombra tres apps del curso y para qué sirven:

→ **Infrastructure & Operations** (hosts/procesos), **Distributed Tracing** (trazas),
**Logs** (consulta de logs).

---

## Reto

### 1 — Atajo personal

Abre **Distributed Tracing** solo con el teclado: <kbd>Ctrl</kbd>+<kbd>K</kbd> → escribe
`Distributed` → <kbd>Enter</kbd>. Guarda la URL en un favorito del navegador.

<details>
<summary>Ver orientación</summary>

La URL será similar a `https://<tu-id>.apps.dynatrace.com/ui/apps/dynatrace.distributedtracing/`.
La usarás en M04.

</details>

---

## Errores frecuentes

| Síntoma | Qué significa en realidad | Qué hacer |
|---------|---------------------------|-----------|
| No veo categorías Apps/Settings en búsqueda | Panel abierto **sin escribir** nada | Escribe `Infrastructure` y mira la **columna izquierda** del modal |
| Busco categorías en el Launcher de fondo | Están en el **modal** de búsqueda, no en Getting started | Abre Search y escribe; o usa enlaces **Open …** del dock |
| «No data» / «Install OneAgent» | Normal en M01-02 | Sigue al **M03**; no es fallo tuyo |
| Pantallas llenas de onboarding | Trial sin telemetría propia | Ignora «Add data» por ahora; foco en **navegar** |
| No encuentro Preferences → Environment | Ruta antigua de la UI | Usa **Settings → General → Environment management** |
| Mezclo demo del tenant con mi lab | Preview/demo ≠ tu Compose | Tras M03, valida que ves el **host del Codespace** |

---

## Qué sigue

→ **[M02 — Arquitectura y Smartscape](../M02-arquitectura-smartscape/README.md)** (conceptos; datos
reales después de M03) · **[M03 — OneAgent](../M03-oneagent-infraestructura/README.md)** (aquí
conectas el lab con Dynatrace).
