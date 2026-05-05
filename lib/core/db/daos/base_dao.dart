import 'package:drift/drift.dart';

import '../app_database.dart';
import '../models/sesion_activa_drift.dart';

class DaoContext {
  final SesionActivaDrift sesion;

  const DaoContext(this.sesion);

  String get empresaId => sesion.usuario.empresaId;
  String get usuarioId => sesion.usuario.id;
  String? get cajaSesionId => sesion.cajaSesionActiva?.id;
  String? get cajaId => sesion.cajaActiva?.id;
  String? get bodegaId => sesion.cajaActiva?.bodegaId ?? sesion.usuario.bodegaDefaultId;
}

abstract class BaseDao extends DatabaseAccessor<AppDatabase> {
  BaseDao(super.db);

  Future<DaoContext> getRequiredContext() async {
    final sesion = await db.authDao.getSesionActiva();
    if (sesion == null) {
      throw StateError('No hay una sesión activa en Drift.');
    }
    return DaoContext(sesion);
  }

  Future<String> getRequiredEmpresaId() async => (await getRequiredContext()).empresaId;

  Future<String> getRequiredUsuarioId() async => (await getRequiredContext()).usuarioId;
}
