import 'package:shared_preferences/shared_preferences.dart';

/// Persiste el timestamp del último pull exitoso por tabla.
/// Permite pull incremental: solo descarga filas modificadas desde el último sync.
class SyncCursorStore {
  static const _prefix = 'sync_cursor_';

  static Future<DateTime?> getLastPullAt(String tableName) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('$_prefix$tableName');
    return stored != null ? DateTime.tryParse(stored) : null;
  }

  static Future<void> setLastPullAt(String tableName, DateTime dt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$tableName', dt.toUtc().toIso8601String());
  }

  /// Borra todos los cursores. El próximo pull será completo para todas las tablas.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
