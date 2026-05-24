import 'package:drift/drift.dart';
import 'package:inventario_v2/core/db/models/sesion_activa_drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:inventario_v2/core/db/app_database.dart';

class StaffAccountRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  StaffAccountRepository(this._supabase, this._db);

  Future<String> createStaffAccount({
    required SessionUserDrift currentUser,
    required String nombre,
    required String correo,
    required String rolId,
    required Set<String> bodegaIds,
  }) async {
    final response = await _supabase.functions.invoke(
      'create-staff-user',
      body: {
        'empresa_id': currentUser.empresaId,
        'admin_user_id': currentUser.serverId,
        'nombre_completo': nombre,
        'correo': correo,
        'rol_id': rolId,
        'bodega_ids': bodegaIds.toList(),
      },
    );

    if (response.status != 200 && response.status != 201) {
      throw Exception(
        response.data is Map<String, dynamic>
            ? (response.data['error'] ?? 'No se pudo crear el personal')
            : 'No se pudo crear el personal',
      );
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta inválida al crear el personal');
    }

    final userJson = Map<String, dynamic>.from(data['usuario'] as Map);
    final assignmentsJson = (data['bodega_usuario'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    await _db.transaction(() async {
      await _db.into(_db.usuarios).insertOnConflictUpdate(
        UsuariosCompanion.insert(
          id: userJson['id'] as String,
          empresaId: userJson['empresa_id'] as String,
          rolId: userJson['rol_id'] as String,
          nombreCompleto: userJson['nombre_completo'] as String? ?? '',
          correo: Value(userJson['correo'] as String?),
          passwordHash: Value(userJson['password_hash'] as String?),
          pinOffline: Value(userJson['pin_offline'] as String?),
          usuarioRegistroId: Value(userJson['usuario_registro_id'] as String?),
          bodegaDefaultId: Value(userJson['bodega_default_id'] as String?),
          estado: Value(userJson['estado'] as bool? ?? true),
          createdAt: Value(
            DateTime.tryParse(userJson['fecha_registro']?.toString() ?? '') ??
                DateTime.now(),
          ),
          updatedAt: Value(
            DateTime.tryParse(
                  userJson['ultima_actualizacion']?.toString() ?? '',
                ) ??
                DateTime.now(),
          ),
          fechaEliminacion: Value(
            DateTime.tryParse(userJson['fecha_eliminacion']?.toString() ?? ''),
          ),
          syncStatus: const Value('synced'),
        ),
      );

      for (final assignmentJson in assignmentsJson) {
        await _db.into(_db.bodegasUsuarios).insertOnConflictUpdate(
          BodegasUsuariosCompanion.insert(
            id: assignmentJson['id'] as String,
            usuarioId: assignmentJson['usuario_id'] as String,
            bodegaId: assignmentJson['bodega_id'] as String,
            usuarioRegistroId: Value(
              assignmentJson['usuario_registro_id'] as String?,
            ),
            estado: Value(assignmentJson['estado'] as bool? ?? true),
            createdAt: Value(
              DateTime.tryParse(
                    assignmentJson['fecha_registro']?.toString() ?? '',
                  ) ??
                  DateTime.now(),
            ),
            updatedAt: Value(
              DateTime.tryParse(
                    assignmentJson['ultima_actualizacion']?.toString() ?? '',
                  ) ??
                  DateTime.now(),
            ),
            fechaEliminacion: Value(
              DateTime.tryParse(
                assignmentJson['fecha_eliminacion']?.toString() ?? '',
              ),
            ),
            syncStatus: const Value('synced'),
          ),
        );
      }
    });

    return userJson['id'] as String;
  }

  /// Resetea la contraseña de un usuario staff.
  /// Retorna la contraseña temporal generada.
  /// Solo puede ser invocado por un admin de la misma empresa.
  Future<String> resetStaffPassword({
    required String targetUserId,
    required String empresaId,
  }) async {
    final response = await _supabase.functions.invoke(
      'reset-staff-password',
      body: {
        'target_user_id': targetUserId,
        'empresa_id': empresaId,
      },
    );

    if (response.status != 200) {
      final data = response.data;
      throw Exception(
        data is Map<String, dynamic>
            ? (data['error'] ?? 'No se pudo resetear la contraseña')
            : 'No se pudo resetear la contraseña',
      );
    }

    final data = response.data;
    if (data is! Map<String, dynamic> || data['temp_password'] == null) {
      throw Exception('Respuesta inválida al resetear contraseña');
    }

    return data['temp_password'] as String;
  }

  /// Re-envía la invitación a un usuario staff que no ha activado su cuenta.
  /// Usa la misma Edge Function de creación que re-invita por email.
  Future<void> resendInvitation({
    required String correo,
    required String empresaId,
    required String adminUserId,
    required String nombre,
    required String rolId,
    required Set<String> bodegaIds,
  }) async {
    // Reutiliza la Edge Function create-staff-user
    // que internamente llama a inviteUserByEmail.
    // Si el usuario ya existe, Supabase re-envía la invitación.
    final response = await _supabase.functions.invoke(
      'create-staff-user',
      body: {
        'empresa_id': empresaId,
        'admin_user_id': adminUserId,
        'nombre_completo': nombre,
        'correo': correo,
        'rol_id': rolId,
        'bodega_ids': bodegaIds.toList(),
      },
    );

    if (response.status != 200 && response.status != 201) {
      final data = response.data;
      throw Exception(
        data is Map<String, dynamic>
            ? (data['error'] ?? 'No se pudo re-enviar la invitación')
            : 'No se pudo re-enviar la invitación',
      );
    }
  }
}
