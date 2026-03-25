# Análisis de Errores Técnicos y Lógicos - Inventario V2

## Fecha de Análisis
Marzo 22, 2026

## Resumen Ejecutivo
Este documento identifica errores técnicos, problemas de lógica, vulnerabilidades de seguridad y áreas de mejora detectadas en el proyecto Inventario V2.

## 1. ERRORES CRÍTICOS

### 1.1 Credenciales Expuestas en Código
**Severidad:** CRÍTICA 🔴
**Archivo:** `lib/core/constants/app_constants.dart`

**Problema:**
```dart
static const String supabaseUrl = 'https://tovzdapibtbufjrilptk.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

Las credenciales de Supabase están hardcodeadas en el código fuente.

**Impacto:**
- Exposición de credenciales en repositorio Git
- Riesgo de acceso no autorizado a la base de datos
- Violación de mejores prácticas de seguridad

**Solución:**
- Usar variables de entorno con `flutter_dotenv`
- Crear archivo `.env` y agregarlo a `.gitignore`
- Implementar configuración por ambiente (dev, staging, prod)

```dart
// Solución propuesta
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
```

### 1.2 Uso de IDs Temporales Inseguros
**Severidad:** ALTA 🔴
**Archivos:** `checkout_screen.dart`, múltiples repositorios

**Problema:**
```dart
..serverId = DateTime.now().millisecondsSinceEpoch.toString()
```

Se usan timestamps como IDs en lugar de UUIDs, lo que puede causar:
- Colisiones en operaciones concurrentes
- IDs predecibles (riesgo de seguridad)
- Problemas de sincronización

**Solución:**
Usar siempre `const Uuid().v4()` para generar IDs únicos:
```dart
..serverId = const Uuid().v4()
```

### 1.3 Validación Insuficiente de Foreign Keys
**Severidad:** ALTA 🔴
**Archivo:** `sync_repository.dart`

**Problema:**
La validación de foreign keys solo verifica longitud < 32, pero no valida formato UUID:
```dart
if (val != null && val.isNotEmpty && val.length < 32) {
  debugPrint("⚠️ [Sync] Descartando por FK inválida");
  return false;
}
```

**Impacto:**
- Datos corruptos pueden pasar la validación
- Errores de integridad referencial en Supabase

**Solución:**
Validar formato UUID completo:
```dart
bool isValidUUID(String? value) {
  if (value == null || value.isEmpty) return false;
  final uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  return uuidRegex.hasMatch(value);
}
```

## 2. ERRORES DE LÓGICA

### 2.1 Cálculo de Saldo Pendiente Inconsistente
**Severidad:** MEDIA 🟡
**Archivo:** `checkout_screen.dart`

**Problema:**
```dart
double get _pendingBalance {
  if (_saleType == "Contado") return 0.0;
  double balance = widget.total - _depositAmount;
  return balance < 0 ? 0 : balance;
}
```

Si el abono es mayor al total, se permite pero se muestra 0. Debería validarse antes.

**Solución:**
```dart
// Validar en el método _processSale antes de guardar
if (_saleType == "Fiado" && _depositAmount > widget.total) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("⚠️ El abono no puede ser mayor al total")),
  );
  return;
}
```

### 2.2 Actualización de Saldo de Cliente Sin Validación
**Severidad:** MEDIA 🟡
**Archivo:** `sale_detail_screen.dart`

**Problema:**
```dart
if (cliente != null) {
  cliente.saldoDeudorActual = (cliente.saldoDeudorActual - amount).clamp(0, double.infinity);
}
```

No valida si el monto del abono es mayor al saldo pendiente de la venta específica.

**Solución:**
Validar contra el saldo de la venta:
```dart
if (amount > venta.saldoPendiente) {
  throw Exception("El abono no puede ser mayor al saldo pendiente");
}
```

### 2.3 Costo Promedio Ponderado con División por Cero
**Severidad:** MEDIA 🟡
**Archivo:** `movimiento_repository.dart`

**Problema:**
```dart
if (nuevaCantidadTotal > 0) {
  nuevoCostoPromedio = (costoTotalActual + costoTotalEntrante) / nuevaCantidadTotal;
}
```

Si `nuevaCantidadTotal` es 0, el costo promedio queda en 0, lo cual puede no ser correcto.

**Solución:**
```dart
if (nuevaCantidadTotal > 0) {
  nuevoCostoPromedio = (costoTotalActual + costoTotalEntrante) / nuevaCantidadTotal;
} else {
  // Mantener el costo anterior o usar el nuevo costo
  nuevoCostoPromedio = inventarioMacro.costoPromedio > 0 
    ? inventarioMacro.costoPromedio 
    : nuevoCosto;
}
```

### 2.4 Traslados Sin Validación de Stock Suficiente
**Severidad:** ALTA 🔴
**Archivo:** `movimiento_repository.dart`

**Problema:**
En el método `registrarTrasladoBodegas`, se resta stock sin validar si hay suficiente:
```dart
invOrigen.cantidadActual -= cantidad;
```

**Impacto:**
- Stock negativo en bodega origen
- Inconsistencias en inventario
- Pérdida de trazabilidad

**Solución:**
```dart
if (invOrigen.cantidadActual < cantidad) {
  throw Exception(
    "Stock insuficiente en bodega origen. Disponible: ${invOrigen.cantidadActual}, Solicitado: $cantidad"
  );
}
invOrigen.cantidadActual -= cantidad;
```

## 3. PROBLEMAS DE ARQUITECTURA Y DISEÑO

### 3.1 Falta de Manejo de Transacciones Fallidas
**Severidad:** MEDIA 🟡

**Problema:**
Las transacciones de Isar no tienen rollback explícito en caso de error parcial.

**Solución:**
Implementar patrón de compensación o validar todo antes de iniciar la transacción:
```dart
// Validar ANTES de la transacción
await _validateStockAvailability(items, bodegaOrigenId);

// Luego ejecutar transacción
await _isar.writeTxn(() async {
  // Operaciones atómicas
});
```

### 3.2 Sincronización Sin Control de Conflictos
**Severidad:** ALTA 🔴
**Archivo:** `sync_repository.dart`

**Problema:**
No hay estrategia de resolución de conflictos cuando dos dispositivos modifican el mismo registro offline.

**Impacto:**
- Pérdida de datos
- Sobrescritura de cambios
- Inconsistencias entre dispositivos

**Solución:**
Implementar estrategia de resolución:
```dart
// Opción 1: Last-Write-Wins con timestamp
if (local.ultimaActualizacion.isAfter(remote.ultimaActualizacion)) {
  // Mantener local
} else {
  // Usar remoto
}

// Opción 2: Merge inteligente por campo
// Opción 3: Marcar conflicto para resolución manual
```

### 3.3 Falta de Índices Compuestos
**Severidad:** MEDIA 🟡

**Problema:**
Consultas frecuentes como `bodegaId + productoId` no tienen índice compuesto.

**Solución:**
```dart
@collection
class InventarioCollection {
  // Agregar índice compuesto
  @Index(composite: [CompositeIndex('bodegaId'), CompositeIndex('productoId')])
  Id id = Isar.autoIncrement;
  
  late String bodegaId;
  late String productoId;
}
```

### 3.4 Debouncing Muy Corto para Sincronización
**Severidad:** BAJA 🟢
**Archivo:** `auto_sync_provider.dart`

**Problema:**
```dart
_debounceTimer = Timer(const Duration(seconds: 2), () async {
  await triggerSyncNow();
});
```

2 segundos puede ser muy corto en operaciones masivas (ej: entrada de 100 productos).

**Solución:**
Hacer el debounce configurable o aumentarlo:
```dart
static const Duration _syncDebounce = Duration(seconds: 5);
```

## 4. PROBLEMAS DE RENDIMIENTO

### 4.1 Consultas N+1 en Historial
**Severidad:** MEDIA 🟡
**Archivo:** `movimiento_repository.dart`

**Problema:**
```dart
for (var mov in movimientos) {
  final usuario = await _isar.usuarioCollections
    .filter()
    .serverIdEqualTo(mov.usuarioRegistroId!)
    .findFirst();
}
```

Consulta individual por cada movimiento.

**Solución:**
```dart
// Cargar todos los usuarios una vez
final usuariosMap = {
  for (var u in await _isar.usuarioCollections.where().findAll())
    u.serverId: u
};

// Usar el mapa en el loop
for (var mov in movimientos) {
  final usuario = usuariosMap[mov.usuarioRegistroId];
}
```

### 4.2 Falta de Paginación en Listas
**Severidad:** MEDIA 🟡

**Problema:**
Listas como productos, ventas, movimientos cargan todos los registros sin paginación.

**Solución:**
Implementar paginación con Isar:
```dart
final productos = await isar.productoCollections
  .where()
  .offset(page * pageSize)
  .limit(pageSize)
  .findAll();
```

### 4.3 Imágenes Sin Compresión
**Severidad:** MEDIA 🟡
**Archivo:** `image_storage_service.dart`

**Problema:**
Las imágenes se suben sin compresión, consumiendo ancho de banda y almacenamiento.

**Solución:**
```dart
import 'package:image/image.dart' as img;

Future<File> compressImage(File file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes);
  final compressed = img.encodeJpg(image!, quality: 85);
  return File(file.path)..writeAsBytesSync(compressed);
}
```

## 5. PROBLEMAS DE SEGURIDAD

### 5.1 Falta de Validación de Permisos
**Severidad:** ALTA 🔴

**Problema:**
Aunque existe sistema RBAC, no se valida en el cliente antes de operaciones críticas.

**Solución:**
```dart
class PermissionService {
  static Future<bool> canPerform(String action) async {
    final user = await getCurrentUser();
    final rol = await getRol(user.rolId);
    final accesos = await getAccesosRol(rol.serverId);
    return accesos.any((a) => a.permiso == action);
  }
}

// Usar antes de operaciones
if (!await PermissionService.canPerform('crear_producto')) {
  throw Exception('No tienes permisos para crear productos');
}
```

### 5.2 PIN Offline Sin Límite de Intentos
**Severidad:** MEDIA 🟡

**Problema:**
No hay límite de intentos fallidos para el PIN offline, permitiendo ataques de fuerza bruta.

**Solución:**
```dart
class PinAttemptTracker {
  static int _attempts = 0;
  static DateTime? _lockUntil;
  
  static bool canAttempt() {
    if (_lockUntil != null && DateTime.now().isBefore(_lockUntil!)) {
      return false;
    }
    return _attempts < 5;
  }
  
  static void recordFailure() {
    _attempts++;
    if (_attempts >= 5) {
      _lockUntil = DateTime.now().add(Duration(minutes: 15));
    }
  }
}
```

### 5.3 Logs con Información Sensible
**Severidad:** MEDIA 🟡

**Problema:**
Múltiples `debugPrint` con información de usuarios, IDs, etc. que podrían quedar en producción.

**Solución:**
```dart
// Crear logger condicional
class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

// Reemplazar todos los debugPrint
AppLogger.log("🔐 [Auth] Iniciando registro");
```

## 6. PROBLEMAS DE MANTENIBILIDAD

### 6.1 Código Duplicado en Mappers
**Severidad:** BAJA 🟢

**Problema:**
Cada colección tiene su propio `fromJson` y `toJson` con lógica repetida.

**Solución:**
Crear clase base con helpers:
```dart
abstract class IsarModel {
  DateTime parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    throw Exception('Invalid date format');
  }
  
  double parseDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }
}
```

### 6.2 Strings Mágicos en Código
**Severidad:** BAJA 🟢

**Problema:**
```dart
_selectedStatus = "Todos"; // String mágico
if (_saleType == "Contado") // String mágico
```

**Solución:**
```dart
class SaleFilters {
  static const String all = "Todos";
  static const String paid = "Pagado";
  static const String pending = "Pendiente";
}

class SaleTypes {
  static const String cash = "Contado";
  static const String credit = "Fiado";
}
```

### 6.3 Falta de Documentación en Métodos Complejos
**Severidad:** BAJA 🟢

**Problema:**
Métodos como `registrarTrasladoBodegas` no tienen documentación de parámetros y comportamiento.

**Solución:**
```dart
/// Registra un traslado de productos entre dos bodegas.
/// 
/// Actualiza el inventario de origen (resta) y destino (suma),
/// maneja variantes por talla/SKU y registra el movimiento histórico.
/// 
/// Parámetros:
/// - [empresaId]: ID de la empresa
/// - [usuarioId]: ID del usuario que realiza el traslado
/// - [bodegaOrigenId]: Bodega desde donde se traslada
/// - [bodegaDestinoId]: Bodega hacia donde se traslada
/// - [descripcion]: Descripción del movimiento
/// - [items]: Lista de items con estructura: {productId, qr, size, cantidad, cost, price}
/// 
/// Throws [Exception] si hay stock insuficiente o error en la transacción.
Future<void> registrarTrasladoBodegas({...}) async {
```

## 7. WARNINGS Y DEPRECACIONES

### 7.1 Uso de withOpacity Deprecado
**Severidad:** BAJA 🟢
**Archivo:** `checkout_screen.dart:556`

**Problema:**
```dart
color.withOpacity(0.1) // Deprecado
```

**Solución:**
```dart
color.withValues(alpha: 0.1) // Nuevo método
```

### 7.2 TODO Pendiente en Código
**Severidad:** BAJA 🟢
**Archivo:** `sale_detail_screen.dart:617`

**Problema:**
```dart
// TODO: ref.invalidate(cashRegisterDetailProvider(sesionActual?.serverId));
```

**Solución:**
Implementar o remover el TODO:
```dart
ref.invalidate(cashRegisterDetailProvider(sesionActual?.serverId));
```

## 8. MEJORAS RECOMENDADAS

### 8.1 Implementar Retry Logic en Sincronización
**Prioridad:** ALTA

**Propuesta:**
```dart
Future<void> syncWithRetry({int maxRetries = 3}) async {
  int attempts = 0;
  while (attempts < maxRetries) {
    try {
      await pushCambiosLocales();
      return;
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries) rethrow;
      await Future.delayed(Duration(seconds: 2 * attempts));
    }
  }
}
```

### 8.2 Agregar Telemetría y Monitoreo
**Prioridad:** MEDIA

**Propuesta:**
```dart
// Integrar Firebase Analytics o Sentry
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_DSN';
    options.tracesSampleRate = 1.0;
  },
  appRunner: () => runApp(MyApp()),
);

// Capturar errores
try {
  await syncData();
} catch (e, stackTrace) {
  await Sentry.captureException(e, stackTrace: stackTrace);
}
```

### 8.3 Implementar Cache de Consultas Frecuentes
**Prioridad:** MEDIA

**Propuesta:**
```dart
class QueryCache {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _timestamps = {};
  
  static Future<T?> get<T>(String key, Future<T> Function() fetcher) async {
    if (_cache.containsKey(key)) {
      final age = DateTime.now().difference(_timestamps[key]!);
      if (age.inMinutes < 5) {
        return _cache[key] as T;
      }
    }
    
    final result = await fetcher();
    _cache[key] = result;
    _timestamps[key] = DateTime.now();
    return result;
  }
}
```

### 8.4 Agregar Tests Unitarios y de Integración
**Prioridad:** ALTA

**Propuesta:**
```dart
// test/repositories/movimiento_repository_test.dart
void main() {
  group('MovimientoRepository', () {
    test('debe validar stock antes de traslado', () async {
      // Arrange
      final repo = MovimientoRepository(mockIsar);
      
      // Act & Assert
      expect(
        () => repo.registrarTrasladoBodegas(
          items: [{'cantidad': 100}],
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### 8.5 Implementar Backup Automático Local
**Prioridad:** MEDIA

**Propuesta:**
```dart
class BackupService {
  static Future<void> createBackup() async {
    final isar = await Isar.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    final backupPath = '${dir.path}/backups/backup_${DateTime.now().millisecondsSinceEpoch}.isar';
    
    await isar.copyToFile(backupPath);
    
    // Mantener solo últimos 5 backups
    await _cleanOldBackups(dir);
  }
  
  static Future<void> restoreBackup(String path) async {
    final isar = await Isar.getInstance();
    await isar.close();
    
    final file = File(path);
    final dbPath = await getApplicationDocumentsDirectory();
    await file.copy('${dbPath.path}/default.isar');
    
    // Reabrir base de datos
    await IsarService().openDB();
  }
}
```

## 9. RESUMEN DE PRIORIDADES

### Críticas (Resolver Inmediatamente) 🔴
1. Credenciales expuestas en código
2. IDs temporales inseguros
3. Traslados sin validación de stock
4. Sincronización sin control de conflictos

### Altas (Resolver en Sprint Actual) 🟠
1. Validación de foreign keys
2. Falta de validación de permisos
3. Implementar tests
4. Retry logic en sincronización

### Medias (Planificar para Próximo Sprint) 🟡
1. Optimizar consultas N+1
2. Implementar paginación
3. Compresión de imágenes
4. PIN con límite de intentos
5. Cache de consultas

### Bajas (Backlog) 🟢
1. Refactorizar mappers
2. Eliminar strings mágicos
3. Agregar documentación
4. Actualizar APIs deprecadas

## 10. MÉTRICAS DE CALIDAD

### Deuda Técnica Estimada
- **Crítica:** 16 horas
- **Alta:** 24 horas
- **Media:** 32 horas
- **Baja:** 16 horas
- **Total:** ~88 horas (11 días de desarrollo)

### Cobertura de Tests
- **Actual:** 0%
- **Objetivo:** 70%

### Complejidad Ciclomática
- **Promedio:** 8-12 (Moderada)
- **Máxima:** 25+ en `movimiento_repository.dart`

## 11. RECOMENDACIONES FINALES

1. **Seguridad Primero:** Resolver inmediatamente las credenciales expuestas
2. **Validaciones:** Agregar validaciones de negocio antes de operaciones críticas
3. **Testing:** Implementar suite de tests antes de agregar nuevas features
4. **Monitoreo:** Agregar telemetría para detectar errores en producción
5. **Documentación:** Documentar flujos críticos y decisiones arquitectónicas
6. **Code Review:** Establecer proceso de revisión de código
7. **CI/CD:** Implementar pipeline con análisis estático y tests automáticos

---

**Nota:** Este análisis se basa en el código actual al 22 de marzo de 2026. Se recomienda revisar periódicamente y actualizar este documento.
