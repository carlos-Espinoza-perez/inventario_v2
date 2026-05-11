import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/models/assistant_operational_context.dart';

class AssistantContextBuilder {
  final Ref _ref;

  AssistantContextBuilder(this._ref);

  Future<AssistantOperationalContext> build({String? selectedWarehouseId}) async {
    final authNotifier = _ref.read(authControllerProvider.notifier);
    final sesion = authNotifier.sesionActiva;

    if (sesion == null) {
      return const AssistantOperationalContext(
        empresaId: '',
        usuarioId: '',
        rolId: '',
        permisos: [],
      );
    }

    final usuario = sesion.usuario;
    final db = _ref.read(driftDatabaseProvider);

    final allowedBodegas = await db.authDao.watchBodegasVisibles().first;
    final allowedWarehouses = allowedBodegas
        .map((b) => AssistantWarehouse(id: b.id, nombre: b.nombre))
        .toList();
    final allowedWarehouseIds = allowedWarehouses.map((b) => b.id).toSet();

    String? bodegaId;
    if (selectedWarehouseId != null &&
        allowedWarehouseIds.contains(selectedWarehouseId)) {
      bodegaId = selectedWarehouseId;
    } else if (allowedWarehouses.length == 1) {
      bodegaId = allowedWarehouses.first.id;
    }

    // Verificar si hay sesión de caja activa
    final cajaSesionActiva = sesion.cajaSesionActiva;
    final cajaSesionAbierta = cajaSesionActiva != null;
    final cajaId = sesion.cajaActiva?.id;
    final openCashSessionId = cajaSesionActiva?.id;

    // Permisos del rol
    List<String> permisos = sesion.permisos;
    if (permisos.isEmpty) {
      try {
        permisos = await db.authDao.getPermisosPorRol(sesion.rol.id);
      } catch (_) {
        permisos = [];
      }
    }

    return AssistantOperationalContext(
      empresaId: usuario.empresaId,
      usuarioId: usuario.id,
      rolId: usuario.rolId,
      permisos: permisos,
      selectedWarehouseId: bodegaId,
      allowedWarehouses: allowedWarehouses,
      cajaSesionAbierta: cajaSesionAbierta,
      cajaId: cajaId,
      openCashSessionId: openCashSessionId,
    );
  }
}

final assistantContextBuilderProvider = Provider<AssistantContextBuilder>((ref) {
  return AssistantContextBuilder(ref);
});
