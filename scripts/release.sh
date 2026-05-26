#!/usr/bin/env bash
# scripts/release.sh
# Uso: bash scripts/release.sh "Corrección en traslados" "Mejora en sincronización"
# Cada argumento se convierte en una línea del release notes.
# Requiere: gh CLI autenticado, git, flutter

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
# Incrementa el patch automáticamente (1.0.0 → 1.0.1) y el versionCode
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_NAME"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION_NAME="${MAJOR}.${MINOR}.${NEW_PATCH}"
NEW_VERSION_CODE=$((VERSION_CODE + 1))
NEW_TAG="v${NEW_VERSION_NAME}"

echo "Nueva versión: $NEW_VERSION_NAME+$NEW_VERSION_CODE (tag: $NEW_TAG)"
read -rp "¿Continuar? [s/N] " confirm
[[ "$confirm" =~ ^[sS]$ ]] || { echo "Cancelado."; exit 0; }

# ── Actualizar pubspec.yaml ──────────────────────────────────────────────────
sed -i "s/^version: .*/version: ${NEW_VERSION_NAME}+${NEW_VERSION_CODE}/" pubspec.yaml
echo "✓ pubspec.yaml actualizado"

# ── Construir release notes JSON ─────────────────────────────────────────────
NOTES_JSON="["
for note in "$@"; do
  NOTES_JSON+="\"$note\","
done
NOTES_JSON="${NOTES_JSON%,}]"

# ── Actualizar version.json ──────────────────────────────────────────────────
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
APK_NAME="inventario-${NEW_TAG}.apk"
APK_URL="https://github.com/${REPO}/releases/download/${NEW_TAG}/${APK_NAME}"
PUBLISHED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 - <<PYEOF
import json

path = "app_update/version.json"
with open(path) as f:
    data = json.load(f)

data["versionName"] = "${NEW_VERSION_NAME}"
data["versionCode"] = ${NEW_VERSION_CODE}
data["apkUrl"] = "${APK_URL}"
data["publishedAt"] = "${PUBLISHED_AT}"
data["releaseNotes"] = ${NOTES_JSON}

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
echo "✓ app_update/version.json actualizado"

# ── Commit y tag ─────────────────────────────────────────────────────────────
git add pubspec.yaml app_update/version.json
git commit -m "chore: release ${NEW_TAG}"
git tag "$NEW_TAG"
echo "✓ Commit y tag $NEW_TAG creados"

# ── Push ─────────────────────────────────────────────────────────────────────
echo ""
read -rp "¿Hacer push a origin y disparar GitHub Actions? [s/N] " push_confirm
if [[ "$push_confirm" =~ ^[sS]$ ]]; then
  git push origin main
  git push origin "$NEW_TAG"
  echo ""
  echo "✓ Push realizado. GitHub Actions compilará y publicará el APK."
  echo "  Puedes seguir el progreso en:"
  echo "  https://github.com/${REPO}/actions"
else
  echo "Push pendiente. Cuando estés listo ejecuta:"
  echo "  git push origin main && git push origin $NEW_TAG"
fi
