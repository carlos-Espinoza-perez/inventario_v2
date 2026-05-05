import 'package:drift/drift.dart';
import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/sesion_activa_drift.dart';
import 'package:uuid/uuid.dart';

class RoleAccessRepository {
  final AppDatabase _db;

  RoleAccessRepository(this._db);

  Future<void> ensureBaseRolesForUser(SessionUserDrift currentUser) async {
    final roles = await (_db.select(_db.roles)
          ..where((t) => t.empresaId.equals(currentUser.empresaId) & t.estado.equals(true)))
        .get();

    if (roles.isEmpty) {
      final adminId = const Uuid().v4();
      final operatorId = const Uuid().v4();

      await _db.batch((batch) {
        batch.insert(_db.roles, RolesCompanion.insert(
          id: adminId,
          empresaId: currentUser.empresaId,
          nombre: 'Administrador',
          userAdmin: const Value(true),
          usuarioRegistroId: Value(currentUser.serverId),
          syncStatus: const Value('pending_insert'),
        ));
        batch.insert(_db.roles, RolesCompanion.insert(
          id: operatorId,
          empresaId: currentUser.empresaId,
          nombre: 'Operador',
          userAdmin: const Value(false),
          usuarioRegistroId: Value(currentUser.serverId),
          syncStatus: const Value('pending_insert'),
        ));
      });

      await syncRolePermissions(
        roleId: adminId,
        codes: adminDefaultPermissionCodes.toSet(),
        currentUserId: currentUser.serverId,
      );
      await syncRolePermissions(
        roleId: operatorId,
        codes: operatorDefaultPermissionCodes.toSet(),
        currentUserId: currentUser.serverId,
      );
      return;
    }

    for (final role in roles) {
      if (role.userAdmin) {
        await syncRolePermissions(
          roleId: role.id,
          codes: adminDefaultPermissionCodes.toSet(),
          currentUserId: currentUser.serverId,
          additiveOnly: true,
        );
      }
    }
  }

  Future<void> syncRolePermissions({
    required String roleId,
    required Set<String> codes,
    required String currentUserId,
    bool additiveOnly = false,
  }) async {
    final existing = await (_db.select(_db.accesosRol)
          ..where((t) => t.rolId.equals(roleId)))
        .get();

    final byCode = {for (final access in existing) access.codigoAcceso: access};

    await _db.batch((batch) {
      for (final code in codes) {
        final access = byCode[code];
        if (access == null) {
          batch.insert(_db.accesosRol, AccesosRolCompanion.insert(
            id: const Uuid().v4(),
            rolId: roleId,
            codigoAcceso: code,
            usuarioRegistroId: Value(currentUserId),
            estado: const Value(true),
            syncStatus: const Value('pending_insert'),
          ));
        } else if (!access.estado) {
          batch.update(_db.accesosRol, const AccesosRolCompanion(
            estado: Value(true),
            syncStatus: Value('pending_update'),
          ), where: (t) => t.rolId.equals(roleId) & t.codigoAcceso.equals(code));
        }
      }

      if (!additiveOnly) {
        for (final access in existing) {
          if (!codes.contains(access.codigoAcceso) && access.estado) {
            batch.update(_db.accesosRol, const AccesosRolCompanion(
              estado: Value(false),
              syncStatus: Value('pending_update'),
            ), where: (t) => t.rolId.equals(roleId) & t.codigoAcceso.equals(access.codigoAcceso));
          }
        }
      }
    });
  }
}
