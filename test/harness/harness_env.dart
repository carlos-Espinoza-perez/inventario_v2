import 'dart:io';

/// Id del proyecto Supabase linkeado en `supabase/.temp/linked-project.json`
/// (producción). El harness nunca debe apuntarle a esto — solo a un
/// Supabase local (`supabase start`).
const linkedProductionProjectRef = 'tovzdapibtbufjrilptk';

/// Variables mínimas que necesita `AppConstants` para armar el cliente y el
/// proxy (ver lib/core/constants/app_constants.dart).
class HarnessEnv {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final Map<String, String> raw;

  const HarnessEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.raw,
  });

  /// Carga y valida `test/harness/.env.harness`. Aborta (lanza
  /// [StateError]) si el archivo no existe, si `SUPABASE_URL` no es
  /// localhost, o si contiene la ref del proyecto de producción linkeado
  /// — así un `.env.harness` mal copiado nunca termina pegándole a
  /// producción.
  static HarnessEnv loadAndValidate({String path = 'test/harness/.env.harness'}) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'No existe $path. El harness NO carga el .env raíz a propósito '
        '(aislamiento de Supabase local vs. producción): creá '
        '$path con SUPABASE_URL=http://127.0.0.1:54321 y el anon key que '
        'imprime `supabase start`. Ver test/harness/README.md.',
      );
    }

    final raw = <String, String>{};
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      raw[trimmed.substring(0, eq).trim()] = trimmed.substring(eq + 1).trim();
    }

    final url = raw['SUPABASE_URL'];
    final anonKey = raw['SUPABASE_ANON_KEY'];
    if (url == null || url.isEmpty) {
      throw StateError('$path no define SUPABASE_URL.');
    }
    if (anonKey == null || anonKey.isEmpty) {
      throw StateError('$path no define SUPABASE_ANON_KEY.');
    }

    final uri = Uri.tryParse(url);
    final isLocalhost = uri != null &&
        (uri.host == '127.0.0.1' || uri.host == 'localhost');
    if (!isLocalhost) {
      throw StateError(
        'SUPABASE_URL en $path ("$url") no es localhost. El harness se '
        'aborta a propósito: no debe pegarle a nada que no sea un Supabase '
        'local levantado con `supabase start`.',
      );
    }
    if (url.contains(linkedProductionProjectRef) ||
        raw.values.any((v) => v.contains(linkedProductionProjectRef))) {
      throw StateError(
        'SUPABASE_URL o alguna variable en $path contiene la ref del '
        'proyecto de producción linkeado ($linkedProductionProjectRef). '
        'El harness se aborta: revisá que $path apunte solo al Supabase '
        'local, nunca al proyecto real.',
      );
    }

    return HarnessEnv(supabaseUrl: url, supabaseAnonKey: anonKey, raw: raw);
  }
}
