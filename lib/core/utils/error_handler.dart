import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String humanize(Object error) {
    final rawMessage = error.toString();

    if (error is AuthException) {
      final authMessage = error.message.toLowerCase();
      if (authMessage.contains('new password should be different') ||
          authMessage.contains('same password') ||
          authMessage.contains('different from the old')) {
        return 'La nueva contraseña debe ser diferente a la actual.';
      }
      if (authMessage.contains('invalid login credentials')) {
        return 'Correo o contraseña incorrectos. Revisa tus datos e inténtalo nuevamente.';
      }
      if (authMessage.contains('user already registered')) {
        return 'Este correo ya está registrado. Intenta iniciar sesión.';
      }
      if (authMessage.contains('email not confirmed')) {
        return 'Tu correo no ha sido verificado.';
      }
      if (authMessage.contains('password should be at least')) {
        return 'La contraseña es muy débil.';
      }
      return error.message;
    }

    if (rawMessage.contains('SocketException') ||
        rawMessage.contains('Network is unreachable') ||
        rawMessage.contains('ClientException') ||
        rawMessage.contains('Connection refused')) {
      return 'No tienes conexión a internet. Verifica tu red.';
    }

    if (rawMessage.contains('Error syncing session data') ||
        rawMessage.contains('SqliteException') ||
        rawMessage.contains('FOREIGN KEY constraint failed') ||
        rawMessage.contains('replaceSesionActiva') ||
        rawMessage.contains('INSERT INTO')) {
      return 'No pudimos preparar tu sesión local. Verifica tu conexión e intenta iniciar sesión nuevamente.';
    }

    if (rawMessage.startsWith('Exception: ')) {
      return rawMessage.replaceAll('Exception: ', '');
    }

    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }
}
