import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/constants/app_enums.dart';
import 'package:inventario_v2/core/providers/database_provider.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/codigo_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_codigo_producto_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/usuario_collection.dart';
import 'package:inventario_v2/features/auth/data/collections/bodega_collection.dart';

final movimientoRepositoryProvider = FutureProvider((ref) async {
  final isar = ref.watch(isarDbProvider).value;
  return MovimientoRepository(isar as Isar);
});

class MovimientoRepository {
  final Isar _isar;
  MovimientoRepository(this._isar);

  Future<void> guardarEntradaAlmacen({
    required String empresaId,
    required String usuarioId,
    required String bodegaId,
    required String descripcion,
    required List<Map<String, dynamic>> lineasOrden,
  }) async {
    await _isar.writeTxn(() async {
      // 1. CREAR CABECERA (Movimiento)
      final movimientoId = const Uuid().v4();
      final nuevoMovimiento = MovimientoProductoCollection()
        ..serverId = movimientoId
        ..empresaId = empresaId
        ..tipoMovimiento = TipoMovimiento.compra
        ..bodegaDestinoId = bodegaId
        ..fechaRegistro = DateTime.now()
        ..estadoMovimiento = EstadoMovimiento.aprobado
        ..descripcion = descripcion
        ..usuarioRegistroId = usuarioId
        ..ultimaActualizacion = DateTime.now()
        ..pendienteSincronizacion = true;

      await _isar.movimientoProductoCollections.put(nuevoMovimiento);

      // 2. PROCESAR CADA LÍNEA DE PRODUCTO (Agrupado por producto)
      for (var linea in lineasOrden) {
        final String productoId = linea['productId'];
        final double nuevoCosto = (linea['cost'] as num).toDouble();

        // items = lista de mapas: [{'qr': '...', 'size': '...'}, ...]
        final List itemsEscaneados = linea['items'] as List;
        final double cantidadEntranteTotal = itemsEscaneados.length.toDouble();

        // Agrupar items por talla/sku para el detalle histórico
        final Map<String, Map<String, dynamic>> variantesAgrupadas = {};
        for (var item in itemsEscaneados) {
          final String talla = item['size'] ?? 'Unique';
          final String qr = item['qr'] ?? 'N/A';
          // Usamos el precio del item o el costo si no hay precio de venta específico
          // Pero aquí es entrada (compra), el precio relevante es COSTO o PRECIO VENTA si se define.
          // Guardaremos lo que haya disponible.
          final precioVenta = item['price'];

          final key = "${talla}_$qr";

          if (!variantesAgrupadas.containsKey(key)) {
            variantesAgrupadas[key] = {
              'talla': talla,
              'sku': qr,
              'cantidad': 0,
              'precio': precioVenta, // Puede ser null
            };
          }
          variantesAgrupadas[key]!['cantidad'] += 1;
        }

        final variantesJsonStr = jsonEncode(variantesAgrupadas.values.toList());

        // A. Crear Detalle Movimiento (Registro histórico)
        final detalleId = const Uuid().v4();
        final detalle = DetalleMovimientoProductoCollection()
          ..serverId = detalleId
          ..movimientoProductoId = movimientoId
          ..productoId = productoId
          ..cantidad = cantidadEntranteTotal
          ..costoUnitarioFinal = nuevoCosto
          ..costoProveedor = nuevoCosto
          ..variantesJson =
              variantesJsonStr // Nuevo campo
          ..ultimaActualizacion = DateTime.now()
          ..fechaEliminacion = null; // null por defecto

        await _isar.detalleMovimientoProductoCollections.put(detalle);

        // B. Actualizar PRODUCTO (Último Costo)
        final producto = await _isar.productoCollections
            .filter()
            .serverIdEqualTo(productoId)
            .findFirst();

        if (producto != null) {
          producto.ultimoCosto = nuevoCosto;
          // Actualizar precio venta si vino en el formulario
          if (linea['price'] != null) {
            producto.precioBase = (linea['price'] as num).toDouble();
          }
          producto.ultimaActualizacion = DateTime.now();
          producto.pendienteSincronizacion = true;
          await _isar.productoCollections.put(producto);
        }

        // C. Actualizar INVENTARIO MACRO (Tabla InventarioProducto)
        InventarioCollection? inventarioMacro = await _isar
            .inventarioCollections
            .filter()
            .bodegaIdEqualTo(bodegaId)
            .productoIdEqualTo(productoId)
            .findFirst();

        inventarioMacro ??= InventarioCollection()
          ..serverId = const Uuid().v4()
          ..bodegaId = bodegaId
          ..productoId = productoId
          ..cantidadActual = 0
          ..costoPromedio = 0
          ..cantidadReservada = 0
          ..ultimaActualizacion = DateTime.now()
          ..pendienteSincronizacion = true;

        // Cálculo de Promedio Ponderado
        final costoTotalActual =
            inventarioMacro.cantidadActual * inventarioMacro.costoPromedio;
        final costoTotalEntrante = cantidadEntranteTotal * nuevoCosto;
        final nuevaCantidadTotal =
            inventarioMacro.cantidadActual + cantidadEntranteTotal;

        double nuevoCostoPromedio = 0;
        if (nuevaCantidadTotal > 0) {
          nuevoCostoPromedio =
              (costoTotalActual + costoTotalEntrante) / nuevaCantidadTotal;
        }

        inventarioMacro.cantidadActual = nuevaCantidadTotal;
        inventarioMacro.costoPromedio = nuevoCostoPromedio;
        inventarioMacro.actualizadoPor = usuarioId; // Campo visto en tu imagen
        inventarioMacro.ultimaActualizacion = DateTime.now();
        inventarioMacro.pendienteSincronizacion = true;

        await _isar.inventarioCollections.put(inventarioMacro);

        // D. PROCESAR CADA TALLA/CÓDIGO (Inventario Micro)
        for (var item in itemsEscaneados) {
          final String qr = item['qr'];
          final String talla = item['size'];

          // 1. Gestionar Identidad (Tabla CodigoProducto)
          CodigoProductoCollection? codigoIdentidad = await _isar
              .codigoProductoCollections
              .filter()
              .codigoSkuEqualTo(qr)
              .findFirst();

          // Lógica de PRECIO DIFERENCIADO
          double? precioTalla;
          if (item['price'] != null) {
            final double precioItem = (item['price'] is num)
                ? (item['price'] as num).toDouble()
                : double.tryParse(item['price'].toString()) ?? 0.0;

            // Usamos el precioBase actualizado del producto en memoria
            final double precioBaseRef = producto?.precioBase ?? 0.0;

            // Si el precio de la talla es diferente al del producto padre, lo guardamos.
            // Si es igual, dejamos null para que herede.
            if (precioItem != precioBaseRef) {
              precioTalla = precioItem;
            }
          }

          if (codigoIdentidad == null) {
            codigoIdentidad = CodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..productoId = productoId
              ..talla = talla
              ..codigoSku = qr
              ..precioEspecifico = precioTalla
              ..usuarioRegistroId = usuarioId
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;

            await _isar.codigoProductoCollections.put(codigoIdentidad);
          } else {
            // Si ya existe, actualizamos el precio específico si cambió
            if (precioTalla != codigoIdentidad.precioEspecifico) {
              codigoIdentidad.precioEspecifico = precioTalla;
              codigoIdentidad.ultimaActualizacion = DateTime.now();
              codigoIdentidad.pendienteSincronizacion = true;
              await _isar.codigoProductoCollections.put(codigoIdentidad);
            }
          }

          // 2. Actualizar Stock por Talla (Tabla InventarioCodigoProducto)
          final invMicro = await _isar.inventarioCodigoProductoCollections
              .filter()
              .inventarioIdEqualTo(
                inventarioMacro.serverId,
              ) // Relación con Padre
              .codigoProductoIdEqualTo(
                codigoIdentidad.serverId,
              ) // Relación con SKU
              .findFirst();

          if (invMicro != null) {
            invMicro.cantidad += 1;
            invMicro.ultimaActualizacion = DateTime.now();
            invMicro.usuarioRegistroId = usuarioId;
            invMicro.pendienteSincronizacion = true;
            await _isar.inventarioCodigoProductoCollections.put(invMicro);
          } else {
            final nuevoInvMicro = InventarioCodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..inventarioId = inventarioMacro.serverId
              ..codigoProductoId = codigoIdentidad.serverId
              ..cantidad = 1
              ..usuarioRegistroId = usuarioId
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;

            await _isar.inventarioCodigoProductoCollections.put(nuevoInvMicro);
          }
        }
      }
    });
  }

  // --- NUEVO MÉTODO: TRASLADO ENTRE BODEGAS ---
  Future<void> registrarTrasladoBodegas({
    required String empresaId,
    required String usuarioId,
    required String bodegaOrigenId,
    required String bodegaDestinoId,
    required String descripcion,
    required List<Map<String, dynamic>> items,
  }) async {
    debugPrint(
      "Repo: Iniciando traslado. Items: ${items.length}, Usuario: $usuarioId",
    );
    try {
      // VALIDACIÓN PREVIA: Verificar stock suficiente antes de iniciar transacción
      for (var item in items) {
        final String productId = item['productId'];
        final String sku = item['qr'];
        final double cantidad = (item['cantidad'] ?? 1).toDouble();

        // Validar inventario macro
        final invOrigen = await _isar.inventarioCollections
            .filter()
            .bodegaIdEqualTo(bodegaOrigenId)
            .productoIdEqualTo(productId)
            .findFirst();

        if (invOrigen == null) {
          throw Exception(
            'Producto no encontrado en bodega origen. SKU: $sku',
          );
        }

        if (invOrigen.cantidadActual < cantidad) {
          final producto = await _isar.productoCollections
              .filter()
              .serverIdEqualTo(productId)
              .findFirst();
          throw Exception(
            'Stock insuficiente para ${producto?.nombre ?? "producto"}. '
            'Disponible: ${invOrigen.cantidadActual}, Solicitado: $cantidad',
          );
        }

        // Validar inventario micro (por talla/SKU)
        final variante = await _isar.codigoProductoCollections
            .filter()
            .productoIdEqualTo(productId)
            .and()
            .codigoSkuEqualTo(sku)
            .findFirst();

        if (variante != null) {
          final invMicroOrigen = await _isar
              .inventarioCodigoProductoCollections
              .filter()
              .inventarioIdEqualTo(invOrigen.serverId)
              .codigoProductoIdEqualTo(variante.serverId)
              .findFirst();

          if (invMicroOrigen != null && invMicroOrigen.cantidad < cantidad) {
            throw Exception(
              'Stock insuficiente para talla/SKU: $sku. '
              'Disponible: ${invMicroOrigen.cantidad}, Solicitado: $cantidad',
            );
          }
        }
      }

      await _isar.writeTxn(() async {
        // 1. CREAR CABECERA (Movimiento)
        final movimientoId = const Uuid().v4();
        final nuevoMovimiento = MovimientoProductoCollection()
          ..serverId = movimientoId
          ..empresaId = empresaId
          ..tipoMovimiento = TipoMovimiento.traslado
          ..bodegaOrigenId = bodegaOrigenId
          ..bodegaDestinoId = bodegaDestinoId
          ..fechaRegistro = DateTime.now()
          ..estadoMovimiento = EstadoMovimiento.aprobado
          ..descripcion = descripcion
          ..usuarioRegistroId = usuarioId
          ..ultimaActualizacion = DateTime.now()
          ..pendienteSincronizacion = true;

        await _isar.movimientoProductoCollections.put(nuevoMovimiento);
        debugPrint("Repo: Cabecera movimiento creada: $movimientoId");

        // 2. PROCESAR ITEMS
        for (var item in items) {
          final String productId = item['productId'];
          final String sku = item['qr']; // Código SKU
          final String talla = item['size'];
          final double cantidad = (item['cantidad'] ?? 1).toDouble();

          debugPrint(
            "Repo: Procesando item SKU: $sku, Talla: $talla, Cant: $cantidad",
          );

          // Conversión segura de precio
          final double? nuevoPrecio = (item['price'] != null)
              ? (item['price'] is num
                    ? (item['price'] as num).toDouble()
                    : double.tryParse(item['price'].toString()))
              : null;

          // A. BUSCAR PRODUCTO (Para act precio y datos base)
          final producto = await _isar.productoCollections
              .filter()
              .serverIdEqualTo(productId)
              .findFirst();

          if (producto != null) {
            // EL TRASLADO NO DEBE MODIFICAR EL PRECIO GLOBAL EN EL ORIGEN.
          }

          // B. GESTIONAR INVENTARIO ORIGEN (SALIDA)
          final invOrigen = await _isar.inventarioCollections
              .filter()
              .bodegaIdEqualTo(bodegaOrigenId)
              .productoIdEqualTo(productId)
              .findFirst();

          // Costo: priorizar el costo editado por el usuario en el formulario.
          // Si no vino o es 0, fallback al costo promedio de la bodega origen.
          final double costoEditado = item['cost'] != null
              ? (item['cost'] as num).toDouble()
              : 0.0;
          final double costoUnitario = costoEditado > 0
              ? costoEditado
              : (invOrigen?.costoPromedio ?? 0.0);

          if (invOrigen != null) {
            invOrigen.cantidadActual -= cantidad;
            invOrigen.ultimaActualizacion = DateTime.now();
            invOrigen.pendienteSincronizacion = true;
            await _isar.inventarioCollections.put(invOrigen);

            // 2. Micro Origen (Por Talla/SKU)
            final variante = await _isar.codigoProductoCollections
                .filter()
                .productoIdEqualTo(productId)
                .and()
                .codigoSkuEqualTo(sku)
                .findFirst();

            if (variante != null) {
              final invMicroOrigen = await _isar
                  .inventarioCodigoProductoCollections
                  .filter()
                  .inventarioIdEqualTo(invOrigen.serverId)
                  .codigoProductoIdEqualTo(variante.serverId)
                  .findFirst();

              if (invMicroOrigen != null) {
                double nuevaCant = invMicroOrigen.cantidad - cantidad;
                if (nuevaCant < 0) nuevaCant = 0;

                invMicroOrigen.cantidad = nuevaCant;
                invMicroOrigen.ultimaActualizacion = DateTime.now();
                invMicroOrigen.pendienteSincronizacion = true;
                await _isar.inventarioCodigoProductoCollections.put(
                  invMicroOrigen,
                );
              }
            }
          }

          // C. GESTIONAR INVENTARIO DESTINO (ENTRADA)
          // 1. Macro Destino
          InventarioCollection? invDestino = await _isar.inventarioCollections
              .filter()
              .bodegaIdEqualTo(bodegaDestinoId)
              .productoIdEqualTo(productId)
              .findFirst();

          invDestino ??= InventarioCollection()
            ..serverId = const Uuid().v4()
            ..bodegaId = bodegaDestinoId
            ..productoId = productId
            ..cantidadActual = 0
            ..costoPromedio =
                costoUnitario // Hereda costo de origen
            ..ultimaActualizacion = DateTime.now()
            ..pendienteSincronizacion = true;

          // Recalcular costo promedio destino
          final double costoTotalDest =
              invDestino.cantidadActual * invDestino.costoPromedio;
          final double costoTotalEntrante = cantidad * costoUnitario;
          final double nuevaCantDest = invDestino.cantidadActual + cantidad;

          if (nuevaCantDest > 0) {
            invDestino.costoPromedio =
                (costoTotalDest + costoTotalEntrante) / nuevaCantDest;
          } else {
            invDestino.costoPromedio = costoUnitario;
          }

          invDestino.cantidadActual = nuevaCantDest;
          invDestino.actualizadoPor = usuarioId;
          invDestino.ultimaActualizacion = DateTime.now();
          invDestino.pendienteSincronizacion = true;
          await _isar.inventarioCollections.put(invDestino);

          debugPrint("Repo: Inventario macro destino actualizado");

          // 2. Micro Destino (Por Talla/SKU)
          // Buscamos o creamos la variante (CodigoProducto)
          CodigoProductoCollection? variante = await _isar
              .codigoProductoCollections
              .filter()
              .productoIdEqualTo(productId)
              .and()
              .codigoSkuEqualTo(sku)
              .findFirst();

          if (variante == null) {
            debugPrint("Repo: Creando nueva variante destino");
            variante = CodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..productoId = productId
              ..codigoSku = sku
              ..talla = talla
              ..precioEspecifico =
                  nuevoPrecio // Asignamos precio si viene
              ..usuarioRegistroId =
                  usuarioId // FIX: Inicializar campo obligatorio
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;
            await _isar.codigoProductoCollections.put(variante);
          } else {
            debugPrint("Repo: Actualizando variante destino existente");
            // Variante global: Tampoco actualizamos precio específico global por traslado.
          }

          final invMicroDestino = await _isar
              .inventarioCodigoProductoCollections
              .filter()
              .inventarioIdEqualTo(invDestino.serverId)
              .codigoProductoIdEqualTo(variante.serverId)
              .findFirst();

          if (invMicroDestino != null) {
            debugPrint("Repo: Actualizando micro inventario destino");
            invMicroDestino.cantidad += cantidad;
            invMicroDestino.ultimaActualizacion = DateTime.now();
            invMicroDestino.usuarioRegistroId =
                usuarioId; // Actualizamos auditoría
            invMicroDestino.pendienteSincronizacion = true;
            await _isar.inventarioCodigoProductoCollections.put(
              invMicroDestino,
            );
          } else {
            debugPrint("Repo: Creando micro inventario destino");
            final nuevoMicro = InventarioCodigoProductoCollection()
              ..serverId = const Uuid().v4()
              ..inventarioId = invDestino.serverId
              ..codigoProductoId = variante.serverId
              ..cantidad = cantidad
              ..usuarioRegistroId =
                  usuarioId // FIX: Inicializar campo obligatorio
              ..fechaRegistro = DateTime.now()
              ..ultimaActualizacion = DateTime.now()
              ..pendienteSincronizacion = true;
            await _isar.inventarioCodigoProductoCollections.put(nuevoMicro);
          }

          // Construir JSON de variante para historial
          final varianteMap = {
            'talla': talla,
            'sku': sku,
            'cantidad': cantidad,
            'precio': nuevoPrecio, // Puede ser null
          };
          final variantesJsonStr = jsonEncode([varianteMap]);

          // D. REGISTRAR DETALLE HISTÓRICO
          final detalle = DetalleMovimientoProductoCollection()
            ..serverId = const Uuid().v4()
            ..movimientoProductoId = movimientoId
            ..productoId = productId
            ..cantidad = cantidad
            ..costoUnitarioFinal = costoUnitario
            ..costoProveedor = costoUnitario
            ..variantesJson =
                variantesJsonStr // Guardar info de talla
            ..ultimaActualizacion = DateTime.now()
            ..pendienteSincronizacion = true;

          await _isar.detalleMovimientoProductoCollections.put(detalle);
          debugPrint("Repo: Item completado");
        }
      });
      debugPrint("Repo: Transacción finalizada con éxito");
    } catch (e, st) {
      debugPrint("Repo Error al guardar traslado: $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // MÉTODO PARA OBTENER HISTORIAL (KARDEX) DE UN PRODUCTO
  Future<List<Map<String, dynamic>>> obtenerHistorialProducto(
    String productoId, {
    String? bodegaId,
  }) async {
    // 1. Obtener detalles de movimientos asociados al producto
    final detalles = await _isar.detalleMovimientoProductoCollections
        .filter()
        .productoIdEqualTo(productoId)
        .findAll();

    // Mapa para agrupar detalles por movimiento (misma transacción)
    final Map<String, Map<String, dynamic>> movimientosAgrupados = {};

    // Cache de cabeceras para no consultar repetidamente
    final Map<String, MovimientoProductoCollection> cabecerasCache = {};

    for (var detalle in detalles) {
      final movId = detalle.movimientoProductoId;

      // 2. Obtener la cabecera del movimiento (si no está en cache)
      if (!cabecerasCache.containsKey(movId)) {
        final cabecera = await _isar.movimientoProductoCollections
            .filter()
            .serverIdEqualTo(movId)
            .findFirst();

        if (cabecera != null) {
          cabecerasCache[movId] = cabecera;
        } else {
          continue; // Si no hay cabecera, ignoramos el detalle huérfano
        }
      }

      final movimiento = cabecerasCache[movId]!;
      if (bodegaId != null &&
          movimiento.bodegaOrigenId != bodegaId &&
          movimiento.bodegaDestinoId != bodegaId) {
        continue;
      }

      // 3. Inicializar entrada en el mapa agrupado si es nueva
      if (!movimientosAgrupados.containsKey(movId)) {
        movimientosAgrupados[movId] = {
          'id': movimiento.serverId,
          'fecha': movimiento.fechaRegistro,
          'tipo': movimiento.tipoMovimiento.name,
          'bodegaOrigen': movimiento.bodegaOrigenId ?? 'N/A',
          'bodegaDestino': movimiento.bodegaDestinoId ?? 'N/A',
          'descripcion': movimiento.descripcion,
          'usuario': movimiento.usuarioRegistroId,
          'cantidad': 0.0, // Acumulador
          'costo': detalle.costoUnitarioFinal, // Referencia (promedio o último)
          'variantes': <Map<String, dynamic>>[], // Lista de tallas
        };
      }

      // 4. Sumar cantidad total
      movimientosAgrupados[movId]!['cantidad'] += detalle.cantidad;

      // 5. Parsear y agregar variantes (si existen)
      if (detalle.variantesJson != null && detalle.variantesJson!.isNotEmpty) {
        try {
          final List<dynamic> vars = jsonDecode(detalle.variantesJson!);
          for (var v in vars) {
            // Asegurar tipos correctos
            (movimientosAgrupados[movId]!['variantes'] as List).add(
              Map<String, dynamic>.from(v),
            );
          }
        } catch (e) {
          debugPrint("Error parseando variantes JSON: $e");
        }
      } else {
        // Fallback para registros antiguos sin detalle JSON
        // Agregamos una variante genérica con la cantidad de este detalle
        (movimientosAgrupados[movId]!['variantes'] as List).add({
          'talla': 'General',
          'sku': 'N/A',
          'cant': detalle
              .cantidad, // Usamos 'cant' para no confundir con 'cantidad' del item si lo hubiera
          'cantidad': detalle.cantidad, // Duplicamos para asegurar
          'precio': detalle.costoUnitarioFinal,
        });
      }
    }

    // Convertir a lista y ordenar por fecha descendente
    final historial = movimientosAgrupados.values.toList();
    historial.sort(
      (a, b) => (b['fecha'] as DateTime).compareTo(a['fecha'] as DateTime),
    );
    return historial;
  }

  // MÉTODO PARA OBTENER HISTORIAL DE UNA BODEGA
  Future<List<Map<String, dynamic>>> obtenerHistorialBodega(
    String bodegaId,
  ) async {
    final movimientos = await _isar.movimientoProductoCollections
        .filter()
        .bodegaOrigenIdEqualTo(bodegaId)
        .or()
        .bodegaDestinoIdEqualTo(bodegaId)
        .sortByFechaRegistroDesc()
        .findAll();

    final List<Map<String, dynamic>> historial = [];

    for (var mov in movimientos) {
      final detalles = await _isar.detalleMovimientoProductoCollections
          .filter()
          .movimientoProductoIdEqualTo(mov.serverId)
          .findAll();

      double itemsCount = 0;
      double totalCosto = 0;
      for (var d in detalles) {
        itemsCount += d.cantidad;
        totalCosto += (d.cantidad * d.costoUnitarioFinal);
      }

      String direccion = "NEUTRAL";
      if (mov.bodegaDestinoId == bodegaId && mov.bodegaOrigenId == bodegaId) {
        direccion = "INTERNO";
      } else if (mov.bodegaDestinoId == bodegaId) {
        direccion = mov.tipoMovimiento == TipoMovimiento.compra
            ? "ENTRADA"
            : "ENTRADA_TRASLADO";
      } else if (mov.bodegaOrigenId == bodegaId) {
        direccion = mov.tipoMovimiento == TipoMovimiento.traslado
            ? "SALIDA_TRASLADO"
            : "SALIDA";
      }

      historial.add({
        "id": mov.serverId,
        "tipo": mov.tipoMovimiento.name.toUpperCase(),
        "fecha": mov.fechaRegistro,
        "referencia": mov.descripcion ?? "Sin referencia",
        "items": itemsCount.toInt(),
        "total": totalCosto,
        "usuario": mov.usuarioRegistroId != null
            ? (await _isar.usuarioCollections
                          .filter()
                          .serverIdEqualTo(mov.usuarioRegistroId!)
                          .findFirst())
                      ?.nombreCompleto ??
                  "Sistema"
            : "Sistema",
        "direccion": direccion,
        "estado": mov.estadoMovimiento.name.toUpperCase(),
      });
    }

    return historial;
  }

  // MÉTODO PARA OBTENER EL DETALLE COMPLETO DE UN MOVIMIENTO (PARA LA VISTA Y EL PDF)
  Future<Map<String, dynamic>?> obtenerDetalleMovimiento(
    String movimientoId,
  ) async {
    final mov = await _isar.movimientoProductoCollections
        .filter()
        .serverIdEqualTo(movimientoId)
        .findFirst();

    if (mov == null) return null;

    final detalles = await _isar.detalleMovimientoProductoCollections
        .filter()
        .movimientoProductoIdEqualTo(mov.serverId)
        .findAll();

    Map<String, Map<String, dynamic>> groupedItems = {};
    double totalCosto = 0;

    for (var d in detalles) {
      final productoId = d.productoId;
      final producto = await _isar.productoCollections
          .filter()
          .serverIdEqualTo(productoId)
          .findFirst();

      List<dynamic> variantesInfo = [];
      if (d.variantesJson != null && d.variantesJson!.isNotEmpty) {
        try {
          // El JSON puede ser directamente [{talla: L...}]
          final decoded = jsonDecode(d.variantesJson!);
          if (decoded is List) {
            variantesInfo = List<dynamic>.from(decoded);
          } else {
            variantesInfo = [decoded];
          }
        } catch (_) {}
      }

      if (groupedItems.containsKey(productoId)) {
        groupedItems[productoId]!['cantidad'] += d.cantidad;
        groupedItems[productoId]!['subtotal'] +=
            (d.cantidad * d.costoUnitarioFinal);
        (groupedItems[productoId]!['variantes'] as List).addAll(variantesInfo);
      } else {
        groupedItems[productoId] = {
          "nombre": producto?.nombre ?? "Producto Desconocido",
          "sku": "N/A", // Se creará al final
          "cantidad": d.cantidad,
          "precio_compra": d.costoProveedor,
          "precio_venta": producto?.precioBase ?? d.costoUnitarioFinal,
          "subtotal": d.cantidad * d.costoUnitarioFinal,
          "variantes": List<dynamic>.from(variantesInfo),
        };
      }

      totalCosto += (d.cantidad * d.costoUnitarioFinal);
    }

    // Convertir a List y generar los skuDisplay agrupados
    List<Map<String, dynamic>> items = groupedItems.values.map((item) {
      final List variantes = item['variantes'] as List;
      String skuDisplay = "N/A";

      if (variantes.isNotEmpty) {
        final skusValidos = variantes
            .map((v) => v['sku']?.toString())
            .where((sku) => sku != null && sku.isNotEmpty);

        if (skusValidos.isNotEmpty) {
          skuDisplay = skusValidos.toSet().join(", ");
          if (skuDisplay.length > 30) {
            skuDisplay = skuDisplay.substring(0, 30) + "...";
          }
        }
      }

      item['sku'] = skuDisplay;
      return item;
    }).toList();

    final usuario = mov.usuarioRegistroId != null
        ? await _isar.usuarioCollections
              .filter()
              .serverIdEqualTo(mov.usuarioRegistroId!)
              .findFirst()
        : null;

    final bodegaOrigen = mov.bodegaOrigenId != null
        ? await _isar.bodegaCollections
              .filter()
              .serverIdEqualTo(mov.bodegaOrigenId!)
              .findFirst()
        : null;

    final bodegaDestino = mov.bodegaDestinoId != null
        ? await _isar.bodegaCollections
              .filter()
              .serverIdEqualTo(mov.bodegaDestinoId!)
              .findFirst()
        : null;

    return {
      "id": mov.serverId,
      "tipo": mov.tipoMovimiento.name.toUpperCase(),
      "fecha": mov.fechaRegistro,
      "referencia_externa": mov.descripcion ?? "Sin referencia",
      "estado": mov.estadoMovimiento.name.toUpperCase(),
      "usuario": usuario?.nombreCompleto ?? "Sistema",
      "origen": bodegaOrigen?.nombre ?? "N/A",
      "destino": bodegaDestino?.nombre ?? "N/A",
      "cliente": "N/A",
      "proveedor": "N/A",
      "metodo_pago": "N/A",
      "costo_flete": 0.0,
      "costo_productos": totalCosto,
      "items": items,
    };
  }
}
