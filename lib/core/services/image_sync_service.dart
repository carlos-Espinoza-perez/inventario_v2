import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:inventario_v2/core/services/app_logger.dart';

class ImageSyncService {
  Future<void> preCacheImages(Iterable<dynamic> productos) async {
    AppLogger.info('Iniciando sincronizacion de imagenes en segundo plano...');

    var descargadas = 0;
    var existentes = 0;

    for (final producto in productos) {
      final imagenUrl = _readString(producto, 'imagenUrl');
      final nombre = _readString(producto, 'nombre') ?? 'producto';

      if (imagenUrl == null || imagenUrl.isEmpty) continue;

      try {
        final fileInfo = await DefaultCacheManager().getFileFromCache(
          imagenUrl,
        );

        if (fileInfo == null) {
          await DefaultCacheManager().downloadFile(imagenUrl);
          descargadas++;
        } else {
          existentes++;
        }
      } catch (e, st) {
        AppLogger.error('Error pre-cargando imagen para $nombre', e, st);
      }
    }

    AppLogger.info('Sincronizacion de imagenes terminada.');
    AppLogger.info('Descargadas: $descargadas');
    AppLogger.info('Ya en cache: $existentes');
  }

  String? _readString(dynamic producto, String key) {
    try {
      final json = (producto as dynamic).toJson();
      return json[key]?.toString();
    } catch (_) {
      try {
        final value = switch (key) {
          'imagenUrl' => (producto as dynamic).imagenUrl,
          'nombre' => (producto as dynamic).nombre,
          _ => null,
        };
        return value?.toString();
      } catch (_) {
        return null;
      }
    }
  }
}
