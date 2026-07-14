# M05-02 — Workloads Kubernetes

[← Página anterior](M05-01-kind-operator.md) · [Siguiente página →](../M06-dashboards-alertas-logs/README.md)

> **Formato del lab:** **dónde** · **acción** · **para qué** · **validar** · **comprender**.

---

## Punto de partida (starter)

M05-01 completado — DynaKube **Running**, `kubectl get nodes` OK.

---

### Objetivo

Desplegar workloads de ejemplo en kind y validarlos en la app **Kubernetes** de Dynatrace.

### Prerrequisitos

- M05-01 completado (DynaKube Running).

### En qué consiste

Aplicas manifiestos del lab, verificas pods y localizas namespace `dynatrace-lab` en la UI.

### 1 — Desplegar workloads

**Acción:**

```bash
./scripts/k8s-lab-up.sh
kubectl -n dynatrace-lab get pods,svc
```

**Por qué:** Crea `lab-web` (nginx x2) y `lab-loadgen` con tráfico interno.
**Resultado esperado:** Pods `Running`; Service `lab-web` en puerto 80.

### 2 — App Kubernetes en Dynatrace

**Acción:** Abre la app **Kubernetes** (Hub o búsqueda global). Selecciona tu clúster kind / workload `dynatrace-lab`.
**Por qué:** Vista consolidada de cluster → namespace → workload → pod.
**Resultado esperado:** Namespace `dynatrace-lab` con deployments `lab-web` y `lab-loadgen`.

### 3 — Inspeccionar pod

**Acción:** Abre un pod `lab-web-*`. Revisa métricas CPU/memoria y eventos recientes.
**Por qué:** Contrasta monitorización K8s vs contenedores Compose de M03.
**Resultado esperado:** Métricas de pod con datos tras 3–5 min.

### 4 — Workload overview

**Acción:** Desde el deployment `lab-web`, abre vista de **Workloads** / réplicas y comprueba que hay **2 pods**.
**Por qué:** Valida descubrimiento de réplicas y servicio asociado.
**Resultado esperado:** 2/2 pods ready monitorizados.

Validación local al cerrar M05-02:

```bash
./scripts/validate-lab.sh m05
```

### 5 — (Opcional) Smartscape K8s

**Acción:** En Smartscape, localiza entidades **Kubernetes cluster** / **namespace** vinculadas al lab.
**Por qué:** Conecta M02 (topología) con infra K8s.
**Resultado esperado:** Relación cluster → namespace → pod visible o accesible desde Kubernetes app.

## Comprueba tu entendimiento

**Tráfico interno**
¿Qué hace el pod `lab-loadgen`?
→ Genera peticiones HTTP periódicas a `lab-web`.

## Reto

### 1 — Escalar réplicas

```bash
kubectl -n dynatrace-lab scale deployment/lab-web --replicas=3
```

Espera 5 min y confirma que Dynatrace muestra 3 pods.
→ Tercera réplica aparece en Kubernetes app.

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| Namespace vacío en UI | DynaKube aún no ready | Espera pods dynatrace namespace |
| Pods lab pending | Recursos kind | `kubectl describe pod` |
| Clúster no listado | API token sin permisos K8s | Regenera token API |

## Referencia

- Manifiestos: `infra/k8s/demo-workload.yaml`
