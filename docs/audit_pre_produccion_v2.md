# Auditoría Pre-Producción V2 — Inventario (Offline-First)

**Fecha:** 4 de julio, 2026
**Alcance:** capa de sincronización, esquema Supabase, seguridad, flujos de dinero y calidad general.
**Proyecto Supabase:** Sistema de inventario V2 (`tovzdapibtbufjrilptk`)

Esta auditoría verificó el **código actual** contra los documentos de sprints (que estaban desactualizados) y contra el esquema real de Supabase vía CLI.

---

## Resultado de verificación de sprints anteriores

Los 8 fixes de los sprints de sync **SÍ están implementados en el código** (los docs `sync-sprint-*.md` los marcan como pendientes pero es información obsoleta):

| Ítem | Estado verificado |
|---|---|
| 1.1 SQL injection en ghost entities | ✅ Parámetros posicionales + `UuidValidator` en todo el SQL raw |
| 1.2 `metodo_de_pago` | ✅ Push correcto, pull tolera ambos nombres |
| 1.3 `fecha_registro_pago` | ✅ Campo separado, existe en remoto |
| 1.4 `bodega_default_id` | ✅ En push y pull de usuario |
| 1.5 Push coordinado venta→detalles | ✅ Con rollback del padre a `pending_update` |
| 2.1 `tipo_movimiento_local` | ✅ Columna en remoto, mapeo sin pérdida |
| 2.2 Timestamps del servidor | ✅ `_markSyncedWithTimestamps` lee el eco del upsert |
| 3.1 Pull incremental con cursor | ✅ `SyncCursorStore` + paginación de 500 |

`flutter analyze`: **0 issues** (antes y después de las correcciones de esta auditoría).
`supabase db lint`: sin errores de esquema.

---

## 1. Riesgos Críticos 🚨

### 1.1 ✅ [CORREGIDO] `SUPABASE_SERVICE_ROLE_KEY` embebida en el APK
- **Dónde:** `.github/workflows/release.yml` escribía la key en el `.env` que se empaqueta como asset de Flutter (`pubspec.yaml` → `assets: - .env`). Presente en los APK v1.0.0–v1.0.4 publicados.
- **Impacto:** cualquiera que descargue un APK del release de GitHub puede extraer la key y **leer/modificar/borrar toda la base de datos de todas las empresas, ignorando el RLS**.
- **Corrección aplicada:** eliminada del `.env` local, del `.env.example` y del workflow de release. La app no la usaba (0 referencias en `lib/`); solo las Edge Functions la necesitan y Supabase se la inyecta en el servidor automáticamente.
- **⚠️ ACCIÓN MANUAL URGENTE:** rotar la key en el dashboard de Supabase (Settings → API → JWT / API keys → regenerar `service_role`). Mientras no se rote, la key filtrada en los APK viejos sigue siendo válida.

### 1.2 ✅ [CORREGIDO] `OPENAI_API_KEY` embebida en el APK
- **Dónde:** mismo mecanismo (`.env` como asset). Extraíble de cualquier APK publicado → uso de la cuenta de OpenAI a costo del dueño.
- **Corrección aplicada:**
  - Nueva Edge Function `supabase/functions/openai-proxy/index.ts` (desplegada en V2): guarda la key como secreto del servidor, exige JWT válido de un usuario autenticado y hace passthrough del streaming SSE.
  - `openai_client.dart` ahora llama al proxy con el token de sesión de Supabase.
  - Key eliminada del `.env`, `.env.example` y `release.yml`.
- **⚠️ ACCIÓN MANUAL URGENTE:**
  1. Rotar la key en https://platform.openai.com/api-keys (la actual está comprometida).
  2. Configurar la nueva: `supabase secrets set OPENAI_API_KEY=sk-nueva...`
  3. Eliminar los secretos `OPENAI_API_KEY` y `SUPABASE_SERVICE_ROLE_KEY` de GitHub Actions (ya no se usan en el workflow).
  4. Considerar retirar los APKs viejos de los releases de GitHub.

### 1.3 ✅ [CORREGIDO] Cursor de sincronización dependía del reloj del teléfono
- **Dónde:** `sync_repository_drift.dart` (`_pull`) usaba `ultima_actualizacion` (escrita por el cliente) y avanzaba el cursor con `DateTime.now()` del dispositivo.
- **Escenario de fallo:** un teléfono con reloj atrasado 1 hora vende offline; al sincronizar, sus filas quedan con timestamp "en el pasado". Los demás dispositivos, cuyo cursor ya pasó esa hora, **nunca descargan esas ventas** (pérdida silenciosa; solo un pull completo forzado las recuperaría).
- **Corrección aplicada:**
  - Migración `20260704000001_server_updated_at.sql` (aplicada a V2): columna `server_updated_at` + trigger `now()` del servidor + índice, en las 19 tablas de negocio.
  - El pull ahora filtra/ordena por `server_updated_at` y el cursor avanza al **máximo timestamp del servidor recibido**, nunca al reloj local.
  - `ultima_actualizacion` queda intacta para resolución de conflictos (last-write-wins por fecha de edición real). El trabajo offline no cambia en nada.
- **Nota de despliegue:** el APK actual sigue funcionando (columna aditiva). El fix completo del cursor llega con el próximo APK.

### 1.4 ✅ [CORREGIDO] Bucle infinito de reintentos cada 2s ante fallo permanente
- **Dónde:** `auto_sync_provider.dart`. Una fila que falla siempre (ej. rechazo de RLS) provocaba: push falla → `_markSyncError` actualiza la fila → el watcher de tablas detecta el cambio → nuevo push a los 2s → ciclo infinito. Consumo de batería/datos y spam de requests a Supabase sin límite.
- **Corrección aplicada:** cooldown exponencial (2s → 5min) cuando el push termina sin reducir la cola de pendientes; se resetea al reconectar o al haber progreso. Además `_markSyncError` ya no modifica `updated_at` (la fila no cambió; preservar la fecha de edición real mantiene coherente el LWW).

### 1.5 ✅ [CORREGIDO en Fase 0] Repositorio git corrupto
- `refs/heads/main` contenía SHA `0000...` (escritura interrumpida); sin historial local. Restaurado desde `origin/main` (GitHub estaba intacto). Respaldo en `../.git-backup-inventario`.

---

## 2. Riesgos Medios ⚠️ (documentados, no corregidos en esta sesión)

### 2.1 Stock con last-write-wins entre dispositivos (limitación de diseño)
- `inventario_producto.cantidad_actual` se sube como **valor absoluto**. Dos dispositivos vendiendo offline de la misma bodega: A parte de 10 y vende 3 (→7), B parte de 10 y vende 2 (→8). Al sincronizar gana el último push (7 u 8); el valor correcto era 5.
- **Mitigación operativa inmediata:** un solo dispositivo de venta por bodega.
- **Fix de fondo (proyecto aparte):** aplicar los movimientos como deltas en el servidor (RPC/trigger que recalcule stock desde `detalle_venta`/`detalle_movimiento`), no como upsert absoluto.

### 2.2 Comparaciones de enums sensibles a mayúsculas en cálculos de dinero
- `sales_dao.dart`: `cerrarCaja` filtra `m.tipo == 'egreso'` y `getGananciaSesion` compara `tipoVenta == 'credito'`. Los enums del servidor admiten también `'EGRESO'`/`'CREDITO'` (variantes legacy en mayúsculas). Un dato en mayúsculas que llegue por pull queda **fuera del cálculo de gastos/ganancia** → cierre de caja con diferencia incorrecta.
- **Fix propuesto:** normalizar con `.toLowerCase()` en las comparaciones (4 puntos en `sales_dao.dart`) o normalizar al importar en `_cajaMovimientoExtraFromJson`/`_ventaFromJson`.

### 2.3 Hashes bcrypt de contraseñas legibles por toda la empresa
- La tabla `usuario` guarda `password_hash` (para login offline) y la policy RLS permite SELECT a cualquier usuario de la misma empresa → un empleado puede extraer los hashes de todos (incluido el admin) vía PostgREST y crackear contraseñas débiles offline.
- **Fix propuesto:** vista/policy que limite las columnas sensibles al propio usuario (`auth.uid() = id`), o tabla separada `usuario_credencial_offline` con policy estricta.

### 2.4 Login offline no verifica usuario desactivado
- `auth_repository.dart` → `signInOffline` busca solo por correo: no valida `estado` ni `fecha_eliminacion`. Un empleado despedido con la app instalada **puede seguir operando offline** indefinidamente.
- **Fix propuesto:** validar `estado == true && fechaEliminacion == null` en `signInOffline` (2 líneas).

### 2.5 Mensaje de error de sync nunca se persiste
- `_markSyncError(tableName, ids, errorMessage)`: el parámetro `errorMessage` no se guarda en ningún lado. En producción no habrá forma de saber POR QUÉ una fila quedó en `sync_error` sin revisar logs de archivo del dispositivo.
- **Fix propuesto:** columna local `sync_error_message` o registro en `app_logs` con el id de la fila.

---

## 3. Riesgos Bajos ℹ️

1. **Cobertura de tests casi nula:** 2 archivos (solo assistant). Mínimo recomendado: tests de `registrarVentaCompleta` (stock insuficiente, transacción atómica), `cerrarCaja` (teórico/diferencia), y push coordinado con fallo de detalles.
2. **Paginación del pull por offset:** si hay escrituras concurrentes durante una paginación larga, pueden saltarse filas (mitigado: el cursor no avanza si hay fallos y el próximo pull las recoge).
3. **Policies RLS duplicadas** (`rls_bodega`/`rls_bodegas`, etc.): sin impacto, pero conviene limpiar en una migración futura.
4. **`debug_logs` sin retención:** ya pesa 1.6 MB con datos mínimos; agregar un cron de limpieza (pg_cron) o TTL.
5. **Pendientes del audit de mayo aún abiertos:** listas sin `ListView.builder` en pantallas administrativas; consultas pesadas de `SalesDao` en el main thread.
6. **Ghost entities** usan valores dummy (`'EFECTIVO'` como tipo_venta) que no coinciden con los enums esperados — solo local, sin efecto en servidor, pero puede confundir reportes locales.
7. **`getGananciaSesion`** resta `descuento` de `sub_total`; verificar que `sub_total` no venga ya con descuento aplicado desde el checkout (posible doble descuento en el reporte de ganancia).

---

## 4. Cambios aplicados en esta auditoría 📁

| Archivo | Cambio |
|---|---|
| `.github/workflows/release.yml` | Ya no escribe service_role ni key de OpenAI en el `.env` del APK |
| `.env` / `.env.example` | Keys sensibles eliminadas + advertencia de empaquetado |
| `supabase/functions/openai-proxy/index.ts` | **Nueva** Edge Function proxy (desplegada) |
| `lib/features/assistant/data/openai/openai_client.dart` | Llama al proxy con JWT de sesión |
| `lib/core/constants/app_constants.dart` | `openAiApiKey` → `openAiProxyUrl` |
| `supabase/migrations/20260704000001_server_updated_at.sql` | **Nueva** columna+trigger+índice (aplicada a V2) |
| `lib/core/repositories/sync_repository_drift.dart` | Cursor por `server_updated_at` (máx. del servidor); `_markSynced`/`_markSyncError` sin `CURRENT_TIMESTAMP` de SQLite |
| `lib/core/providers/auto_sync_provider.dart` | Cooldown exponencial para pushes sin progreso |
| `docs/supabase_schema.ts` | Snapshot actualizado del esquema remoto |

---

## 5. Acciones manuales pendientes (del dueño) 🛑

1. **Rotar `service_role` key** en Supabase (URGENTE — está en los APK publicados).
2. **Rotar la key de OpenAI** y configurarla: `supabase secrets set OPENAI_API_KEY=sk-...`
3. Eliminar los secretos `SUPABASE_SERVICE_ROLE_KEY` y `OPENAI_API_KEY` de GitHub → Settings → Secrets (ya no los usa el workflow).
4. Valorar retirar/reemplazar los APKs v1.0.0–v1.0.4 de los releases de GitHub.
5. Publicar un nuevo APK (v1.0.5) con estos cambios; hasta entonces el asistente IA de los APK viejos dejará de funcionar al rotar la key (esperado).

## 6. Validación sugerida

- **Sync multi-dispositivo:** vender offline en el dispositivo A con el reloj atrasado 1 hora → conectar → verificar que el dispositivo B recibe la venta en su próximo pull.
- **Bucle de reintentos:** forzar un `sync_error` (ej. desactivar temporalmente una policy) y verificar en el log viewer que los reintentos se espacian (2s, 4s, 8s… máx 5 min) en lugar de cada 2s.
- **Asistente IA:** tras `secrets set`, probar una consulta al Secretario — debe responder igual que antes (ahora vía proxy).
- **Venta completa:** flujo caja → venta → cierre en dispositivo real, verificando que llega a Supabase (tabla `venta_producto` con `server_updated_at` reciente).
