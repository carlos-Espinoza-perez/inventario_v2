import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/sesion_activa_drift.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  SesionActivaDrift? _sesionActiva;

  SessionUserDrift? get usuarioActual => _sesionActiva?.userView;
  SesionActivaDrift? get sesionActiva => _sesionActiva;

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
      state = AsyncError('Faltan datos de empresa', StackTrace.current);
      return;
    }

    try {
      final supabase = ref.read(supabaseClientProvider);
      final db = ref.read(driftDatabaseProvider);
      final repo = AuthRepository(supabase, db);

      debugPrint('[Auth] Iniciando registro: $correo');

      final authResponse = await supabase.auth.signUp(
        email: correo,
        password: contrasena,
        data: {'name': nombre},
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception(
          'El registro falló. Verifica tu conexión o intenta otro correo.',
        );
      }

      await repo.createCompanyAndUser(
        nombre: _draft!.nombre,
        nombreComercial: _draft!.nombreComercial,
        ruc: _draft!.ruc,
        userId: user.id,
        userEmail: user.email!,
        userNombre: nombre,
        userPassword: contrasena,
      );

      _sesionActiva = await db.authDao.getSesionActiva();
      ref.read(autoSyncProvider.notifier).runFullSync();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('[Auth] Error en createUser: $e');
      state = AsyncError(e.toString(), st);
    }
  }

  Future<SessionUserDrift?> getUser() async {
    final db = ref.read(driftDatabaseProvider);
    _sesionActiva ??= await db.authDao.getSesionActiva();
    return _sesionActiva?.userView;
  }

  Future<Empresa?> getEmpresaActual() async {
    final db = ref.read(driftDatabaseProvider);
    _sesionActiva ??= await db.authDao.getSesionActiva();
    return _sesionActiva?.empresa ?? await db.authDao.getEmpresaActual();
  }

  Future<void> checkAuthStatus() async {
    final db = ref.read(driftDatabaseProvider);

    _sesionActiva = await db.authDao.getSesionActiva();
    state = const AsyncData(null);
  }

  FutureOr<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseClientProvider);
      final db = ref.read(driftDatabaseProvider);
      final repo = AuthRepository(supabase, db);

      try {
        await repo.singInOnline(email, password);
      } catch (e) {
        final esErrorDeRed =
            e.toString().contains('SocketException') ||
            e.toString().contains('Network') ||
            e.toString().contains('ClientException');

        if (esErrorDeRed) {
          await repo.signInOffline(email, password);
        } else {
          rethrow;
        }
      }

      _sesionActiva = await db.authDao.getSesionActiva();
      debugPrint('[Auth] Login exitoso: ${_sesionActiva?.usuario.id}');
      ref.read(autoSyncProvider.notifier).runFullSync();
    } catch (e, stackTrace) {
      debugPrint('[Auth] Error en login: $e');
      state = AsyncError(e, stackTrace);
      return;
    }

    state = const AsyncData(null);
  }

  Future<void> logout() async {
    final db = ref.read(driftDatabaseProvider);
    final supabase = ref.read(supabaseClientProvider);

    try {
      await supabase.auth.signOut();
    } catch (_) {}

    await db.authDao.clearSesion();

    _sesionActiva = null;
    state = const AsyncData(null);
  }
}

final currentEmpresaProvider = FutureProvider<Empresa?>((ref) async {
  final auth = ref.read(authControllerProvider.notifier);
  return auth.getEmpresaActual();
});
