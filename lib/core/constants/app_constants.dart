import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Evitamos instanciar la clase
  AppConstants._();

  // Credenciales de Supabase desde variables de entorno
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? _throwMissingEnvVar('SUPABASE_URL');
  
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? _throwMissingEnvVar('SUPABASE_ANON_KEY');

  // OpenAI — Secretario IA
  // La API key ya no viaja en la app: las llamadas pasan por la Edge Function
  // openai-proxy, que guarda la key como secreto del servidor.
  static String get openAiProxyUrl => '$supabaseUrl/functions/v1/openai-proxy';

  static String get openAiModel =>
      dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';

  static double get openAiTemperature =>
      double.tryParse(dotenv.env['OPENAI_TEMPERATURE'] ?? '') ?? 0.2;

  static int get openAiMaxTokens =>
      int.tryParse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '') ?? 1024;

  static int get assistantMaxReactIterations =>
      int.tryParse(dotenv.env['ASSISTANT_MAX_REACT_ITERATIONS'] ?? '') ?? 6;

  static int get assistantHistoryTurns =>
      int.tryParse(dotenv.env['ASSISTANT_HISTORY_TURNS'] ?? '') ?? 12;

  static String _throwMissingEnvVar(String key) {
    throw Exception(
      'Variable de entorno $key no encontrada. '
      'Asegúrate de tener un archivo .env con las credenciales.',
    );
  }
}
