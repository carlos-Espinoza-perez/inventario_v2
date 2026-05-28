import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/db/models/sesion_activa_drift.dart';
import 'package:inventario_v2/core/providers/auto_sync_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/providers/supabase_provider.dart';
import 'package:inventario_v2/features/auth/data/repositories/auth_repository.dart';
import 'package:inventario_v2/core/services/remote_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  String? _linkError;
  String? _sessionSyncError;
  bool _passwordRecoveryPending = false;
  bool _isLoggingOut = false;

  SessionUserDrift? get usuarioActual => _sesionActiva?.userView;
  SesionActivaDrift? get sesionActiva => _sesionActiva;
  String? get linkError => _linkError;
  String? get sessionSyncError => _sessionSyncError;
  bool get passwordRecoveryPending => _passwordRecoveryPending;
  bool get isLoggingOut => _isLoggingOut;

  @override
  FutureOr<void> build() async {
    await checkAuthStatus();

    final supabase = ref.read(supabaseClientProvider);
    final subscription = supabase.auth.onAuthStateChange.listen(
      (data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.passwordRecovery) {
          _passwordRecoveryPending = session != null;
          _linkError = null;
          state = const AsyncData(null);
        }

        // Cuando el usuario inicia sesion activamente (no restauracion de cache)
        // y tiene must_change_password, activar el flujo de cambio forzado.
        if (event == AuthChangeEvent.signedIn) {
          final mustChange =
              session?.user.userMetadata?['must_change_password'] == true;
          if (mustChange) {
            _passwordRecoveryPending = true;
          }
        }

        if (event == AuthChangeEvent.initialSession ||
            event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.passwordRecovery) {
          if (session != null &&
              (_sesionActiva == null ||
                  _sesionActiva!.usuario.id != session.user.id)) {
            // Si estamos en el flujo de creación de empresa nueva (tenemos _draft),
            // evitamos el sync automático porque public.usuario está vacío temporalmente
            // hasta que se ejecute repo.createCompanyAndUser en la llamada de createUser.
            if (_draft != null) {
              debugPrint('[Auth] Detectada creación de empresa en curso, omitiendo sincronización automática en stream.');
              return;
            }

            state = const AsyncLoading();
            try {
              await _syncSessionFromSupabaseUser(session.user.id);
              state = const AsyncData(null);
            } catch (e, st) {
              debugPrint('[Auth] Error syncing session on auth event: $e');
              RemoteLogger.error(
                'Error al restaurar sesión desde Supabase',
                module: 'auth',
                action: 'session_restore_error',
                exception: e,
                stackTrace: st,
              );
              _sessionSyncError = e.toString();
              _sesionActiva = null;
              state = AsyncError(e, StackTrace.current);
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          if (_sesionActiva != null) {
            await logout();
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (error is AuthException &&
            (error.statusCode == 'otp_expired' ||
                error.code == 'otp_expired' ||
                error.message.toLowerCase().contains('expired'))) {
          _linkError = 'otp_expired';
        } else {
          _linkError = error.toString();
        }
        state = const AsyncData(null); // Refresca las rutas
      },
    );

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  void setEmpresaDraft(EmpresaDraft empresaDraft) {
    _draft = empresaDraft;
  }

  void clearLinkError() {
    _linkError = null;
    state = const AsyncData(null);
  }

  void setLinkError(String error) {
    _linkError = error;
    state = const AsyncData(null);
  }

  void clearSessionSyncError() {
    _sessionSyncError = null;
    state = const AsyncData(null);
  }

  Future<void> _syncSessionFromSupabaseUser(String userId) async {
    final supabase = ref.read(supabaseClientProvider);
    final db = ref.read(driftDatabaseProvider);
    final repo = AuthRepository(supabase, db);

    await repo.syncSupabaseUserToLocal(userId);
    _sesionActiva = await db.authDao.getSesionActiva();
    _sessionSyncError = null;
    ref.read(autoSyncProvider.notifier).runFullSync();
  }

  Future<void> completePasswordChange(String password) async {
    state = const AsyncLoading();

    try {
      final supabase = ref.read(supabaseClientProvider);
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception(
          'La sesion de recuperacion expiro. Solicita un nuevo enlace.',
        );
      }

      await supabase.auth.updateUser(
        UserAttributes(
          password: password,
          data: {'must_change_password': false},
        ),
      );

      await _syncSessionFromSupabaseUser(currentUser.id);
      _passwordRecoveryPending = false;
      _linkError = null;
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('[Auth] Error al completar cambio de password: $e');
      state = AsyncError(e, st);
      rethrow;
    }
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

    state = const AsyncLoading();

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
      RemoteLogger.info(
        'Empresa y usuario creados exitosamente',
        module: 'auth',
        action: 'register_success',
        userId: _sesionActiva?.usuario.id,
        empresaId: _sesionActiva?.empresa.id,
      );
      ref.read(autoSyncProvider.notifier).runFullSync();

      // Limpiamos el borrador para que los eventos posteriores puedan sincronizar con normalidad
      _draft = null;

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('[Auth] Error en createUser: $e');
      RemoteLogger.error(
        'Error al crear empresa/usuario',
        module: 'auth',
        action: 'register_error',
        exception: e,
        stackTrace: st,
      );
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
      RemoteLogger.info(
        'Login exitoso',
        module: 'auth',
        action: 'login_success',
        userId: _sesionActiva?.usuario.id,
        empresaId: _sesionActiva?.empresa.id,
      );
      ref.read(autoSyncProvider.notifier).runFullSync();
      _sessionSyncError = null;
      _linkError = null;
    } catch (e, stackTrace) {
      debugPrint('[Auth] Error en login: $e');
      RemoteLogger.error(
        'Error en login',
        module: 'auth',
        action: 'login_error',
        exception: e,
        stackTrace: stackTrace,
      );
      state = AsyncError(e, stackTrace);
      return;
    }

    state = const AsyncData(null);
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final db = ref.read(driftDatabaseProvider);
    final supabase = ref.read(supabaseClientProvider);

    final userId = _sesionActiva?.usuario.id;
    final empresaId = _sesionActiva?.empresa.id;
    try {
      await supabase.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_user_id');

      await db.authDao.clearSesion();

      RemoteLogger.info(
        'Logout exitoso',
        module: 'auth',
        action: 'logout',
        userId: userId,
        empresaId: empresaId,
      );

      _sesionActiva = null;
      _passwordRecoveryPending = false;
      _sessionSyncError = null;
      _linkError = null;
      state = const AsyncData(null);
    } catch (e) {
      debugPrint('[Auth] No se pudo cerrar sesion: $e');
      rethrow;
    } finally {
      _isLoggingOut = false;
    }
  }
}

final currentEmpresaProvider = FutureProvider<Empresa?>((ref) async {
  final auth = ref.read(authControllerProvider.notifier);
  return auth.getEmpresaActual();
});
