#!/usr/bin/env bash
# =============================================================================
# redact-capture.sh — Oculta datos sensibles en capturas de pantalla Dynatrace
# =============================================================================
#
# PROPÓSITO DEL LAB:
#   Antes de publicar screenshots del tenant en el repo, tapar:
#     - Esquina inferior izquierda: email / cuenta del usuario en el dock.
#     - Esquina superior izquierda: icono de perfil / menú de usuario.
#   Evita filtrar PII o identificar tenants en material público.
#
# PRERREQUISITOS:
#   - ImageMagick (comando `convert`) instalado en el sistema.
#
# USO:
#   ./scripts/redact-capture.sh labs/img/M01-02-*.png
#   ./scripts/redact-capture.sh ruta/a/captura.png
#
# NOTA SOBRE COORDENADAS:
#   Los rectángulos están calibrados para resolución típica de capturas del
#   curso (1080p aprox.). Si cambia la resolución UI de Dynatrace, ajustar
#   las coordenadas en los -draw 'rectangle x1,y1 x2,y2'.
#
# NOTAS:
#   - Buena práctica de seguridad al compartir observabilidad: redactar tenant,
#     tokens, emails, nombres de clientes reales.
# =============================================================================

set -euo pipefail

# Color de relleno: tono oscuro similar al fondo de la UI Dynatrace (#0f1117).
FILL='#0f1117'

# --- Procesar cada archivo pasado como argumento -----------------------------
# "$@" → todos los argumentos; permite globs expandidos por el shell (M01-*.png).
for f in "$@"; do
  # Si no existe el fichero, avisar y continuar con el siguiente (no abortar lote).
  [[ -f "$f" ]] || { echo "skip: $f"; continue; }

  # convert (ImageMagick):
  #   -fill COLOR      → color del rectángulo sólido.
  #   -draw rectangle  → x1,y1 esquina sup-izq; x2,y2 inf-derecha (píxeles).
  #   Sobrescribe "$f" in-place con las zonas redactadas.
  convert "$f" \
    -fill "$FILL" -draw 'rectangle 0,868 78,971' \
    -fill "$FILL" -draw 'rectangle 0,0 78,120' \
    "$f"

  # file -b → tipo MIME/dimensiones breves; confirmación de que el PNG sigue válido.
  echo "OK: $f ($(file -b "$f"))"
done
