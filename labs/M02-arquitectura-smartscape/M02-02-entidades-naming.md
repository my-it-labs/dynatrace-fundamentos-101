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

Clasificas entidades del lab y configuras (o documentas) una convención de nombres como la que usarías en un entorno real con muchos hosts y equipos.

### 1 — Clasificar entidades

**Acción:** En el host del lab, abre la ficha de: (a) contenedor **postgres**, (b) proceso **python** de demo-api, (c) tecnología **Redis** si está detectada. Anota el **tipo** de entidad que muestra la UI en cada caso.
**Por qué:** Associate exige distinguir host / process / service / database.
**Resultado esperado:** Tres tipos distintos identificados correctamente.

### 2 — Hostname del Codespace

**Acción:** Anota el hostname exacto del host en Dynatrace (suele coincidir con el nombre de la VM del Codespace).
**Por qué:** En un entorno real con cientos de hosts, el hostname es el filtro más directo para llegar a una máquina concreta.
**Resultado esperado:** Hostname copiado para usarlo como filtro en búsquedas.

### 3 — Convención de nombres (intro)

**Acción:** Abre **Settings** y busca `naming` en **Search settings**. En un tenant nuevo solo aparece **Request naming** (servicios); las antiguas reglas de *host naming* no existen. El nombre del host lo da el propio hostname (o el *host group* al instalar OneAgent). Documenta en tus notas la convención que usarías: `lab-<tu-usuario>`.
**Por qué:** En producción varios equipos y entornos conviven en el mismo tenant; una convención evita ambigüedad.
**Resultado esperado:** Criterio de nombre documentado y sabes que en Latest Dynatrace se decide en origen, no con reglas de UI.

### 4 — Segments (visión)

**Acción:** Navega a **Settings → Environment segmentation → Segments**. Lee la descripción: un *segment* es un filtro reutilizable (p. ej. «solo mi host») que aplicas en cualquier app.
**Por qué:** Los Segments sustituyen el filtrado de las antiguas *management zones*, que ya no existen en tenants nuevos. M06 vuelve sobre ello.
**Resultado esperado:** Sabes dónde se configuran los Segments.

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
| No encuentro Host naming ni Management zones | Tenant nuevo (Latest Dynatrace) | Es normal: naming en origen y filtrado con **Segments** |
