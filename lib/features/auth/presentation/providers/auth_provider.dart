import 'dart:async';
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

    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseClientProvider);

      // Generando usuario
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

      // Generando empresa
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

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
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

    // Buscamos si existe ALGÚN usuario guardado
    // Como es "Un Solo Usuario", el primero que encontremos es el dueño.
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
          // Si es contraseña incorrecta o usuario no encontrado, relanzamos el error
          rethrow;
        }
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }

    checkAuthStatus();
    state = const AsyncData(null);
  }
}
