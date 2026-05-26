# Proceso de Release — Inventario App

Este documento describe todo lo que necesita saber un agente de IA (o un desarrollador)
para publicar una nueva versión de la app correctamente.

---

## Resumen rápido

Para publicar una nueva versión el usuario dirá algo como:

> "Publica una nueva versión con estos cambios: corrección en traslados, mejora en sincronización"

El agente debe ejecutar:

```bash
bash scripts/release.sh "Corrección en traslados" "Mejora en sincronización"
```

Eso es todo. El script y GitHub Actions hacen el resto automáticamente.

---

## Arquitectura del sistema de releases

```
Developer / AI Agent
        │
        │  bash scripts/release.sh "nota 1" "nota 2"
        ▼
scripts/release.sh
  ├── Incrementa versionCode y versionName en pubspec.yaml
  ├── Actualiza app_update/version.json con nuevos valores y release notes
  ├── Crea commit: "chore: release vX.Y.Z"
  ├── Crea tag git: vX.Y.Z
  └── Push a origin main + origin vX.Y.Z
        │
        ▼
GitHub Actions (.github/workflows/release.yml)
  ├── Se dispara SOLO por tags con formato vX.Y.Z
  ├── Restaura keystore desde secret KEYSTORE_BASE64
  ├── Compila APK release con Flutter
  ├── Renombra APK: inventario-vX.Y.Z.apk
  ├── Crea GitHub Release con el APK como asset
  ├── Actualiza app_update/version.json (apkUrl, publishedAt)
  └── Hace commit de version.json a main [skip ci]
        │
        ▼
App en dispositivos Android
  ├── Al iniciar consulta version.json desde GitHub raw
  ├── Compara versionCode remoto vs local
  ├── Si hay actualización → muestra modal
  └── Usuario descarga e instala el nuevo APK
```

---

## Archivos clave

| Archivo | Propósito |
|---|---|
| `pubspec.yaml` | Fuente de verdad de `versionName` y `versionCode`. Formato: `version: 1.0.1+2` (nombre+código) |
| `app_update/version.json` | Metadata de la versión más reciente. La app lo consulta al iniciar |
| `.github/workflows/release.yml` | Workflow de GitHub Actions. Solo se dispara con tags `vX.Y.Z` |
| `scripts/release.sh` | Script local para hacer un release desde la terminal |
| `android/app/build.gradle.kts` | Lee `android/key.properties` para firmar el APK release |
| `android/key.properties` | Credenciales del keystore. **Ignorado por git. No commitear nunca.** |
| `inventario-release.jks` | Keystore de firma. **Ignorado por git. No commitear nunca.** |

---

## Formato de version.json

```json
{
  "versionName": "1.0.1",
  "versionCode": 2,
  "minRequiredVersionCode": 1,
  "apkUrl": "https://github.com/carlos-Espinoza-perez/inventario_v2/releases/download/v1.0.1/inventario-v1.0.1.apk",
  "releaseNotes": [
    "Corrección en traslados",
    "Mejora en sincronización"
  ],
  "forceUpdate": false,
  "publishedAt": "2026-05-26T00:00:00Z"
}
```

### Campos que controla el agente / desarrollador

| Campo | Quién lo actualiza | Cuándo |
|---|---|---|
| `versionName` | `scripts/release.sh` | Automático al correr el script |
| `versionCode` | `scripts/release.sh` | Automático al correr el script |
| `releaseNotes` | `scripts/release.sh` | Se pasan como argumentos al script |
| `forceUpdate` | **Manual** | Antes de correr el script si se requiere actualización obligatoria |
| `minRequiredVersionCode` | **Manual** | Cuando se rompe compatibilidad con versiones anteriores |
| `apkUrl` | GitHub Actions | Automático después de compilar |
| `publishedAt` | GitHub Actions | Automático después de compilar |

---

## Cómo hacer un release paso a paso

### Caso normal (actualización opcional)

```bash
bash scripts/release.sh "Descripción del cambio 1" "Descripción del cambio 2"
```

El script pregunta confirmación dos veces:
1. Antes de crear el commit y el tag.
2. Antes de hacer push.

### Caso con actualización obligatoria

Editar `app_update/version.json` manualmente antes de correr el script:

```json
"forceUpdate": true
```

Luego correr el script normalmente.

### Caso con versión mínima requerida

Si la nueva versión rompe compatibilidad con versiones antiguas, editar `version.json`:

```json
"minRequiredVersionCode": 3
```

Esto fuerza la actualización en todos los dispositivos con `versionCode < 3`, independientemente de `forceUpdate`.

---

## Versionado — convención

El script incrementa automáticamente el **patch** de `versionName` y el `versionCode`:

```
pubspec.yaml actual:   version: 1.0.0+1
Después del script:    version: 1.0.1+2
Tag creado:            v1.0.1
```

Si el usuario pide un cambio de **minor** o **major** (ej: `1.1.0` o `2.0.0`),
el agente debe editar `pubspec.yaml` manualmente antes de correr el script:

```bash
# Editar pubspec.yaml: cambiar version: 1.0.5+6 → version: 1.1.0+7
# Luego correr:
bash scripts/release.sh "Nueva funcionalidad importante"
```

---

## Secrets de GitHub Actions

Están configurados en el repositorio. No es necesario volver a configurarlos salvo que el keystore cambie.

| Secret | Descripción |
|---|---|
| `KEYSTORE_BASE64` | Keystore en Base64 |
| `KEY_STORE_PASSWORD` | Contraseña del keystore |
| `KEY_PASSWORD` | Contraseña de la clave |
| `KEY_ALIAS` | Alias de la clave (`inventario`) |

Para actualizar los secrets si el keystore cambia:

```bash
# Regenerar Base64 y subir
KEYSTORE_B64=$(python3 -c "
import base64
with open('inventario-release.jks', 'rb') as f:
    print(base64.b64encode(f.read()).decode())
")
gh secret set KEYSTORE_BASE64 --body "$KEYSTORE_B64" --repo carlos-Espinoza-perez/inventario_v2
gh secret set KEY_STORE_PASSWORD --body "NUEVA_CONTRASEÑA" --repo carlos-Espinoza-perez/inventario_v2
gh secret set KEY_PASSWORD --body "NUEVA_CONTRASEÑA" --repo carlos-Espinoza-perez/inventario_v2
gh secret set KEY_ALIAS --body "inventario" --repo carlos-Espinoza-perez/inventario_v2
```

---

## Comportamiento de la app al detectar una actualización

| Condición | Comportamiento |
|---|---|
| `versionCodeLocal >= versionCodeRemoto` | No muestra nada, inicio normal |
| `versionCodeLocal < versionCodeRemoto` y `forceUpdate: false` | Modal opcional con botón "Después" |
| `forceUpdate: true` | Modal obligatorio, sin botón "Después", sin navegación atrás |
| `versionCodeLocal < minRequiredVersionCode` | Modal obligatorio (aunque `forceUpdate` sea false) |
| Sin conexión a internet | Inicio normal sin modal, sin importar `forceUpdate` |
| Timeout al consultar version.json (>5s) | Inicio normal sin modal |

---

## Reglas para no romper datos locales

**Antes de cada release verificar:**

1. El `applicationId` no cambió (`com.example.inventario_v2`).
2. El APK está firmado con el mismo keystore (`inventario-release.jks`).
3. El `versionCode` es mayor al anterior.
4. Si hubo cambios en esquema SQLite → se agregó migración con `onUpgrade`.
5. No se limpian datos locales, SharedPreferences ni sesión al iniciar.

---

## Verificar el estado de un release en curso

```bash
# Ver todos los runs recientes
gh run list --repo carlos-Espinoza-perez/inventario_v2 --limit 5

# Ver detalle del último run
gh run view --repo carlos-Espinoza-perez/inventario_v2 --log
```

---

## Qué hace GitHub Actions exactamente

1. Se activa con `git push origin vX.Y.Z`.
2. Instala Java 17 y Flutter 3.32.0.
3. Reconstruye `android/key.properties` desde los secrets.
4. Corre `flutter pub get` y `flutter build apk --release`.
5. Renombra el APK a `inventario-vX.Y.Z.apk`.
6. Crea el GitHub Release con ese APK como asset descargable.
7. Actualiza `apkUrl` y `publishedAt` en `app_update/version.json`.
8. Hace commit de ese cambio a `main` con mensaje `[skip ci]` para no disparar otro run.

---

## URL estable del version.json

La app consulta siempre esta URL al iniciar:

```
https://raw.githubusercontent.com/carlos-Espinoza-perez/inventario_v2/main/app_update/version.json
```

No cambia entre versiones. GitHub Actions actualiza el contenido del archivo en cada release.

---

## Ejemplos de instrucciones al agente

Estas son frases que el usuario puede decir y cómo el agente debe responder:

**"Publica una nueva versión con estos cambios: arreglo en el módulo de ventas"**
```bash
bash scripts/release.sh "Arreglo en el módulo de ventas"
```

**"Publica una versión obligatoria, los usuarios deben actualizar sí o sí"**
```bash
# 1. Editar app_update/version.json → "forceUpdate": true
# 2. Correr:
bash scripts/release.sh "Actualización de seguridad requerida"
```

**"Sube la versión a 1.1.0"**
```bash
# 1. Editar pubspec.yaml: version: 1.1.0+<versionCode_actual+1>
# 2. Correr:
bash scripts/release.sh "Descripción de los cambios"
```

**"¿Cómo va el release?"**
```bash
gh run list --repo carlos-Espinoza-perez/inventario_v2 --limit 3
```

**"¿Cuál es la versión actual publicada?"**
```bash
cat app_update/version.json
```
