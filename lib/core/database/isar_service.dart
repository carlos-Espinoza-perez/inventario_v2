import 'package:inventario_v2/features/auth/data/collections/bodega_usuario_colletion.dart';
import 'package:inventario_v2/features/inventory/data/collections/cargo_adicional_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/categoria_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/detalle_movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/inventario_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/movimiento_producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/producto_collection.dart';
import 'package:inventario_v2/features/inventory/data/collections/regla_costo_collection.dart';
import 'package:inventario_v2/features/pos/data/collections/caja_collection.dart';
import 'package:inventario_v2/features/pos/data/collections/caja_movimiento_extra_collection.dart'
    show CajaMovimientoExtraCollectionSchema;
import 'package:inventario_v2/features/pos/data/collections/caja_sesion_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/cliente_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/detalle_venta_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/historial_pago_collection.dart';
import 'package:inventario_v2/features/sales/data/collections/venta_collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/collections/empresa_collection.dart';
import '../../features/auth/data/collections/usuario_collection.dart';
import '../../features/auth/data/collections/rol_collection.dart';
import '../../features/auth/data/collections/bodega_collection.dart';
import '../../features/auth/data/collections/acceso_rol_collection.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    // 1. Si ya está abierta, devuélvela (Singleton pattern)
    if (Isar.instanceNames.isNotEmpty) {
      return Future.value(Isar.getInstance());
    }

    // 2. Busca la carpeta de documentos del celular
    final dir = await getApplicationDocumentsDirectory();

    // 3. Abre la base de datos con tus esquemas (Schemas)
    return await Isar.open(
      [
        EmpresaCollectionSchema,
        UsuarioCollectionSchema,
        RolCollectionSchema,
        AccesoRolCollectionSchema,
        BodegaCollectionSchema,
        BodegaUsuarioColletionSchema,
        CategoriaCollectionSchema,
        ProductoCollectionSchema,
        InventarioCollectionSchema,
        MovimientoProductoCollectionSchema,
        DetalleMovimientoProductoCollectionSchema,
        ClienteCollectionSchema,
        VentaCollectionSchema,
        DetalleVentaCollectionSchema,
        HistorialPagoCollectionSchema,
        CajaCollectionSchema,
        CajaSesionCollectionSchema,
        CajaMovimientoExtraCollectionSchema,
        ReglaCostoCollectionSchema,
        CargoAdicionalCollectionSchema,
      ],
      directory: dir.path,
      inspector: true,
    );
  }

  // Método helper para limpiar la DB (útil al cerrar sesión)
  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
