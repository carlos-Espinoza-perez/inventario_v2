import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class ImageStorageService {
  final SupabaseClient _supabase;

  // Inyectamos el cliente de Supabase (usualmente Supabase.instance.client)
  ImageStorageService(this._supabase);

  /// Sube la imagen al bucket 'productos' y retorna la URL pública.
  /// Retorna [null] si falla (ej. no hay internet).
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      // 1. Generar un nombre único para el archivo
      // Usamos la fecha y hora actual para evitar duplicados.
      // Ejemplo: 2025-10-24T10:00:00.000.jpg
      final fileExt = p.extension(imageFile.path);
      final fileName = '${DateTime.now().toIso8601String()}$fileExt';

      // La ruta dentro del bucket
      final filePath = fileName;

      // 2. Intentar subir la imagen
      await _supabase.storage
          .from('Productos')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              upsert: true, // Si existe, lo sobrescribe (seguridad)
            ),
          );

      // 3. Obtener la URL pública para guardarla en la BD
      final publicUrl = _supabase.storage
          .from('Productos')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      // Aquí capturamos errores como falta de internet o permisos denegados.
      // Retornamos null para que la app sepa que no se pudo subir (y use la local).
      print("Error subiendo imagen a Supabase: $e");
      return null;
    }
  }
}
