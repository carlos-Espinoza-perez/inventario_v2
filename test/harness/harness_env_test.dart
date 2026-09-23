import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'harness_env.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('harness_env_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  String write(String contents) {
    final path = '${tempDir.path}/.env.harness';
    File(path).writeAsStringSync(contents);
    return path;
  }

  test('archivo inexistente aborta con StateError', () {
    expect(
      () => HarnessEnv.loadAndValidate(
        path: '${tempDir.path}/no-existe.env',
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('SUPABASE_URL apuntando a producción (linkeado) aborta', () {
    final path = write('''
SUPABASE_URL=https://tovzdapibtbufjrilptk.supabase.co
SUPABASE_ANON_KEY=algo
''');
    expect(
      () => HarnessEnv.loadAndValidate(path: path),
      throwsA(isA<StateError>()),
    );
  });

  test('SUPABASE_URL que no es localhost aborta aunque no sea la ref conocida',
      () {
    final path = write('''
SUPABASE_URL=https://otro-proyecto-cualquiera.supabase.co
SUPABASE_ANON_KEY=algo
''');
    expect(
      () => HarnessEnv.loadAndValidate(path: path),
      throwsA(isA<StateError>()),
    );
  });

  test('falta SUPABASE_ANON_KEY aborta', () {
    final path = write('SUPABASE_URL=http://127.0.0.1:54321\n');
    expect(
      () => HarnessEnv.loadAndValidate(path: path),
      throwsA(isA<StateError>()),
    );
  });

  test('URL local válida carga bien', () {
    final path = write('''
# comentario
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=anon-local-key
OPENAI_MODEL=gpt-4o-mini
''');
    final env = HarnessEnv.loadAndValidate(path: path);
    expect(env.supabaseUrl, 'http://127.0.0.1:54321');
    expect(env.supabaseAnonKey, 'anon-local-key');
    expect(env.raw['OPENAI_MODEL'], 'gpt-4o-mini');
  });

  test('localhost (nombre) también se acepta, no solo 127.0.0.1', () {
    final path = write('''
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=anon-local-key
''');
    final env = HarnessEnv.loadAndValidate(path: path);
    expect(env.supabaseUrl, 'http://localhost:54321');
  });
}
