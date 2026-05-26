import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

enum RemoteLogLevel { info, warning, error, critical }

class _AppInfo {
  final String versionName;
  final int versionCode;
  final String buildNumber;
  final String deviceModel;
  final String androidVersion;

  const _AppInfo({
    required this.versionName,
    required this.versionCode,
    required this.buildNumber,
    required this.deviceModel,
    required this.androidVersion,
  });
}

class RemoteLogger {
  static final RemoteLogger _instance = RemoteLogger._internal();
  factory RemoteLogger() => _instance;
  RemoteLogger._internal();

  AppDatabase? _db;
  SupabaseClient? _supabase;
  _AppInfo? _appInfo;
  bool _initialized = false;

  static Future<void> init(AppDatabase db, SupabaseClient supabase) async {
    _instance._db = db;
    _instance._supabase = supabase;
    await _instance._loadAppInfo();
    _instance._initialized = true;
    debugPrint('[RemoteLogger] Inicializado.');
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      String deviceModel = 'unknown';
      String androidVersion = 'unknown';

      if (Platform.isAndroid) {
        // device_info_plus no está en pubspec; usamos valores derivables
        deviceModel = Platform.operatingSystemVersion.split(' ').first;
        androidVersion = Platform.operatingSystemVersion;
      }

      _appInfo = _AppInfo(
        versionName: info.version,
        versionCode: int.tryParse(info.buildNumber) ?? 0,
        buildNumber: info.buildNumber,
        deviceModel: deviceModel,
        androidVersion: androidVersion,
      );
    } catch (e) {
      debugPrint('[RemoteLogger] No se pudo cargar info del app/dispositivo: $e');
    }
  }

  // ── API pública estática ────────────────────────────────────────────────

  static void info(
    String message, {
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    Map<String, dynamic>? metadata,
  }) {
    _instance._log(
      RemoteLogLevel.info,
      message,
      module: module,
      screen: screen,
      action: action,
      userId: userId,
      empresaId: empresaId,
      bodegaId: bodegaId,
      metadata: metadata,
    );
  }

  static void warning(
    String message, {
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    _instance._log(
      RemoteLogLevel.warning,
      message,
      module: module,
      screen: screen,
      action: action,
      userId: userId,
      empresaId: empresaId,
      bodegaId: bodegaId,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  static void error(
    String message, {
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    String? errorCode,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final enrichedMeta = <String, dynamic>{...?metadata};
    if (exception != null) enrichedMeta['exception'] = exception.toString();
    if (stackTrace != null) {
      enrichedMeta['stackTrace'] = stackTrace
          .toString()
          .split('\n')
          .take(10)
          .join('\n');
    }

    _instance._log(
      RemoteLogLevel.error,
      message,
      module: module,
      screen: screen,
      action: action,
      userId: userId,
      empresaId: empresaId,
      bodegaId: bodegaId,
      errorCode: errorCode,
      metadata: enrichedMeta.isNotEmpty ? enrichedMeta : null,
    );
  }

  static void critical(
    String message, {
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    String? errorCode,
    Object? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    final enrichedMeta = <String, dynamic>{...?metadata};
    if (exception != null) enrichedMeta['exception'] = exception.toString();
    if (stackTrace != null) {
      enrichedMeta['stackTrace'] = stackTrace
          .toString()
          .split('\n')
          .take(15)
          .join('\n');
    }

    _instance._log(
      RemoteLogLevel.critical,
      message,
      module: module,
      screen: screen,
      action: action,
      userId: userId,
      empresaId: empresaId,
      bodegaId: bodegaId,
      errorCode: errorCode,
      metadata: enrichedMeta.isNotEmpty ? enrichedMeta : null,
    );
  }

  // ── Lógica interna ──────────────────────────────────────────────────────

  void _log(
    RemoteLogLevel level,
    String message, {
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) {
    if (!_initialized || _db == null) {
      debugPrint('[RemoteLogger] No inicializado. Log descartado: $message');
      return;
    }
    // fire-and-forget — no bloquea el hilo principal
    _persistAndSend(
      level: level,
      message: message,
      module: module,
      screen: screen,
      action: action,
      userId: userId,
      empresaId: empresaId,
      bodegaId: bodegaId,
      errorCode: errorCode,
      metadata: metadata,
    );
  }

  Future<void> _persistAndSend({
    required RemoteLogLevel level,
    required String message,
    String? module,
    String? screen,
    String? action,
    String? userId,
    String? empresaId,
    String? bodegaId,
    String? errorCode,
    Map<String, dynamic>? metadata,
  }) async {
    final db = _db;
    if (db == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = !connectivity.contains(ConnectivityResult.none);

    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();

    final companion = AppLogsCompanion.insert(
      id: id,
      createdAt: Value(now),
      level: level.name,
      module: Value(module),
      screen: Value(screen),
      action: Value(action),
      message: message,
      errorCode: Value(errorCode),
      userId: Value(userId),
      empresaId: Value(empresaId),
      bodegaId: Value(bodegaId),
      appVersionName: Value(_appInfo?.versionName),
      appVersionCode: Value(_appInfo?.versionCode),
      buildNumber: Value(_appInfo?.buildNumber),
      deviceModel: Value(_appInfo?.deviceModel),
      androidVersion: Value(_appInfo?.androidVersion),
      isOnline: Value(isOnline),
      metadataJson: Value(metadata != null ? jsonEncode(metadata) : null),
      sentToRemote: const Value(false),
    );

    try {
      await db.into(db.appLogs).insert(companion);
    } catch (e) {
      debugPrint('[RemoteLogger] Error al guardar log local: $e');
      return;
    }

    if (isOnline) {
      await _uploadLog(id, db);
    }
  }

  Future<void> _uploadLog(String logId, AppDatabase db) async {
    final supabase = _supabase;
    if (supabase == null) return;

    try {
      final row = await (db.select(db.appLogs)
            ..where((t) => t.id.equals(logId)))
          .getSingleOrNull();
      if (row == null) return;

      await supabase.from('debug_logs').insert({
        'id': row.id,
        'created_at': row.createdAt.toIso8601String(),
        'level': row.level,
        'module': row.module,
        'screen': row.screen,
        'action': row.action,
        'message': row.message,
        'error_code': row.errorCode,
        'user_id': row.userId,
        'empresa_id': row.empresaId,
        'bodega_id': row.bodegaId,
        'app_version_name': row.appVersionName,
        'app_version_code': row.appVersionCode,
        'build_number': row.buildNumber,
        'device_model': row.deviceModel,
        'android_version': row.androidVersion,
        'is_online': row.isOnline,
        'metadata_json': row.metadataJson,
      });

      await (db.update(db.appLogs)..where((t) => t.id.equals(logId))).write(
        AppLogsCompanion(
          sentToRemote: const Value(true),
          remoteSentAt: Value(DateTime.now().toUtc()),
        ),
      );
    } catch (e) {
      // quedó sent_to_remote = false; se reintenta en flushPending
      debugPrint('[RemoteLogger] Error al subir log a Supabase: $e');
    }
  }

  /// Sube todos los logs pendientes. Llamar cuando se recupera la conexión.
  static Future<void> flushPending() async {
    await _instance._doFlushPending();
  }

  Future<void> _doFlushPending() async {
    final db = _db;
    final supabase = _supabase;
    if (db == null || supabase == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final pending = await (db.select(db.appLogs)
          ..where((t) => t.sentToRemote.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(100))
        .get();

    if (pending.isEmpty) return;

    debugPrint('[RemoteLogger] Subiendo ${pending.length} logs pendientes...');

    for (final row in pending) {
      await _uploadLog(row.id, db);
    }

    await _cleanOldLogs(db);
  }

  /// Elimina logs enviados con más de 30 días de antigüedad.
  Future<void> _cleanOldLogs(AppDatabase db) async {
    final cutoff = DateTime.now().toUtc().subtract(const Duration(days: 30));
    await (db.delete(db.appLogs)
          ..where(
            (t) =>
                t.sentToRemote.equals(true) &
                t.createdAt.isSmallerThanValue(cutoff),
          ))
        .go();
  }
}
