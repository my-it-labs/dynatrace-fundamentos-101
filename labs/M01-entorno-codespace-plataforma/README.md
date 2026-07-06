# M01 — Entorno del curso y plataforma Dynatrace

[← Página anterior](../../README.md) · [Siguiente página →](M01-01-bootstrap-entorno.md)

> [!NOTE]
> **Cómo funciona este módulo.** Lee la **teoría** y después los **laboratorios** paso a paso
> (cada lab indica dónde actuar, qué validar y qué comprender).

## Qué aprenderás

- Preparar tu fork y Codespace con la infraestructura del curso.
- Configurar un tenant **Dynatrace SaaS trial** y los tokens del laboratorio.
- Levantar la stack demo (web, API, Postgres, Redis, carga).
- **Orientarte en Dynatrace aunque nunca lo hayas usado** (Launcher, búsqueda, apps clave).

## Teoría

### ¿Qué es Dynatrace en una frase?

Es una plataforma en la **nube (SaaS)** donde **ves** el estado de tus aplicaciones e
infraestructura: métricas, trazas, logs y problemas detectados automáticamente. **No sustituye**
a tu servidor ni a Docker: **observa** lo que ya tienes desplegado.

### Modelo mental (imprescindible antes del M01-02)

```text
  Tu Codespace (Docker / kind)          Tenant Dynatrace (navegador)
  ┌─────────────────────────┐          ┌─────────────────────────┐
  │ demo-web, demo-api, …   │  ──────► │ Apps: Hosts, Traces, Logs │
  │ + OneAgent (desde M03)  │  datos   │ Problems, Dashboards, …   │
  └─────────────────────────┘          └─────────────────────────┘
         ▲                                      ▲
    Donde CORREN las apps                 Donde MIRAS las apps
```

Hasta que no instalas **OneAgent** (M03), la flecha de datos **no existe**: la UI puede estar vacía
o mostrar solo onboarding/demo del trial. **Eso no significa que lo hayas hecho mal.**

### Piezas del curso

| Componente | Qué es | Cuándo entra |
|------------|--------|--------------|
| **Tenant SaaS** | Tu cuenta cloud de Dynatrace (trial) | M01-01 |
| **Environment** | Espacio lógico dentro del tenant; tiene un **ID** en la URL | M01-02 |
| **OneAgent** | Agente que envía telemetría desde hosts/contenedores | M03 |
| **Operator** | Instala/configura monitorización en Kubernetes | M05 |
| **Codespace** | Máquina remota donde corre Docker y kind | M01-01 |

### Tokens (antes de M03/M05)

Los scripts **no** usan tu usuario/contraseña de login. Necesitas **tres tokens** en `infra/.env`
(generación paso a paso en **[M01-01 — pasos 2b–2e](M01-01-bootstrap-entorno.md#2b--qué-tokens-necesitas-mapa-del-curso)**):

| Token | Uso |
|-------|-----|
| PaaS | OneAgent en Docker (M03) |
| API | Dynatrace Operator (M05) |
| Ingest | Trazas OTel (M04) y Grail (M05) |

> [!IMPORTANT]
> No instalamos **Dynatrace Managed** en el Codespace. La plataforma vive en el trial SaaS; el
> Codespace solo ejecuta tus apps y agentes.

### Anatomía de la interfaz (mapa para el lab M01-02)

Cuando abres la URL del tenant, verás **tres ideas** repetidas en todo el curso:

| Elemento | Cómo reconocerlo | Para qué lo usarás |
|----------|------------------|-------------------|
| **Dock** | Barra estrecha de iconos a la izquierda | Ir a Launcher, Search, apps ancladas |
| **Launcher** | Página «Getting started» / «Explore apps» | Mapa de apps; vuelves aquí si te pierdes |
| **Búsqueda global** | Lupa o <kbd>Ctrl</kbd>+<kbd>K</kbd> | Abrir cualquier app sin memorizar menús |
| **App** | Pantalla con título (Logs, Services, …) | Trabajo concreto (hosts, trazas, DQL…) |
| **Settings** | App de engranaje / «Manage Dynatrace» | Tokens, environment, alertas (M05–M06) |

**Launcher vs Hub:** en tenants recientes el inicio se llama **Launcher** (antes «Hub»). En el curso
usamos **Launcher**.

**Apps que debes ubicar ya** (aunque estén vacías):

| App en la UI | Qué observa |
|--------------|-------------|
| **Infrastructure & Operations** | Hosts, procesos, contenedores |
| **Distributed Tracing** | Trazas entre servicios |
| **Logs** | Logs centralizados |
| **Services** | Servicios detectados (API, workers…) |
| **Settings** | Configuración del environment |

### Conceptos que suelen confundir

| Confundes… | Con… | Aclaración |
|-------------|------|------------|
| Tenant vacío | Login incorrecto | Sin OneAgent, no hay datos **tuyos** |
| Onboarding «Add data» | Paso obligado del lab | Es invitación del producto; en M01-02 **solo navegas** |
| URL `.live.dynatrace.com` | URL `.apps.dynatrace.com` | Ambas son válidas según generación del tenant |
| Demo/preview del trial | Tu stack `demo-web` | Tras M03 validarás **tu** host en Explorer |

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M01-01 | [Bootstrap del entorno](M01-01-bootstrap-entorno.md) | Fork, Codespace, `.env`, stack Docker |
| M01-02 | [Primera navegación en Dynatrace](M01-02-navegacion-ui.md) | Mapa de la UI, búsqueda, apps clave (**sin experiencia previa**) |

→ Si **nunca** has usado Dynatrace: lee la teoría de arriba y haz **[M01-02](M01-02-navegacion-ui.md)**
(aunque M01-01 siga pendiente, basta con tener el tenant abierto).

→ Si ya tienes Codespace: **[M01-01](M01-01-bootstrap-entorno.md)** primero, luego **M01-02**.
