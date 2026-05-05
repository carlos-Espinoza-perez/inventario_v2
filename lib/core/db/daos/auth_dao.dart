import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import 'base_dao.dart';
import '../models/auth_admin_models.dart';
import '../models/sesion_activa_drift.dart';
import '../tables/auth_tables.dart';
import '../tables/cash_tables.dart';
part 'auth_dao.g.dart';

@DriftAccessor(
  tables: [
    Empresas,
    Usuarios,
    Bodegas,
    BodegasUsuarios,
    Roles,
    AccesosRol,
    Cajas,
    CajaSesiones,
  ],
)
class AuthDao extends BaseDao with _$AuthDaoMixin {
  AuthDao(super.db);

  Expression<bool> _isPending(GeneratedColumn<String> column) {
    return column.equals('pending_insert') | column.equals('pending_update');
  }

  Future<Usuario?> getUsuarioActual() {
    return (select(usuarios)
          ..where((tbl) => tbl.estado.equals(true))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Empresa?> getEmpresaActual() async {
    final usuario = await getUsuarioActual();
    if (usuario == null) return null;

    return (select(
      empresas,
    )..where((tbl) => tbl.id.equals(usuario.empresaId))).getSingleOrNull();
  }

  Future<Role?> getRolActual() async {
    final usuario = await getUsuarioActual();
    if (usuario == null) return null;

    return (select(
      roles,
    )..where((tbl) => tbl.id.equals(usuario.rolId))).getSingleOrNull();
  }

  Future<List<String>> getPermisosPorRol(String rolId) async {
    final permisos = await (select(
      accesosRol,
    )..where((tbl) => tbl.rolId.equals(rolId) & tbl.estado.equals(true))).get();
    return permisos.map((item) => item.codigoAcceso).toList();
  }

  Future<CajaSesione?> getCajaSesionActivaParaUsuario(String usuarioId) {
    return (select(cajaSesiones)
          ..where(
            (tbl) =>
                tbl.usuarioAperturaId.equals(usuarioId) &
                tbl.estadoSesion.equals('abierta'),
          )
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.fechaApertura)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<SesionActivaDrift?> getSesionActiva() async {
    final usuario = await getUsuarioActual();
    if (usuario == null) return null;

    final empresa = await (select(
      empresas,
    )..where((tbl) => tbl.id.equals(usuario.empresaId))).getSingleOrNull();
    final rol = await (select(
      roles,
    )..where((tbl) => tbl.id.equals(usuario.rolId))).getSingleOrNull();

    if (empresa == null || rol == null) {
      return null;
    }

    final permisos = await getPermisosPorRol(rol.id);
    final cajaSesion = await getCajaSesionActivaParaUsuario(usuario.id);
    final caja = cajaSesion == null
        ? null
        : await (select(cajas)
                ..where((tbl) => tbl.id.equals(cajaSesion.cajaId)))
              .getSingleOrNull();

    return SesionActivaDrift(
      empresa: empresa,
      usuario: usuario,
      rol: rol,
      permisos: permisos,
      cajaSesionActiva: cajaSesion,
      cajaActiva: caja,
    );
  }

  Stream<SesionActivaDrift?> watchSesionActiva() {
    final query = select(usuarios)
      ..where((tbl) => tbl.estado.equals(true))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
      ..limit(1);

    return query.watchSingleOrNull().asyncMap((_) => getSesionActiva());
  }

  Future<void> replaceSesionActiva({
    required EmpresasCompanion empresa,
    required UsuariosCompanion usuario,
    required RolesCompanion rol,
    List<AccesosRolCompanion> permisos = const [],
    CajasCompanion? caja,
    CajaSesionesCompanion? cajaSesion,
  }) async {
    await transaction(() async {
      await delete(cajaSesiones).go();
      await delete(cajas).go();
      await delete(accesosRol).go();
      await delete(roles).go();
      await delete(bodegasUsuarios).go();
      await delete(bodegas).go();
      await delete(usuarios).go();
      await delete(empresas).go();

      await into(empresas).insertOnConflictUpdate(empresa);
      await into(roles).insertOnConflictUpdate(rol);
      await into(usuarios).insertOnConflictUpdate(usuario);

      for (final permiso in permisos) {
        await into(accesosRol).insertOnConflictUpdate(permiso);
      }

      if (caja != null) {
        await into(cajas).insertOnConflictUpdate(caja);
      }
      if (cajaSesion != null) {
        await into(cajaSesiones).insertOnConflictUpdate(cajaSesion);
      }
    });
  }

  Future<void> clearSesion() async {
    await transaction(() async {
      await delete(cajaSesiones).go();
      await delete(cajas).go();
      await delete(accesosRol).go();
      await delete(roles).go();
      await delete(bodegasUsuarios).go();
      await delete(bodegas).go();
      await delete(usuarios).go();
      await delete(empresas).go();
    });
  }

  Stream<List<Bodega>> watchBodegasVisibles({String query = ''}) async* {
    final user = await getUsuarioActual();
    if (user == null) {
      yield const <Bodega>[];
      return;
    }

    final userWarehouseStream = select(bodegasUsuarios)
      ..where((tbl) => tbl.usuarioId.equals(user.id) & tbl.estado.equals(true));

    await for (final relaciones in userWarehouseStream.watch()) {
      final ids = relaciones.map((r) => r.bodegaId).toSet();
      if (ids.isEmpty) {
        yield const <Bodega>[];
        continue;
      }

      final warehousesQuery = select(bodegas)
        ..where((tbl) => tbl.estado.equals(true) & tbl.id.isIn(ids.toList()))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]);

      if (query.trim().isNotEmpty) {
        warehousesQuery.where((tbl) => tbl.nombre.like('%${query.trim()}%'));
      }

      yield await warehousesQuery.get();
    }
  }

  Future<Bodega?> getBodegaById(String bodegaId) {
    return (select(
      bodegas,
    )..where((tbl) => tbl.id.equals(bodegaId))).getSingleOrNull();
  }

  Future<Set<String>> getValidBodegasIds() async {
    final user = await getUsuarioActual();
    if (user == null) return <String>{};

    final relaciones =
        await (select(bodegasUsuarios)..where(
              (tbl) => tbl.usuarioId.equals(user.id) & tbl.estado.equals(true),
            ))
            .get();

    if (relaciones.isEmpty) {
      final all = await (select(
        bodegas,
      )..where((tbl) => tbl.estado.equals(true))).get();
      return all.map((b) => b.id).toSet();
    }

    return relaciones.map((r) => r.bodegaId).toSet();
  }

  Future<void> createBodegaForCurrentUser({
    required String nombre,
    String? direccion,
    String? descripcion,
    required bool esPuntoVenta,
  }) async {
    final context = await getRequiredContext();
    final now = DateTime.now();
    final bodegaId = const Uuid().v4();
    final relacionId = const Uuid().v4();

    await transaction(() async {
      await into(bodegas).insert(
        BodegasCompanion.insert(
          id: bodegaId,
          empresaId: context.empresaId,
          nombre: nombre,
          direccion: Value(direccion?.isEmpty == true ? null : direccion),
          descripcion: Value(descripcion?.isEmpty == true ? null : descripcion),
          esPuntoVenta: Value(esPuntoVenta),
          usuarioRegistroId: Value(context.usuarioId),
          estado: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );

      await into(bodegasUsuarios).insert(
        BodegasUsuariosCompanion.insert(
          id: relacionId,
          usuarioId: context.usuarioId,
          bodegaId: bodegaId,
          usuarioRegistroId: Value(context.usuarioId),
          estado: const Value(true),
          createdAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('pending_insert'),
        ),
      );
    });
  }

  Future<List<Empresa>> getPendingEmpresas() {
    return (select(empresas)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Role>> getPendingRoles() {
    return (select(roles)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<AccesosRolData>> getPendingAccesosRol() {
    return (select(
      accesosRol,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Usuario>> getPendingUsuarios() {
    return (select(usuarios)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Bodega>> getPendingBodegas() {
    return (select(bodegas)..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<BodegasUsuario>> getPendingBodegasUsuarios() {
    return (select(
      bodegasUsuarios,
    )..where((tbl) => _isPending(tbl.syncStatus))).get();
  }

  Future<List<Role>> getActiveRolesByEmpresa(String empresaId) {
    return (select(roles)
          ..where(
            (tbl) => tbl.empresaId.equals(empresaId) & tbl.estado.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]))
        .get();
  }

  Future<List<Usuario>> getActiveUsersByEmpresa(String empresaId) {
    return (select(usuarios)
          ..where(
            (tbl) => tbl.empresaId.equals(empresaId) & tbl.estado.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombreCompleto)]))
        .get();
  }

  Future<List<Bodega>> getActiveBodegasByEmpresa(String empresaId) {
    return (select(bodegas)
          ..where(
            (tbl) => tbl.empresaId.equals(empresaId) & tbl.estado.equals(true),
          )
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.nombre)]))
        .get();
  }

  Future<List<BodegasUsuario>> getActiveAssignmentsByEmpresa(String empresaId) {
    return (select(bodegasUsuarios).join([
            innerJoin(bodegas, bodegas.id.equalsExp(bodegasUsuarios.bodegaId)),
          ])
          ..where(bodegas.empresaId.equals(empresaId))
          ..where(bodegasUsuarios.estado.equals(true)))
        .map((row) => row.readTable(bodegasUsuarios))
        .get();
  }

  Future<StaffAdminDataDrift> getStaffAdminData(String empresaId) async {
    final users = await getActiveUsersByEmpresa(empresaId);
    final rolesList = await getActiveRolesByEmpresa(empresaId);
    final warehouses = await getActiveBodegasByEmpresa(empresaId);
    final assignments = await getActiveAssignmentsByEmpresa(empresaId);
    return StaffAdminDataDrift(
      users: users,
      roles: rolesList,
      warehouses: warehouses,
      assignments: assignments,
    );
  }

  Future<RoleManagementDataDrift> getRoleManagementData(String empresaId) async {
    final rolesList = await getActiveRolesByEmpresa(empresaId);
    final roleIds = rolesList.map((role) => role.id).toList();
    final accesses = roleIds.isEmpty
        ? <AccesosRolData>[]
        : await (select(accesosRol)
              ..where(
                (tbl) =>
                    tbl.rolId.isIn(roleIds) & tbl.estado.equals(true),
              ))
            .get();
    return RoleManagementDataDrift(roles: rolesList, accesses: accesses);
  }

  Future<Set<String>> getRolePermissionCodes(String roleId) async {
    final accesses =
        await (select(accesosRol)
              ..where(
                (tbl) => tbl.rolId.equals(roleId) & tbl.estado.equals(true),
              ))
            .get();
    return accesses.map((item) => item.codigoAcceso).toSet();
  }

  Future<Role?> findActiveRoleByName({
    required String empresaId,
    required String name,
    String? excludeRoleId,
  }) async {
    final result =
        await (select(roles)
              ..where(
                (tbl) =>
                    tbl.empresaId.equals(empresaId) &
                    tbl.nombre.equals(name) &
                    tbl.estado.equals(true),
              ))
            .get();

    for (final role in result) {
      if (excludeRoleId == null || role.id != excludeRoleId) {
        return role;
      }
    }
    return null;
  }

  Future<Role> upsertRoleForEmpresa({
    required String empresaId,
    required String currentUserId,
    String? roleId,
    required String name,
    required bool isAdmin,
  }) async {
    final now = DateTime.now();
    final resolvedId = roleId ?? const Uuid().v4();
    await into(roles).insertOnConflictUpdate(
      RolesCompanion.insert(
        id: resolvedId,
        empresaId: empresaId,
        nombre: name,
        userAdmin: Value(isAdmin),
        usuarioRegistroId: Value(currentUserId),
        estado: const Value(true),
        createdAt: Value(now),
        updatedAt: Value(now),
        fechaEliminacion: const Value.absent(),
        syncStatus: Value(roleId == null ? 'pending_insert' : 'pending_update'),
      ),
    );
    return (select(roles)..where((tbl) => tbl.id.equals(resolvedId))).getSingle();
  }

  Future<void> deactivateRole(String roleId) async {
    final now = DateTime.now();
    await (update(roles)..where((tbl) => tbl.id.equals(roleId))).write(
      RolesCompanion(
        estado: const Value(false),
        fechaEliminacion: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<void> updateStaffUser({
    required String userId,
    required String empresaId,
    required String roleId,
    required String nombre,
    String? correo,
  }) async {
    final now = DateTime.now();
    await (update(usuarios)..where((tbl) => tbl.id.equals(userId))).write(
      UsuariosCompanion(
        empresaId: Value(empresaId),
        rolId: Value(roleId),
        nombreCompleto: Value(nombre),
        correo: Value(correo?.isEmpty == true ? null : correo),
        estado: const Value(true),
        fechaEliminacion: const Value(null),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }

  Future<void> replaceUserWarehouseAssignments({
    required String userId,
    required String currentUserId,
    required Set<String> warehouseIds,
  }) async {
    final now = DateTime.now();
    await transaction(() async {
      final currentAssignments =
          await (select(bodegasUsuarios)
                ..where((tbl) => tbl.usuarioId.equals(userId)))
              .get();

      for (final assignment in currentAssignments) {
        await (update(
          bodegasUsuarios,
        )..where((tbl) => tbl.id.equals(assignment.id))).write(
          BodegasUsuariosCompanion(
            estado: const Value(false),
            fechaEliminacion: Value(now),
            updatedAt: Value(now),
            syncStatus: const Value('pending_update'),
          ),
        );
      }

      for (final warehouseId in warehouseIds) {
        await into(bodegasUsuarios).insertOnConflictUpdate(
          BodegasUsuariosCompanion.insert(
            id: const Uuid().v4(),
            usuarioId: userId,
            bodegaId: warehouseId,
            usuarioRegistroId: Value(currentUserId),
            estado: const Value(true),
            createdAt: Value(now),
            updatedAt: Value(now),
            fechaEliminacion: const Value.absent(),
            syncStatus: const Value('pending_insert'),
          ),
        );
      }
    });
  }

  Future<void> deactivateUser(String userId) async {
    final now = DateTime.now();
    await (update(usuarios)..where((tbl) => tbl.id.equals(userId))).write(
      UsuariosCompanion(
        estado: const Value(false),
        fechaEliminacion: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('pending_update'),
      ),
    );
  }
}
