import 'package:inventario_v2/core/db/app_database.dart';

class SessionUserDrift {
  final String serverId;
  final String empresaId;
  final String rolId;
  final String nombreCompleto;
  final String? correo;
  final String? passwordHash;
  final String? pinOffline;
  final String? bodegaDefaultId;
  final bool estado;

  const SessionUserDrift({
    required this.serverId,
    required this.empresaId,
    required this.rolId,
    required this.nombreCompleto,
    required this.correo,
    required this.passwordHash,
    required this.pinOffline,
    required this.bodegaDefaultId,
    required this.estado,
  });

  factory SessionUserDrift.fromUsuario(Usuario usuario) {
    return SessionUserDrift(
      serverId: usuario.id,
      empresaId: usuario.empresaId,
      rolId: usuario.rolId,
      nombreCompleto: usuario.nombreCompleto,
      correo: usuario.correo,
      passwordHash: usuario.passwordHash,
      pinOffline: usuario.pinOffline,
      bodegaDefaultId: usuario.bodegaDefaultId,
      estado: usuario.estado,
    );
  }

  String get id => serverId;
}

class SesionActivaDrift {
  final Empresa empresa;
  final Usuario usuario;
  final Role rol;
  final List<String> permisos;
  final CajaSesione? cajaSesionActiva;
  final Caja? cajaActiva;

  const SesionActivaDrift({
    required this.empresa,
    required this.usuario,
    required this.rol,
    required this.permisos,
    required this.cajaSesionActiva,
    required this.cajaActiva,
  });

  SessionUserDrift get userView => SessionUserDrift.fromUsuario(usuario);
}
