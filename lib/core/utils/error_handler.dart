import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String humanize(Object error) {
    // 1. Convertimos el error a String para analizarlo si no encaja en tipos conocidos
    final String rawMessage = error.toString();

    // 2. Errores de SUPABASE (AuthException)
    if (error is AuthException) {
      if (error.message.contains("Invalid login credentials")) {
        return "Correo o contraseña incorrectos.";
      }
      if (error.message.contains("User already registered")) {
        return "Este correo ya está registrado. Intenta iniciar sesión.";
      }
      if (error.message.contains("Email not confirmed")) {
        return "Tu correo no ha sido verificado.";
      }
      if (error.message.contains("Password should be at least")) {
        return "La contraseña es muy débil.";
      }
      // Mensaje por defecto de Supabase si no es ninguno de los anteriores
      return error.message;
    }

    // 3. Errores de CONEXIÓN (Internet)
    // Buscamos palabras clave comunes en errores de red
    if (rawMessage.contains("SocketException") ||
        rawMessage.contains("Network is unreachable") ||
        rawMessage.contains("ClientException") ||
        rawMessage.contains("Connection refused")) {
      return "No tienes conexión a internet. Verifica tu red.";
    }

    // 4. Errores de BASE DE DATOS LOCAL (Isar)
    if (rawMessage.contains("IsarError")) {
      return "Error interno de base de datos.";
    }

    // 5. Errores Personalizados (Los que tú lanzas con throw Exception("..."))
    if (rawMessage.startsWith("Exception: ")) {
      return rawMessage.replaceAll("Exception: ", "");
    }

    // 6. Fallback (Si no sabemos qué pasó)
    return "Ocurrió un error inesperado. Inténtalo de nuevo.";
  }
}
