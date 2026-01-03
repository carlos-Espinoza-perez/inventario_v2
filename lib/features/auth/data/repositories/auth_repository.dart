import 'package:inventario_v2/core/utils/password_hasher.dart';
import 'package:inventario_v2/features/auth/data/collections/empresa_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/rol_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/usuario_collection.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;
  final Isar _isar;

  AuthRepository(this._supabase, this._isar);

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
        throw Exception("No se pudo crear la empresa");
      }

      final data = response as Map<String, dynamic>;
      final jsonEmpresa = data['empresa'] as Map<String, dynamic>;
      final jsonUsuario = data['usuario'] as Map<String, dynamic>;
      final jsonRol = data['rol'] as Map<String, dynamic>;

      final newCompany = EmpresaCollection.fromJson(jsonEmpresa);
      final newUser = UsuarioCollection.fromJson(jsonUsuario);
      final newRol = RolCollection.fromJson(jsonRol);

      await _isar.writeTxn(() async {
        await _isar.empresaCollections.put(newCompany);
        await _isar.usuarioCollections.put(newUser);
        await _isar.rolCollections.put(newRol);
      });
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
        throw Exception("No se pudo iniciar sesión");
      }

      final userData = await _supabase
          .from('usuario')
          .select('*, empresa(*), rol(*)')
          .eq('id', user.id)
          .single();

      final jsonEmpresa = userData['empresa'] as Map<String, dynamic>;
      final jsonRol = userData['rol'] as Map<String, dynamic>;

      final jsonUsuario = Map<String, dynamic>.from(userData);
      jsonUsuario.remove('empresa');
      jsonUsuario.remove('rol');

      final newUser = UsuarioCollection.fromJson(jsonUsuario);
      final newEmpresa = EmpresaCollection.fromJson(jsonEmpresa);
      final newRol = RolCollection.fromJson(jsonRol);
      await _isar.writeTxn(() async {
        await _isar.empresaCollections.clear();
        await _isar.usuarioCollections.clear();
        await _isar.rolCollections.clear();

        await _isar.empresaCollections.put(newEmpresa);
        await _isar.usuarioCollections.put(newUser);
        await _isar.rolCollections.put(newRol);
      });
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw Exception('Error en Login Online: $e');
    }
  }

  Future<void> signInOffline(String email, String password) async {
    final user = await _isar.usuarioCollections
        .filter()
        .correoEqualTo(email)
        .findFirst();

    if (user == null) {
      throw Exception(
        "No hay datos guardados para este usuario. Conéctate a internet para el primer inicio.",
      );
    }

    if (user.passwordHash == null) {
      throw Exception("Seguridad no sincronizada. Inicia sesión con internet.");
    }

    final isPasswordValid = PasswordHasher.checkPassword(
      password,
      user.passwordHash!,
    );

    if (!isPasswordValid) {
      throw Exception("Contraseña incorrecta.");
    }
  }
}
