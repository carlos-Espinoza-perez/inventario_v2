# Inventario V2 - Referencia Rápida

## Comandos Esenciales

### Desarrollo
```bash
# Generar código (Isar + Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch
flutter pub run build_runner watch

# Ejecutar app
flutter run

# Análisis de código
flutter analyze
```

### Base de Datos
```bash
# Limpiar base de datos (desde código)
final isar = await IsarService().db;
await isar.writeTxn(() => isar.clear());
```

## Estructura del Proyecto

```
lib/
├── core/                    # Infraestructura
│   ├── constants/          # Enums, constantes
│   ├── providers/          # DB, Sync, Auth
│   ├── repositories/       # Sincronización
│   ├── router/             # Rutas (GoRouter)
│   └── services/           # Servicios auxiliares
├── features/               # Módulos
│   ├── auth/              # Autenticación
│   ├── dashboard/         # Dashboard
│   ├── inventory/         # Inventario
│   ├── sales/             # Ventas/POS
│   └── report/            # Reportes
```

## Providers Principales

### Autenticación
```dart
final authState = ref.watch(authControllerProvider);
final authCtrl = ref.read(authControllerProvider.notifier);
final usuario = authCtrl.usuarioActual;
```

### Base de Datos
```dart
final isar = await ref.read(isarDbProvider.future);
```

### Sincronización
```dart
final syncState = ref.watch(autoSyncProvider);
ref.read(autoSyncProvider.notifier).triggerSyncNow();
```

### Bodega Seleccionada
```dart
final bodega = ref.watch(selectedBodegaProvider);
```

## Operaciones Comunes

### Crear Producto
```dart
final producto = ProductoCollection()
  ..serverId = const Uuid().v4()
  ..empresaId = empresaId
  ..categoriaId = categoriaId
  ..nombre = nombre
  ..ultimaActualizacion = DateTime.now()
  ..pendienteSincronizacion = true;

await isar.writeTxn(() async {
  await isar.productoCollections.put(producto);
});
```

### Consultar Inventario
```dart
final inventario = await isar.inventarioCollections
  .filter()
  .bodegaIdEqualTo(bodegaId)
  .productoIdEqualTo(productoId)
  .findFirst();
```

### Registrar Venta
```dart
final venta = VentaCollection()
  ..serverId = const Uuid().v4()
  ..empresaId = empresaId
  ..clienteId = clienteId
  ..cajaSesionId = cajaSesionId
  ..totalVenta = total
  ..tipoVenta = TipoVenta.contado
  ..estadoPago = EstadoPago.pagado
  ..fechaVenta = DateTime.now()
  ..ultimaActualizacion = DateTime.now()
  ..pendienteSincronizacion = true;

await isar.writeTxn(() async {
  await isar.ventaCollections.put(venta);
});
```

## Navegación

### Rutas Principales
```dart
context.push('/dashboard');
context.push('/warehouse');
context.push('/product-list');
context.push('/pos');
context.push('/sales');
context.push('/reports');
```

### Con Parámetros
```dart
context.push('/product-detail/$productId');
context.push('/warehouse-inventory/$warehouseId');
context.push('/sale-detail/$saleId');
```

## Enums Importantes

```dart
// Movimientos
TipoMovimiento.compra
TipoMovimiento.traslado
TipoMovimiento.ajuste

// Ventas
TipoVenta.contado
TipoVenta.credito

// Pagos
EstadoPago.pagado
EstadoPago.pendiente
EstadoPago.parcial

MetodoPago.efectivo
MetodoPago.tarjeta
MetodoPago.transferencia
```

## Patrones de Sincronización

### Marcar para Sincronizar
```dart
objeto.pendienteSincronizacion = true;
objeto.ultimaActualizacion = DateTime.now();
await isar.coleccion.put(objeto);
```

### Forzar Sincronización
```dart
ref.read(autoSyncProvider.notifier).triggerSyncNow();
```

### Sincronización Completa
```dart
ref.read(autoSyncProvider.notifier).runFullSync();
```

## Validaciones Comunes

### Validar UUID
```dart
bool isValidUUID(String? value) {
  if (value == null || value.isEmpty) return false;
  final regex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  return regex.hasMatch(value);
}
```

### Validar Stock
```dart
if (inventario.cantidadActual < cantidadSolicitada) {
  throw Exception('Stock insuficiente');
}
```

## Debugging

### Logs Condicionales
```dart
if (kDebugMode) {
  debugPrint('🔍 Debug info');
}
```

### Inspeccionar Isar
```dart
// Abrir inspector en navegador
// http://localhost:8080 (cuando inspector: true en openDB)
```

## Errores Comunes

### Error: "No se puede sincronizar"
- Verificar conexión a internet
- Revisar credenciales de Supabase
- Validar que los IDs sean UUIDs válidos

### Error: "Stock negativo"
- Validar stock antes de operaciones
- Revisar lógica de traslados

### Error: "Sesión de caja no abierta"
- Abrir caja antes de vender
- Verificar que cajaSesionId no sea null

## Mejores Prácticas

1. **Siempre usar UUIDs:** `const Uuid().v4()`
2. **Marcar para sync:** `pendienteSincronizacion = true`
3. **Actualizar timestamp:** `ultimaActualizacion = DateTime.now()`
4. **Validar antes de guardar:** Stock, permisos, datos requeridos
5. **Usar transacciones:** `isar.writeTxn(() async { ... })`
6. **Manejar errores:** try-catch en operaciones críticas
7. **Logs informativos:** debugPrint con emojis para facilitar búsqueda

## Contactos y Recursos

- **Documentación Isar:** https://isar.dev/
- **Documentación Riverpod:** https://riverpod.dev/
- **Documentación Supabase:** https://supabase.com/docs
- **Documentación GoRouter:** https://pub.dev/packages/go_router
