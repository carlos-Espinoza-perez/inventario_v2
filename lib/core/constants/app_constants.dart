import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Evitamos instanciar la clase
  AppConstants._();

  // Credenciales de Supabase desde variables de entorno
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? _throwMissingEnvVar('SUPABASE_URL');
  
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? _throwMissingEnvVar('SUPABASE_ANON_KEY');

  static String _throwMissingEnvVar(String key) {
    throw Exception(
      'Variable de entorno $key no encontrada. '
      'Asegúrate de tener un archivo .env con las credenciales de Supabase.'
    );
  }
}
