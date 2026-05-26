import 'package:drift/drift.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/daos/auth_dao.dart';
import 'package:inventario_v2/core/utils/password_hasher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  final AuthDao _authDao;

  AuthRepository(this._supabase, this._db) : _authDao = _db.authDao;

  Future<void> createCompanyAndUser({
    required String nombre,
    required String nombreComercial,
    required String ruc,
    required String userId,
    required String userEmail,
    required String userNombre,
    required String userPassword,
  }) async {
    try {
      final hashedPassword = PasswordHasher.hashPassword(userPassword);
      final response = await _supabase.rpc(
        'crear_empresa_inicial',
        params: {
          'p_nombre_empresa': nombre,
          'p_ruc_empresa': ruc,
          'p_user_id': userId,
          'p_user_email': userEmail,
          'p_user_nombre': userNombre,
          'p_user_password': hashedPassword,
        },
      );

      if (response == null) {
        throw Exception('No se pudo crear la empresa');
      }

      final data = response as Map<String, dynamic>;
      final jsonEmpresa = Map<String, dynamic>.from(data['empresa'] as Map);
      final jsonUsuario = Map<String, dynamic>.from(data['usuario'] as Map);
      final jsonRol = Map<String, dynamic>.from(data['rol'] as Map);

      final permissionsRaw = await _supabase
          .from('acceso_rol')
          .select()
          .eq('rol_id', jsonUsuario['rol_id'])
          .eq('estado', true);

      final permisos = (permissionsRaw as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map(_accesoRolCompanionFromJson)
          .toList();

      await _authDao.replaceSesionActiva(
        empresa: _empresaCompanionFromJson(jsonEmpresa),
        usuario: _usuarioCompanionFromJson(jsonUsuario),
        rol: _rolCompanionFromJson(jsonRol),
        permisos: permisos,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Error de base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado al crear empresa: $e');
    }
  }

  Future<void> singInOnline(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      await syncSupabaseUserToLocal(user.id);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Error en Login Online: $e');
    }
  }

  Future<void> signInOffline(String email, String password) async {
    final user =
        await (_db.select(_db.usuarios)
              ..where((tbl) => tbl.correo.equals(email))
              ..limit(1))
            .getSingleOrNull();

    if (user == null) {
      throw Exception(
        'No hay datos guardados para este usuario. Conéctate a internet para el primer inicio.',
      );
    }

    if (user.passwordHash == null) {
      throw Exception('Seguridad no sincronizada. Inicia sesión con internet.');
    }

    final isPasswordValid = PasswordHasher.checkPassword(
      password,
      user.passwordHash!,
    );

    if (!isPasswordValid) {
      throw Exception('Contraseña incorrecta.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_user_id', user.id);
  }

  Future<void> syncSupabaseUserToLocal(String userId) async {
    try {
      final userData = await _supabase
          .from('usuario')
          .select('*, empresa(*), rol(*)')
          .eq('id', userId)
          .single();

      final jsonEmpresa = Map<String, dynamic>.from(userData['empresa'] as Map);
      final jsonRol = Map<String, dynamic>.from(userData['rol'] as Map);
      final jsonUsuario = Map<String, dynamic>.from(userData);
      jsonUsuario.remove('empresa');
      jsonUsuario.remove('rol');

      final permissionsRaw = await _supabase
          .from('acceso_rol')
          .select()
          .eq('rol_id', jsonUsuario['rol_id'])
          .eq('estado', true);

      final permisos = (permissionsRaw as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .map(_accesoRolCompanionFromJson)
          .toList();

      await _authDao.replaceSesionActiva(
        empresa: _empresaCompanionFromJson(jsonEmpresa),
        usuario: _usuarioCompanionFromJson(jsonUsuario),
        rol: _rolCompanionFromJson(jsonRol),
        permisos: permisos,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_user_id', userId);
    } catch (e) {
      throw Exception('Error syncing session data from Supabase: $e');
    }
  }

  EmpresasCompanion _empresaCompanionFromJson(Map<String, dynamic> json) {
    return EmpresasCompanion.insert(
      id: json['id'] as String,
      nombre: json['nombre'] as String? ?? '',
      nombreComercial: Value(json['nombre_comercial'] as String?),
      ruc: Value(json['ruc'] as String?),
      configuracion: Value(json['configuracion']?.toString()),
      estado: Value(json['estado'] as bool? ?? true),
      usuarioRegistroId: Value(json['usuario_registro_id'] as String?),
      createdAt: Value(
        _parseDateTime(json['fecha_registro']) ?? DateTime.now(),
      ),
      updatedAt: Value(
        _parseDateTime(json['ultima_actualizacion']) ?? DateTime.now(),
      ),
      fechaEliminacion: Value(_parseDateTime(json['fecha_eliminacion'])),
      syncStatus: const Value('synced'),
    );
  }

  UsuariosCompanion _usuarioCompanionFromJson(Map<String, dynamic> json) {
    return UsuariosCompanion.insert(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      rolId: json['rol_id'] as String,
      nombreCompleto: json['nombre_completo'] as String? ?? '',
      correo: Value(json['correo'] as String?),
      passwordHash: Value(json['password_hash'] as String?),
      pinOffline: Value(json['pin_offline'] as String?),
      // The invited user's creator/default warehouse may not be part of this
      // first-login local snapshot, so keeping those remote FK values can break
      // SQLite inserts. They are audit/default references, not required to open
      // the session.
      usuarioRegistroId: const Value(null),
      bodegaDefaultId: const Value(null),
      estado: Value(json['estado'] as bool? ?? true),
      createdAt: Value(
        _parseDateTime(json['fecha_registro']) ?? DateTime.now(),
      ),
      updatedAt: Value(
        _parseDateTime(json['ultima_actualizacion']) ?? DateTime.now(),
      ),
      fechaEliminacion: Value(_parseDateTime(json['fecha_eliminacion'])),
      syncStatus: const Value('synced'),
    );
  }

  RolesCompanion _rolCompanionFromJson(Map<String, dynamic> json) {
    return RolesCompanion.insert(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      nombre: json['nombre'] as String? ?? '',
      userAdmin: Value(json['user_admin'] as bool? ?? false),
      usuarioRegistroId: Value(json['usuario_registro_id'] as String?),
      estado: Value(json['estado'] as bool? ?? true),
      createdAt: Value(
        _parseDateTime(json['fecha_registro']) ?? DateTime.now(),
      ),
      updatedAt: Value(
        _parseDateTime(json['ultima_actualizacion']) ?? DateTime.now(),
      ),
      fechaEliminacion: Value(_parseDateTime(json['fecha_eliminacion'])),
      syncStatus: const Value('synced'),
    );
  }

  AccesosRolCompanion _accesoRolCompanionFromJson(Map<String, dynamic> json) {
    return AccesosRolCompanion.insert(
      id: json['id'] as String,
      rolId: json['rol_id'] as String,
      codigoAcceso: json['codigo_acceso'] as String? ?? '',
      usuarioRegistroId: const Value(null),
      estado: Value(json['estado'] as bool? ?? true),
      createdAt: Value(
        _parseDateTime(json['fecha_registro']) ?? DateTime.now(),
      ),
      updatedAt: Value(
        _parseDateTime(json['ultima_actualizacion']) ?? DateTime.now(),
      ),
      fechaEliminacion: Value(_parseDateTime(json['fecha_eliminacion'])),
      syncStatus: const Value('synced'),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
