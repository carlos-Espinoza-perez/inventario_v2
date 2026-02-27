import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:inventario_v2/features/auth/data/collections/usuario_collection.dart';
import 'package:inventario_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';

part 'auth_provider.g.dart';

class EmpresaDraft {
  final String nombre;
  final String nombreComercial;
  final String ruc;

  EmpresaDraft({
    required this.nombre,
    required this.nombreComercial,
    required this.ruc,
  });
}

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  EmpresaDraft? _draft;

  UsuarioCollection? _usuarioLocal;

  UsuarioCollection? get usuarioActual => _usuarioLocal;

  @override
  FutureOr<void> build() async {
    await checkAuthStatus();
  }

  void setEmpresaDraft(EmpresaDraft empresaDraft) {
    _draft = empresaDraft;
  }

  FutureOr<void> createUser(
    String nombre,
    String correo,
    String contrasena,
  ) async {
    if (_draft == null) {
      state = AsyncError("Faltan datos de empresa", StackTrace.current);
      return;
    }

    // NO ponemos AsyncLoading aquí: hacemos la carga localmente en el widget
    // para evitar que el router intercepte y redirija al /splash.
    // Sólo cambiamos el estado cuando hay éxito o error definitivo.

    try {
      final supabase = ref.read(supabaseClientProvider);

      debugPrint('🔐 [Auth] Iniciando registro: $correo');

      // 1. Crear usuario en Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: correo,
        password: contrasena,
        data: {'name': nombre},
      );

      final user = authResponse.user;

      if (user == null) {
        throw Exception(
          "El registro falló. Verifica tu conexión o intenta otro correo.",
        );
      }

      debugPrint('✅ [Auth] Usuario Auth creado: ${user.id}');

      // 2. Crear empresa, rol y usuario en Supabase + Isar
      final isar = await ref.read(isarDbProvider.future);
      final repo = AuthRepository(supabase, isar);

      await repo.createCompanyAndUser(
        nombre: _draft!.nombre,
        nombreComercial: _draft!.nombreComercial,
        ruc: _draft!.ruc,
        userId: user.id,
        userEmail: user.email!,
        userNombre: nombre,
        userPassword: contrasena,
      );

      debugPrint('✅ [Auth] Empresa creada exitosamente');

      // 3. Cargar el usuario local inmediatamente para que el router
      //    vea _usuarioLocal != null y redirija a /dashboard
      _usuarioLocal = await isar.usuarioCollections.where().findFirst();
      debugPrint('✅ [Auth] Usuario local cargado: $_usuarioLocal');

      // 4. Notificar éxito (dispara redirect del router → /dashboard)
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('❌ [Auth] Error en createUser: $e');
      debugPrint('   StackTrace: $st');
      state = AsyncError(e.toString(), st);
    }
  }

  Future<UsuarioCollection?> getUser() async {
    final isar = await ref.read(isarDbProvider.future);
    final user = await isar.usuarioCollections.where().findFirst();
    _usuarioLocal = user;
    return user;
  }

  Future<void> checkAuthStatus() async {
    final isar = await ref.read(isarDbProvider.future);

    final user = await isar.usuarioCollections.where().findFirst();

    if (user != null) {
      _usuarioLocal = user;
      state = const AsyncData(null);
    } else {
      _usuarioLocal = null;
      state = const AsyncData(null);
    }
  }

  FutureOr<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseClientProvider);
      final isar = await ref.read(isarDbProvider.future);
      final repo = AuthRepository(supabase, isar);

      try {
        await repo.singInOnline(email, password);
      } catch (e) {
        final esErrorDeRed =
            e.toString().contains("SocketException") ||
            e.toString().contains("Network") ||
            e.toString().contains("ClientException");

        if (esErrorDeRed) {
          await repo.signInOffline(email, password);
        } else {
          rethrow;
        }
      }

      // Actualizar usuario local después de login exitoso
      final user = await isar.usuarioCollections.where().findFirst();
      _usuarioLocal = user;
      debugPrint('✅ [Auth] Login exitoso: $_usuarioLocal');
    } catch (e, stackTrace) {
      debugPrint('❌ [Auth] Error en login: $e');
      state = AsyncError(e, stackTrace);
      return;
    }

    state = const AsyncData(null);
  }

  Future<void> logout() async {
    final isar = await ref.read(isarDbProvider.future);
    final supabase = ref.read(supabaseClientProvider);

    try {
      await supabase.auth.signOut();
    } catch (_) {}

    await isar.writeTxn(() async {
      await isar.usuarioCollections.clear();
    });

    _usuarioLocal = null;
    state = const AsyncData(null);
  }
}
