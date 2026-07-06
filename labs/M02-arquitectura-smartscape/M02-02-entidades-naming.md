# M02-02 — Entidades y naming

[← Página anterior](M02-01-smartscape-recorrido.md) · [Siguiente página →](../M04-aplicaciones-trazas-problemas/README.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

M02-01 hecho; host y contenedores identificados en Smartscape o Infrastructure.

---

### Objetivo

Diferenciar tipos de entidad en la UI y aplicar una regla de naming básica para hosts del laboratorio.

### Prerrequisitos

- M02-01 completado.

### En qué consiste

Clasificas entidades del lab y configuras (o documentas) una convención de nombres para no mezclar entornos en un tenant compartido.

### 1 — Clasificar entidades

**Acción:** En el host del lab, abre la ficha de: (a) contenedor **postgres**, (b) proceso **python** de demo-api, (c) tecnología **Redis** si está detectada. Anota el **tipo** de entidad que muestra la UI en cada caso.
**Por qué:** Associate exige distinguir host / process / service / database.
**Resultado esperado:** Tres tipos distintos identificados correctamente.

### 2 — Hostname del Codespace

**Acción:** Anota el hostname exacto del host en Dynatrace (suele coincidir con el nombre de la VM del Codespace).
**Por qué:** En aulas con tenant compartido, el hostname es el filtro principal para «tu» lab.
**Resultado esperado:** Hostname copiado para usarlo como filtro en búsquedas.

### 3 — Naming rule (intro)

**Acción:** Abre **Settings → Monitoring → Host naming** (ruta equivalente). Revisa reglas existentes. Si tu tenant lo permite, añade un prefijo descriptivo o documenta en tus notas: `lab-<tu-usuario>`.
**Por qué:** Evita ambigüedad si compartís tenant en un mismo equipo.
**Resultado esperado:** Criterio de nombre documentado (regla que aplicas tú).

### 4 — Management zone (visión)

**Acción:** Navega a **Settings → Preferences → Management zones** y localiza la zona por defecto. Lee qué entidades incluye tu host.
**Por qué:** M06 profundizará en zonas; aquí solo ubicación en la UI.
**Resultado esperado:** Sabes dónde se configuran zonas; host visible en la zona default.

## Comprueba tu entendimiento

**Filtro por hostname**
Usa la búsqueda global con el hostname del Codespace y abre directamente la ficha del host.
→ Llegas al host correcto en un solo salto.

## Reto

### 1 — Glosario propio

Escribe tres líneas: qué es un **host**, un **process** y un **service** en *tu* lab (con nombres concretos).

<details>
<summary>Ver orientación</summary>

Ejemplo: Host = VM Codespace; Process = python en contenedor demo-api; Service = endpoint HTTP instrumentado (completarás detalle en M04).

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| No encuentro Host naming | UI actualizada | Busca «host naming» en global search |
| Regla no aplica retroactivamente | Comportamiento normal | Cambio afecta a descubrimientos nuevos |
| Veo hosts de otras personas | Tenant compartido | Filtra siempre por tu hostname |
