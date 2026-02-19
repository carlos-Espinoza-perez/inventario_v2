import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';

class ImageSyncService {
  /// Descarga y guarda en caché todas las imágenes de la lista de productos.
  /// Ideal para llamar después de traer los datos de Supabase.
  Future<void> preCacheImages(List<ProductoCollection> productos) async {
    print("🔄 Iniciando sincronización de imágenes en segundo plano...");

    int descargadas = 0;
    int existentes = 0;

    for (var producto in productos) {
      // Solo nos importan los que tienen URL de nube y NO tienen imagen local manual
      if (producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty) {
        try {
          // 1. Verificar si ya está en caché
          final fileInfo = await DefaultCacheManager().getFileFromCache(
            producto.imagenUrl!,
          );

          if (fileInfo == null) {
            // 2. Si no existe, forzamos la descarga
            await DefaultCacheManager().downloadFile(producto.imagenUrl!);
            descargadas++;
          } else {
            existentes++;
          }
        } catch (e) {
          print("❌ Error pre-cargando imagen para ${producto.nombre}: $e");
          // Continuamos con el siguiente, no detenemos el proceso
        }
      }
    }

    print("✅ Sincronización de imágenes terminada.");
    print("   ⬇️ Descargadas: $descargadas");
    print("   📂 Ya en caché: $existentes");
  }
}
