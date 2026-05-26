#!/usr/bin/env bash
# scripts/release.sh
# Uso: bash scripts/release.sh "Corrección en traslados" "Mejora en sincronización"
# Cada argumento se convierte en una línea del release notes.
# Requiere: gh CLI autenticado, git, flutter
#
# IMPORTANTE: este script NO toca version.json.
# Solo actualiza pubspec.yaml y crea el tag.
# GitHub Actions actualiza version.json DESPUÉS de compilar y publicar el APK,
# evitando que los teléfonos vean una nueva versión antes de que el APK exista.

set -euo pipefail

# ── Validar argumentos ───────────────────────────────────────────────────────
if [[ $# -eq 0 ]]; then
  echo "Uso: bash scripts/release.sh \"Nota 1\" \"Nota 2\" ..."
  exit 1
fi

# ── Leer versión actual desde pubspec.yaml ───────────────────────────────────
CURRENT=$(grep '^version:' pubspec.yaml | tr -d ' ' | cut -d':' -f2)
VERSION_NAME=$(echo "$CURRENT" | cut -d'+' -f1)
VERSION_CODE=$(echo "$CURRENT" | cut -d'+' -f2)

echo "Versión actual: $VERSION_NAME+$VERSION_CODE"
echo ""

# ── Calcular próxima versión ─────────────────────────────────────────────────
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION_NAME="${MAJOR}.${MINOR}.${NEW_PATCH}"
NEW_VERSION_CODE=$((VERSION_CODE + 1))
NEW_TAG="v${NEW_VERSION_NAME}"

echo "Nueva versión: $NEW_VERSION_NAME+$NEW_VERSION_CODE (tag: $NEW_TAG)"
echo ""
echo "Release notes:"
for note in "$@"; do
  echo "  • $note"
done
echo ""
read -rp "¿Continuar? [s/N] " confirm
[[ "$confirm" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }

# ── Actualizar pubspec.yaml ──────────────────────────────────────────────────
sed -i "s/^version: .*/version: ${NEW_VERSION_NAME}+${NEW_VERSION_CODE}/" pubspec.yaml
echo "✓ pubspec.yaml actualizado"

# ── Guardar release notes en un archivo temporal para que Actions lo lea ─────
# GitHub Actions leerá este archivo y lo usará para actualizar version.json
# junto con la apkUrl real, DESPUÉS de que el APK esté publicado.
NOTES_JSON="["
for note in "$@"; do
  NOTES_JSON+="\"$note\","
done
NOTES_JSON="${NOTES_JSON%,}]"

python3 - <<PYEOF
import json

path = "app_update/pending_release_notes.json"
data = {"releaseNotes": ${NOTES_JSON}}
with open(path, "w", encoding="utf-8", newline="\n") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
echo "✓ Release notes guardadas en app_update/pending_release_notes.json"

# ── Commit y tag ─────────────────────────────────────────────────────────────
git add pubspec.yaml app_update/pending_release_notes.json
git commit -m "chore: release ${NEW_TAG}"
git tag "$NEW_TAG"
echo "✓ Commit y tag $NEW_TAG creados"

# ── Push ─────────────────────────────────────────────────────────────────────
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
echo ""
read -rp "¿Hacer push a origin y disparar GitHub Actions? [s/N] " push_confirm
if [[ "$push_confirm" =~ ^[sS]$ ]]; then
  git push origin main
  git push origin "$NEW_TAG"
  echo ""
  echo "✓ Push realizado. GitHub Actions compilará y publicará el APK."
  echo "  version.json se actualizará solo cuando el APK esté listo."
  echo "  Puedes seguir el progreso en:"
  echo "  https://github.com/${REPO}/actions"
else
  echo "Push pendiente. Cuando estés listo ejecuta:"
  echo "  git push origin main && git push origin $NEW_TAG"
fi
