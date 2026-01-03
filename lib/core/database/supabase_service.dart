import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Getter simple para acceder al cliente desde cualquier lado
  SupabaseClient get client => Supabase.instance.client;

  // Getter para saber si hay usuario logueado actualmente
  User? get currentUser => client.auth.currentUser;

  // Getter para saber si hay sesión activa
  bool get hasSession => client.auth.currentSession != null;

  // Función para cerrar sesión (útil globalmente)
  Future<void> signOut() async {
    await client.auth.signOut();
  }
}
