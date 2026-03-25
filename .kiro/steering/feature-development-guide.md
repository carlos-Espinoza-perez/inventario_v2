---
inclusion: manual
---

# Guía de Desarrollo de Features - Inventario V2

Esta guía proporciona el proceso estándar para desarrollar nuevas funcionalidades en el proyecto Inventario V2.

## Checklist de Desarrollo

### 1. Análisis y Diseño
- [ ] Definir requisitos funcionales
- [ ] Identificar modelos de datos necesarios
- [ ] Diseñar flujo de usuario (wireframes)
- [ ] Identificar dependencias con otros módulos
- [ ] Definir estrategia de sincronización offline

### 2. Modelo de Datos (Isar Collection)

#### Crear Colección
```dart
import 'package:isar/isar.dart';

part 'mi_collection.g.dart';

@collection
class MiCollection {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId; // UUID de Supabase

  @Index()
  late String empresaId;

  // Campos de negocio
  late String campo1;
  String? campo2;

  // Auditoría estándar
  late DateTime fechaRegistro;
  String? usuarioRegistroId;
  bool estado = true;
  late DateTime ultimaActualizacion;
  DateTime? fechaEliminacion;

  // Sincronización
  @Index()
  bool pendienteSincronizacion = true;

  MiCollection();

  // Mapper: Supabase → Isar
  factory MiCollection.fromJson(Map<String, dynamic> json) {
    return MiCollection()
      ..serverId = json['id']
      ..empresaId = json['empresa_id']
      ..campo1 = json['campo_1']
      ..campo2 = json['campo_2']
      ..fechaRegistro = DateTime.parse(json['fecha_registro'])
      ..usuarioRegistroId = json['usuario_registro_id']
      ..estado = json['estado'] ?? true
      ..ultimaActualizacion = DateTime.parse(json['ultima_actualizacion'])
      ..fechaEliminacion = json['fecha_eliminacion'] != null
          ? DateTime.parse(json['fecha_eliminacion'])
          : null;
  }

  // Mapper: Isar → Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'empresa_id': empresaId,
      'campo_1': campo1,
      'campo_2': campo2,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'usuario_registro_id': usuarioRegistroId,
      'estado': estado,
      'ultima_actualizacion': ultimaActualizacion.toIso8601String(),
      'fecha_eliminacion': fechaEliminacion?.toIso8601String(),
    };
  }
}
```

#### Generar Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Registrar en IsarService
```dart
// lib/core/providers/isar_service.dart
return await Isar.open(
  [
    // ... otras colecciones
    MiCollectionSchema,
  ],
  directory: dir.path,
  inspector: true,
);
```

### 3. Repositorio

#### Crear Repositorio
```dart
// lib/features/mi_feature/data/repositories/mi_repository.dart
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class MiRepository {
  final Isar _isar;
  MiRepository(this._isar);

  Future<void> crear({
    required String empresaId,
    required String usuarioId,
    required String campo1,
    String? campo2,
  }) async {
    await _isar.writeTxn(() async {
      final nuevo = MiCollection()
        ..serverId = const Uuid().v4()
        ..empresaId = empresaId
        ..campo1 = campo1
        ..campo2 = campo2
        ..fechaRegistro = DateTime.now()
        ..usuarioRegistroId = usuarioId
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true;

      await _isar.miCollections.put(nuevo);
    });
  }

  Future<List<MiCollection>> listar({String? empresaId}) async {
    if (empresaId != null) {
      return await _isar.miCollections
          .filter()
          .empresaIdEqualTo(empresaId)
          .estadoEqualTo(true)
          .findAll();
    }
    return await _isar.miCollections
        .filter()
        .estadoEqualTo(true)
        .findAll();
  }

  Future<MiCollection?> obtenerPorId(String id) async {
    return await _isar.miCollections
        .filter()
        .serverIdEqualTo(id)
        .findFirst();
  }

  Future<void> actualizar(MiCollection objeto) async {
    await _isar.writeTxn(() async {
      objeto.ultimaActualizacion = DateTime.now();
      objeto.pendienteSincronizacion = true;
      await _isar.miCollections.put(objeto);
    });
  }

  Future<void> eliminar(String id) async {
    await _isar.writeTxn(() async {
      final objeto = await obtenerPorId(id);
      if (objeto != null) {
        objeto.estado = false;
        objeto.fechaEliminacion = DateTime.now();
        objeto.ultimaActualizacion = DateTime.now();
        objeto.pendienteSincronizacion = true;
        await _isar.miCollections.put(objeto);
      }
    });
  }
}
```

### 4. Provider (Riverpod)

#### Crear Provider
```dart
// lib/features/mi_feature/presentation/providers/mi_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mi_provider.g.dart';

@riverpod
Future<MiRepository> miRepository(MiRepositoryRef ref) async {
  final isar = await ref.watch(isarDbProvider.future);
  return MiRepository(isar);
}

@riverpod
Future<List<MiCollection>> miList(MiListRef ref) async {
  final repo = await ref.watch(miRepositoryProvider.future);
  final authCtrl = ref.read(authControllerProvider.notifier);
  final empresaId = authCtrl.usuarioActual?.empresaId;
  return await repo.listar(empresaId: empresaId);
}

@riverpod
Future<MiCollection?> miDetail(MiDetailRef ref, String id) async {
  final repo = await ref.watch(miRepositoryProvider.future);
  return await repo.obtenerPorId(id);
}
```

#### Generar Código
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. UI (Screens y Widgets)

#### Screen Principal
```dart
// lib/features/mi_feature/presentation/screens/mi_list_screen.dart
class MiListScreen extends ConsumerWidget {
  const MiListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(miListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Feature')),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No hay datos'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.campo1),
                subtitle: Text(item.campo2 ?? ''),
                onTap: () => context.push('/mi-detail/${item.serverId}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/mi-create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 6. Sincronización

#### Agregar a SyncRepository
```dart
// lib/core/repositories/sync_repository.dart

// En pushCambiosLocales()
await _syncMiColeccion();

// Método de sincronización
Future<void> _syncMiColeccion() async {
  final items = await _isar.miCollections
      .filter()
      .pendienteSincronizacionEqualTo(true)
      .findAll();
  await _syncTable(
    tableName: 'mi_tabla',
    items: items,
    toJson: (i) => i.toJson(),
    onCleanup: (list) => _isar.writeTxn(() async {
      for (var i in list) {
        i.pendienteSincronizacion = false;
        await _isar.miCollections.put(i);
      }
    }),
  );
}

// En subscribeToRealtimeChanges()
_subscribeTable<MiCollection>(
  tableName: 'mi_tabla',
  collection: _isar.miCollections,
  fromJson: (json) => MiCollection.fromJson(json),
);

// En pullRemoteChanges()
await _pullTable(
  'mi_tabla',
  _isar.miCollections,
  (j) => MiCollection.fromJson(j),
);
```

#### Agregar Watcher en AutoSyncProvider
```dart
// lib/core/providers/auto_sync_provider.dart

// En _initIsarWatchers()
final streamsToWatch = [
  // ... otros streams
  isar.miCollections.watchLazy(),
];
```

### 7. Rutas

#### Agregar Rutas en AppRouter
```dart
// lib/core/router/app_router.dart

ShellRoute(
  builder: (context, state, child) => MainLayout(child: child),
  routes: [
    // ... otras rutas
    GoRoute(
      path: '/mi-list',
      builder: (context, state) => const MiListScreen(),
    ),
    GoRoute(
      path: '/mi-detail/:id',
      builder: (context, state) => MiDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/mi-create',
      builder: (context, state) => const MiCreateScreen(),
    ),
  ],
),
```

### 8. Testing

#### Test Unitario del Repositorio
```dart
// test/repositories/mi_repository_test.dart
void main() {
  late Isar isar;
  late MiRepository repository;

  setUp(() async {
    isar = await Isar.open(
      [MiCollectionSchema],
      directory: '',
      name: 'test',
    );
    repository = MiRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('MiRepository', () {
    test('debe crear un nuevo registro', () async {
      await repository.crear(
        empresaId: 'test-empresa',
        usuarioId: 'test-user',
        campo1: 'valor1',
      );

      final items = await repository.listar();
      expect(items.length, 1);
      expect(items.first.campo1, 'valor1');
    });

    test('debe actualizar un registro existente', () async {
      await repository.crear(
        empresaId: 'test-empresa',
        usuarioId: 'test-user',
        campo1: 'valor1',
      );

      final items = await repository.listar();
      final item = items.first;
      item.campo1 = 'valor2';
      await repository.actualizar(item);

      final updated = await repository.obtenerPorId(item.serverId);
      expect(updated?.campo1, 'valor2');
    });
  });
}
```

### 9. Documentación

#### Actualizar README
- Agregar descripción de la nueva feature
- Documentar endpoints de API si aplica
- Agregar capturas de pantalla

#### Comentarios en Código
```dart
/// Gestiona las operaciones CRUD de [MiCollection].
/// 
/// Todas las operaciones marcan los registros como pendientes
/// de sincronización para el sistema offline-first.
class MiRepository {
  /// Crea un nuevo registro.
  /// 
  /// Parámetros:
  /// - [empresaId]: ID de la empresa propietaria
  /// - [usuarioId]: ID del usuario que crea el registro
  /// - [campo1]: Campo obligatorio
  /// - [campo2]: Campo opcional
  /// 
  /// Throws [Exception] si falla la transacción.
  Future<void> crear({...}) async {
```

### 10. Checklist Final

- [ ] Modelo de datos creado y generado
- [ ] Repositorio implementado con CRUD completo
- [ ] Providers creados y generados
- [ ] Screens implementadas
- [ ] Rutas configuradas
- [ ] Sincronización agregada (Push, Pull, Realtime)
- [ ] Watchers configurados
- [ ] Tests unitarios escritos
- [ ] Documentación actualizada
- [ ] Code review realizado
- [ ] Probado en modo offline
- [ ] Probado sincronización
- [ ] Validaciones de negocio implementadas
- [ ] Manejo de errores implementado

## Patrones Comunes

### Validación de Permisos
```dart
final authCtrl = ref.read(authControllerProvider.notifier);
final usuario = authCtrl.usuarioActual;

if (usuario == null) {
  throw Exception('Usuario no autenticado');
}

// Validar permisos específicos si es necesario
```

### Manejo de Errores
```dart
try {
  await repository.crear(...);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Guardado exitosamente')),
  );
} catch (e) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('❌ Error: $e')),
  );
}
```

### Loading States
```dart
final asyncValue = ref.watch(miListProvider);

return asyncValue.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, st) => Text('Error: $e'),
  data: (data) => MyWidget(data: data),
);
```

## Recursos Adicionales

- [Documentación Isar](https://isar.dev/)
- [Documentación Riverpod](https://riverpod.dev/)
- [Guía de Testing Flutter](https://docs.flutter.dev/testing)
- [Material Design Guidelines](https://m3.material.io/)
