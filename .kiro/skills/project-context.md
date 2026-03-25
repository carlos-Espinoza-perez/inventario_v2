# Inventario V2 - Contexto del Proyecto

## Descripción General
Sistema de gestión de inventario offline-first desarrollado en Flutter/Dart con sincronización bidireccional a Supabase. Incluye módulos de autenticación, inventario, ventas (POS), y reportes.

## Arquitectura

### Patrón Arquitectónico
- **Clean Architecture** con estructura Feature-First
- **Offline-First** con sincronización inteligente
- **State Management**: Riverpod 2.0 con generadores
- **Base de Datos Local**: Isar (NoSQL embebida)
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)

### Estructura de Carpetas
```
lib/
├── core/                    # Infraestructura compartida
│   ├── constants/          # Enums, constantes
│   ├── providers/          # Providers globales (DB, Sync, Auth)
│   ├── repositories/       # Repositorios de sincronización
│   ├── router/             # Configuración de rutas (GoRouter)
│   ├── services/           # Servicios auxiliares
│   └── presentation/       # Widgets compartidos
├── features/               # Módulos por funcionalidad
│   ├── auth/              # Autenticación y usuarios
│   ├── dashboard/         # Pantalla principal
│   ├── inventory/         # Gestión de inventario
│   ├── sales/             # Ventas y POS
│   └── report/            # Reportes y análisis
```

## Módulos Principales

### 1. Autenticación (`auth`)
**Archivos Clave:**
- `lib/features/auth/presentation/providers/auth_provider.dart` - Estado de autenticación
- `lib/features/auth/data/repositories/auth_repository.dart` - Lógica de login/registro
- `lib/features/auth/data/collections/usuario_collection.dart` - Modelo de usuario

**Funcionalidades:**
- Registro de empresa y usuario inicial
- Login online (Supabase Auth) y offline (PIN)
- Control de acceso basado en roles (RBAC)
- Gestión de bodegas por usuario
- Perfil de usuario

### 2. Inventario (`inventory`)
**Archivos Clave:**
- `lib/features/inventory/data/collections/producto_collection.dart` - Productos
- `lib/features/inventory/data/collections/inventario_collection.dart` - Stock por bodega
- `lib/features/inventory/data/collections/movimiento_producto_collection.dart` - Movimientos
- `lib/features/inventory/data/repository/producto_repository.dart` - Operaciones CRUD

**Funcionalidades:**
- Catálogo de productos con categorías
- Gestión de bodegas/almacenes
- Control de stock multinivel
- Movimientos: compras, traslados, ajustes
- Escaneo de códigos de barras
- Reconocimiento de imágenes con ML Kit
- Generación de códigos QR
- Historial de movimientos

### 3. Ventas y POS (`sales`)
**Archivos Clave:**
- `lib/features/sales/presentation/pos_screen.dart` - Punto de venta
- `lib/features/sales/data/collections/venta_collection.dart` - Ventas
- `lib/features/sales/data/collections/caja_sesion_collection.dart` - Sesiones de caja
- `lib/features/sales/data/repositories/caja_repository.dart` - Operaciones de caja

**Funcionalidades:**
- Punto de venta (POS) completo
- Ventas al contado y a crédito
- Gestión de clientes
- Sesiones de caja con apertura/cierre
- Arqueo de caja
- Historial de pagos
- Movimientos extra de caja

### 4. Reportes (`report`)
**Archivos Clave:**
- `lib/features/report/presentation/reports_dashboard_screen.dart` - Hub de reportes
- `lib/features/report/presentation/sales_report_screen.dart` - Reporte de ventas
- `lib/features/report/presentation/inventory_report_screen.dart` - Reporte de inventario

**Funcionalidades:**
- Reportes de ventas con gráficos
- Análisis de inventario
- Reportes financieros
- Cuentas por cobrar
- Flujo de caja

## Sistema de Sincronización

### Arquitectura Offline-First
**Archivo Principal:** `lib/core/providers/auto_sync_provider.dart`

**Estrategia:**
1. **Escritura Local Primero**: Todas las operaciones se guardan en Isar inmediatamente
2. **Marcado de Cambios**: Flag `pendienteSincronizacion = true`
3. **Sincronización Automática**: Detecta cambios y sube cuando hay conexión
4. **Debouncing**: Espera 2 segundos de inactividad antes de sincronizar
5. **Bidireccional**: Push (local → nube) y Pull (nube → local)

### Repositorio de Sincronización
**Archivo:** `lib/core/repositories/sync_repository.dart`

**Métodos Principales:**
- `pushCambiosLocales()` - Sube cambios locales a Supabase
- `pullRemoteChanges()` - Descarga cambios remotos
- `subscribeToRealtimeChanges()` - Escucha cambios en tiempo real

**Orden de Sincronización (Jerarquía de Dependencias):**
```
NIVEL 0: Empresa, Reglas de Costo, Cargos Adicionales
NIVEL 1: Roles, Usuarios, Bodegas, Clientes, Categorías
NIVEL 2: Bodega-Usuario, Cajas, Productos, Códigos
NIVEL 3: Inventario, Movimientos, Sesiones de Caja
NIVEL 4: Detalles de Movimientos, Ventas
NIVEL 5: Detalles de Ventas, Historial de Pagos
```

## Modelos de Datos

### Sistema Dual de IDs
Todas las colecciones usan dos identificadores:
- `id` (Isar.autoIncrement) - ID local para operaciones Isar
- `serverId` (UUID) - ID maestro de Supabase para sincronización

### Campos de Auditoría Estándar
```dart
late DateTime ultimaActualizacion;
DateTime? fechaEliminacion;
String? usuarioRegistroId;
bool estado = true;  // Soft delete
bool pendienteSincronizacion = true;  // Flag de sync
```

### Colecciones Principales (20+)

**Autenticación:**
- `EmpresaCollection` - Empresas
- `UsuarioCollection` - Usuarios con PIN offline
- `RolCollection` - Roles de usuario
- `AccesoRolCollection` - Permisos por rol
- `BodegaCollection` - Bodegas/almacenes
- `BodegaUsuarioCollection` - Relación usuario-bodega

**Inventario:**
- `CategoriaCollection` - Categorías de productos
- `ProductoCollection` - Productos con imágenes
- `InventarioCollection` - Stock por bodega
- `CodigoProductoCollection` - Códigos de barras/QR
- `InventarioCodigoProductoCollection` - Relación inventario-código
- `MovimientoProductoCollection` - Movimientos de inventario
- `DetalleMovimientoProductoCollection` - Líneas de movimiento
- `ReglaCostoCollection` - Reglas de costeo
- `CargoAdicionalCollection` - Cargos adicionales

**Ventas:**
- `ClienteCollection` - Clientes
- `VentaCollection` - Ventas
- `DetalleVentaCollection` - Líneas de venta
- `HistorialPagoCollection` - Pagos
- `CajaCollection` - Cajas registradoras
- `CajaSesionCollection` - Sesiones de caja
- `CajaMovimientoExtraCollection` - Movimientos extra

## Enumeraciones
**Archivo:** `lib/core/constants/app_enums.dart`

```dart
enum TipoMovimiento { compra, traslado, ajuste, solicitud }
enum EstadoMovimiento { pendiente, aprobado, rechazado }
enum TipoVenta { contado, credito }
enum EstadoPago { pagado, pendiente, parcial, anulado }
enum MetodoPago { efectivo, tarjeta, transferencia }
enum EstadoSesion { abierta, cerrada, arqueada }
enum TipoMovimientoCaja { ingreso, egreso }
```

## Navegación y Rutas

### Router Principal
**Archivo:** `lib/core/router/app_router.dart`

**Configuración:**
- GoRouter con 30+ rutas
- Redirect basado en estado de autenticación
- Shell route para layout compartido
- Rutas dinámicas con parámetros

**Rutas Principales:**
```
/splash              - Pantalla de carga
/login               - Inicio de sesión
/create-company      - Crear empresa
/create-user         - Registrar usuario
/dashboard           - Panel principal
/warehouse           - Gestión de bodegas
/product-list        - Catálogo de productos
/pos                 - Punto de venta
/sales               - Dashboard de ventas
/cash-register       - Caja registradora
/reports             - Hub de reportes
```

## Dependencias Clave

### State Management
- `flutter_riverpod: ^2.6.1` - Gestión de estado reactiva
- `riverpod_annotation: ^2.6.1` - Anotaciones para generación
- `riverpod_generator: ^2.3.9` - Generador de código

### Base de Datos
- `isar: ^3.1.0+1` - Base de datos NoSQL local
- `isar_flutter_libs: ^3.1.0+1` - Librerías nativas
- `isar_generator: ^3.1.0+1` - Generador de colecciones

### Backend
- `supabase_flutter: ^2.12.0` - Cliente de Supabase
- `connectivity_plus: ^7.0.0` - Detección de conectividad

### ML y Visión
- `mobile_scanner: ^7.1.4` - Escaneo de códigos
- `camera: ^0.11.3` - Acceso a cámara
- `google_mlkit_image_labeling: ^0.14.1` - Reconocimiento de imágenes
- `google_mlkit_text_recognition: ^0.15.0` - OCR

### UI y Utilidades
- `go_router: ^17.0.1` - Navegación declarativa
- `fl_chart: ^1.1.1` - Gráficos
- `qr_flutter: ^4.1.0` - Generación de QR
- `cached_network_image: ^3.4.1` - Caché de imágenes
- `intl: ^0.20.2` - Internacionalización
- `bcrypt: ^1.1.3` - Hashing de contraseñas
- `uuid: ^4.5.2` - Generación de UUIDs
- `pdf: ^3.11.3` - Generación de PDFs
- `printing: ^5.14.2` - Impresión

## Flujos de Trabajo Principales

### 1. Registro de Nueva Empresa
1. Usuario completa formulario en `/create-company`
2. Se guarda draft en `AuthController`
3. Usuario completa datos personales en `/create-user`
4. Se crea usuario en Supabase Auth
5. Se crea empresa, rol admin y usuario en BD
6. Se sincroniza con Supabase
7. Redirect automático a `/dashboard`

### 2. Login
1. Usuario ingresa credenciales en `/login`
2. Intenta login online con Supabase
3. Si falla por red, intenta login offline con PIN
4. Carga usuario local desde Isar
5. Actualiza estado en `AuthController`
6. Redirect a `/dashboard`

### 3. Creación de Producto
1. Usuario completa formulario en `/product-create`
2. Opcionalmente escanea código de barras
3. Opcionalmente usa cámara mágica (ML Kit)
4. Se guarda en Isar con `pendienteSincronizacion = true`
5. AutoSync detecta cambio y programa sincronización
6. Después de 2 segundos, sube a Supabase
7. Marca como sincronizado

### 4. Venta en POS
1. Usuario abre sesión de caja
2. Agrega productos al carrito
3. Selecciona cliente y método de pago
4. Confirma venta
5. Se guarda venta y detalles en Isar
6. Se actualiza inventario localmente
7. Se sincroniza automáticamente cuando hay conexión

### 5. Sincronización Completa
1. App detecta conexión a internet
2. `AutoSync` ejecuta `runFullSync()`
3. **Push**: Sube todos los cambios locales pendientes
4. **Pull**: Descarga cambios remotos
5. Actualiza UI automáticamente vía Riverpod
6. Muestra indicador de sincronización en layout

## Configuración del Proyecto

### Variables de Entorno
**Archivo:** `lib/core/constants/app_constants.dart`
```dart
class AppConstants {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

### Inicialización
**Archivo:** `lib/main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  // Inicializar Isar
  final isarService = IsarService();
  await isarService.openDB();
  
  runApp(const ProviderScope(child: MyApp()));
}
```

## Comandos Útiles

### Generación de Código
```bash
# Generar código de Isar y Riverpod
flutter pub run build_runner build --delete-conflicting-outputs

# Modo watch para desarrollo
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Análisis de Código
```bash
# Analizar código
flutter analyze

# Formatear código
flutter format lib/
```

### Ejecución
```bash
# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release
```

## Patrones y Convenciones

### Nomenclatura
- **Colecciones**: `NombreCollection` (ej: `ProductoCollection`)
- **Providers**: `nombreProvider` (ej: `authControllerProvider`)
- **Screens**: `nombre_screen.dart` (ej: `product_list_screen.dart`)
- **Repositories**: `nombre_repository.dart` (ej: `producto_repository.dart`)

### Estructura de Features
```
feature_name/
├── data/
│   ├── collections/      # Modelos Isar
│   └── repositories/     # Lógica de datos
└── presentation/
    ├── providers/        # Riverpod providers
    ├── screens/          # Pantallas
    └── widgets/          # Widgets específicos
```

### Manejo de Errores
- Usar `AsyncValue` de Riverpod para estados loading/error/data
- Logs con `debugPrint()` para desarrollo
- Try-catch en operaciones críticas de sincronización

## Seguridad

### Autenticación
- Supabase Auth para gestión de usuarios
- Bcrypt para hashing de contraseñas
- PIN de 4 dígitos para acceso offline
- Tokens JWT manejados por Supabase

### Autorización
- Sistema RBAC (Role-Based Access Control)
- Permisos granulares por rol
- Validación en cliente y servidor

### Datos
- Soft deletes con campo `estado`
- Auditoría con `usuarioRegistroId` y `ultimaActualizacion`
- Validación de foreign keys antes de sincronizar

## Optimizaciones

### Performance
- Índices en campos frecuentemente consultados
- Caché de imágenes con `cached_network_image`
- Debouncing en sincronización (2 segundos)
- Lazy loading en listas largas

### Offline
- Todas las operaciones funcionan sin conexión
- Sincronización automática al recuperar conexión
- Validación de datos antes de subir
- Manejo de conflictos con `ultima_actualizacion`

## Testing

### Archivos de Test
- `test/` - Tests unitarios
- `integration_test/` - Tests de integración

### Comandos
```bash
# Ejecutar tests
flutter test

# Tests con cobertura
flutter test --coverage
```

## Notas Importantes

1. **Generación de Código**: Siempre ejecutar `build_runner` después de modificar colecciones o providers anotados
2. **Sincronización**: El orden de sincronización es crítico para mantener integridad referencial
3. **IDs**: Nunca usar IDs locales (1, 2, 3...) para sincronización, siempre UUIDs
4. **Realtime**: Las suscripciones de Supabase se activan automáticamente al iniciar la app
5. **Offline**: El sistema está diseñado para funcionar completamente offline, la sincronización es transparente

## Recursos Adicionales

- [Documentación de Isar](https://isar.dev/)
- [Documentación de Riverpod](https://riverpod.dev/)
- [Documentación de Supabase](https://supabase.com/docs)
- [Documentación de GoRouter](https://pub.dev/packages/go_router)
