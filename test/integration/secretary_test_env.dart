import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

/// Entorno de integración del Secretario IA: AppDatabase real en memoria con
/// un negocio sembrado (empresa, bodegas, catálogo, stock, clientes, caja
/// abierta y ventas del día) para ejecutar el motor de verdad sin dispositivo.
class SecretaryTestEnv {
  late final AppDatabase db;
  late final ProviderContainer container;

  // ── IDs fijos del escenario ─────────────────────────────────────────────
  static const empresaId = 'emp-test-001';
  static const rolId = 'rol-test-001';
  static const usuarioId = 'usr-test-001';
  static const bodegaCentralId = 'bod-central-001';
  static const bodegaSurId = 'bod-sur-001';
  static const catRopaId = 'cat-ropa-001';
  static const catCalzadoId = 'cat-calzado-001';

  static const prodGorraRojaId = 'prd-gorra-roja';
  static const varGorraRojaId = 'var-gorra-roja';
  static const prodGorraAzulId = 'prd-gorra-azul';
  static const varGorraAzulId = 'var-gorra-azul';
  static const prodPantalonId = 'prd-pantalon';
  static const varPantalonId = 'var-pantalon';
  static const prodCamisaId = 'prd-camisa';
  static const varCamisaId = 'var-camisa';
  static const prodZapatoId = 'prd-zapato';
  static const varZapatoId = 'var-zapato';
  // Nombres parecidos a propósito (SEC-IA-002 punto 3: normalizeSpokenQuery)
  // para validar que "eme seis"/"eme ocho" y "talla ese"/"equis ele" no se
  // confundan entre sí.
  static const prodPantalonM6Id = 'prd-pantalon-m6';
  static const varPantalonM6Id = 'var-pantalon-m6';
  static const prodPantalonM8Id = 'prd-pantalon-m8';
  static const varPantalonM8Id = 'var-pantalon-m8';
  static const prodCamisaTallaSId = 'prd-camisa-talla-s';
  static const varCamisaTallaSId = 'var-camisa-talla-s';
  static const prodCamisaTallaXsId = 'prd-camisa-talla-xs';
  static const varCamisaTallaXsId = 'var-camisa-talla-xs';

  static const clienteJuanId = 'cli-juan';
  static const clienteMariaId = 'cli-maria';
  static const clienteFinalId = 'cli-final';
  static const cajaId = 'caja-001';
  static const cajaSesionId = 'cses-001';

  /// Total de las ventas sembradas HOY (50 + 30 contado + 100 fiado).
  static const double totalVentasHoy = 180.0;

  /// Contexto operativo equivalente al que arma AssistantContextBuilder en
  /// la app (usuario logueado, ambas bodegas visibles, caja abierta).
  AssistantOperationalContext get context => const AssistantOperationalContext(
        empresaId: empresaId,
        usuarioId: usuarioId,
        rolId: rolId,
        permisos: [],
        selectedWarehouseId: bodegaCentralId,
        allowedWarehouses: [
          AssistantWarehouse(id: bodegaCentralId, nombre: 'Bodega Central'),
          AssistantWarehouse(id: bodegaSurId, nombre: 'Sucursal Sur'),
        ],
        cajaSesionAbierta: true,
        cajaId: cajaId,
        openCashSessionId: cajaSesionId,
      );

  static void _setupSqliteForHost() {
    // En la máquina de desarrollo (tests de VM) no está sqlite3_flutter_libs;
    // Windows 10+ trae winsqlite3.dll como fallback.
    sqlite_open.open.overrideFor(sqlite_open.OperatingSystem.windows, () {
      try {
        return DynamicLibrary.open('sqlite3.dll');
      } catch (_) {
        return DynamicLibrary.open('winsqlite3.dll');
      }
    });
  }

  /// Simula flutter_secure_storage: BaseDao.getRequiredContext lee
  /// 'active_user_id' de ahí para resolver la sesión activa.
  static void _mockSecureStorage() {
    const channel =
        MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    final storage = <String, String>{'active_user_id': usuarioId};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'read':
          return storage[args['key']];
        case 'write':
          storage[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          storage.remove(args['key']);
          return null;
        case 'readAll':
          return storage;
        case 'containsKey':
          return storage.containsKey(args['key']);
        default:
          return null;
      }
    });
  }

  Future<void> setUp() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    _setupSqliteForHost();
    _mockSecureStorage();

    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [driftDatabaseProvider.overrideWithValue(db)],
    );
    await _seed();
  }

  Future<void> tearDown() async {
    container.dispose();
    await db.close();
  }

  Future<void> _seed() async {
    final now = DateTime.now();

    await db.into(db.empresas).insert(EmpresasCompanion.insert(
          id: empresaId,
          nombre: 'Comercial La Prueba',
        ));
    await db.into(db.roles).insert(RolesCompanion.insert(
          id: rolId,
          empresaId: empresaId,
          nombre: 'Administrador',
          userAdmin: const Value(true),
        ));
    await db.into(db.bodegas).insert(BodegasCompanion.insert(
          id: bodegaCentralId,
          empresaId: empresaId,
          nombre: 'Bodega Central',
          esPuntoVenta: const Value(true),
        ));
    await db.into(db.bodegas).insert(BodegasCompanion.insert(
          id: bodegaSurId,
          empresaId: empresaId,
          nombre: 'Sucursal Sur',
        ));
    await db.into(db.usuarios).insert(UsuariosCompanion.insert(
          id: usuarioId,
          empresaId: empresaId,
          rolId: rolId,
          nombreCompleto: 'Carlos Prueba',
          correo: const Value('test@laprueba.local'),
          bodegaDefaultId: const Value(bodegaCentralId),
        ));

    // ── Catálogo ──
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
          id: catRopaId,
          empresaId: empresaId,
          nombre: 'Ropa',
        ));
    await db.into(db.categorias).insert(CategoriasCompanion.insert(
          id: catCalzadoId,
          empresaId: empresaId,
          nombre: 'Calzado',
        ));

    Future<void> producto({
      required String id,
      required String varId,
      required String nombre,
      required String categoriaId,
      required double costo,
      required double precio,
      String? sku,
    }) async {
      await db.into(db.productos).insert(ProductosCompanion.insert(
            id: id,
            empresaId: empresaId,
            categoriaId: Value(categoriaId),
            nombre: nombre,
            precioBase: Value(precio),
            ultimoCosto: Value(costo),
            ultimoPrecioVenta: Value(precio),
          ));
      await db.into(db.productoVariantes).insert(
            ProductoVariantesCompanion.insert(
              id: varId,
              productoId: id,
              sku: sku ?? 'SKU-$id',
              precioEspecifico: Value(precio),
              costoEspecifico: Value(costo),
            ),
          );
    }

    await producto(
      id: prodGorraRojaId,
      varId: varGorraRojaId,
      nombre: 'Gorra Roja',
      categoriaId: catRopaId,
      costo: 3,
      precio: 8,
    );
    await producto(
      id: prodGorraAzulId,
      varId: varGorraAzulId,
      nombre: 'Gorra Azul',
      categoriaId: catRopaId,
      costo: 3.5,
      precio: 9,
    );
    await producto(
      id: prodPantalonId,
      varId: varPantalonId,
      nombre: 'Pantalon Jeans',
      categoriaId: catRopaId,
      costo: 12,
      precio: 25,
    );
    await producto(
      id: prodCamisaId,
      varId: varCamisaId,
      nombre: 'Camisa Blanca',
      categoriaId: catRopaId,
      costo: 6,
      precio: 15,
    );
    await producto(
      id: prodZapatoId,
      varId: varZapatoId,
      nombre: 'Zapato Deportivo',
      categoriaId: catCalzadoId,
      costo: 20,
      precio: 40,
    );
    await producto(
      id: prodPantalonM6Id,
      varId: varPantalonM6Id,
      nombre: 'Jean Recto M6',
      categoriaId: catRopaId,
      costo: 10,
      precio: 22,
    );
    await producto(
      id: prodPantalonM8Id,
      varId: varPantalonM8Id,
      nombre: 'Jean Recto M8',
      categoriaId: catRopaId,
      costo: 10,
      precio: 22,
    );
    await producto(
      id: prodCamisaTallaSId,
      varId: varCamisaTallaSId,
      nombre: 'Camisa Polo Talla S',
      categoriaId: catRopaId,
      costo: 7,
      precio: 16,
    );
    await producto(
      id: prodCamisaTallaXsId,
      varId: varCamisaTallaXsId,
      nombre: 'Camisa Polo Talla XS',
      categoriaId: catRopaId,
      costo: 7,
      precio: 16,
    );

    // ── Stock: central tiene gorras/pantalón; camisa en 0; zapato solo sur ──
    Future<void> stock(String varId, String bodegaId, double qty,
        {double precio = 0, double costo = 0}) {
      return db.into(db.inventarios).insert(InventariosCompanion.insert(
            id: 'inv-$varId-$bodegaId',
            productoVarianteId: varId,
            bodegaId: bodegaId,
            cantidadActual: Value(qty),
            precioVenta: Value(precio),
            costoPromedio: Value(costo),
          ));
    }

    await stock(varGorraRojaId, bodegaCentralId, 50, precio: 8, costo: 3);
    await stock(varGorraRojaId, bodegaSurId, 10, precio: 8, costo: 3);
    await stock(varGorraAzulId, bodegaCentralId, 30, precio: 9, costo: 3.5);
    await stock(varPantalonId, bodegaCentralId, 20, precio: 25, costo: 12);
    await stock(varCamisaId, bodegaCentralId, 0, precio: 15, costo: 6);
    await stock(varZapatoId, bodegaSurId, 5, precio: 40, costo: 20);

    // ── Clientes ──
    await db.into(db.clientes).insert(ClientesCompanion.insert(
          id: clienteJuanId,
          empresaId: empresaId,
          nombre: 'Juan Perez',
        ));
    await db.into(db.clientes).insert(ClientesCompanion.insert(
          id: clienteMariaId,
          empresaId: empresaId,
          nombre: 'Maria Lopez',
          saldoDeudorActual: const Value(80),
        ));
    await db.into(db.clientes).insert(ClientesCompanion.insert(
          id: clienteFinalId,
          empresaId: empresaId,
          nombre: 'Consumidor Final',
        ));

    // ── Caja abierta ──
    await db.into(db.cajas).insert(CajasCompanion.insert(
          id: cajaId,
          empresaId: empresaId,
          bodegaId: bodegaCentralId,
          nombre: 'Caja Principal',
        ));
    await db.into(db.cajaSesiones).insert(CajaSesionesCompanion.insert(
          id: cajaSesionId,
          cajaId: cajaId,
          usuarioAperturaId: usuarioId,
          fechaApertura: now.subtract(const Duration(hours: 2)),
          montoInicial: const Value(100),
          estadoSesion: 'abierta',
        ));

    // ── Ventas de HOY: 50 + 30 contado pagadas, 100 fiado (debe 80) ──
    Future<void> venta({
      required String id,
      required String clienteId,
      required String tipo,
      required double total,
      required double pagado,
      required String productoId,
      required String varianteId,
      required double cantidad,
      required double precioUnitario,
    }) async {
      await db.into(db.ventas).insert(VentasCompanion.insert(
            id: id,
            empresaId: empresaId,
            clienteId: clienteId,
            usuarioId: usuarioId,
            cajaSesionId: cajaSesionId,
            tipoVenta: tipo,
            estadoPago: pagado >= total ? 'PAGADO' : 'PENDIENTE',
            totalVenta: Value(total),
            totalPagado: Value(pagado),
            saldoPendiente: Value(total - pagado),
            fechaVenta: now,
          ));
      await db.into(db.detalleVentas).insert(DetalleVentasCompanion.insert(
            id: 'det-$id',
            ventaId: id,
            productoId: productoId,
            productoVarianteId: Value(varianteId),
            cantidad: cantidad,
            precioUnitario: precioUnitario,
            subTotal: Value(total),
          ));
      if (pagado > 0) {
        await db.into(db.pagosVentas).insert(PagosVentasCompanion.insert(
              id: 'pag-$id',
              ventaId: id,
              cajaSesionId: cajaSesionId,
              montoPagado: pagado,
              metodoPago: 'Efectivo',
              fechaRegistro: now,
            ));
      }
    }

    await venta(
      id: 'ven-hoy-1',
      clienteId: clienteFinalId,
      tipo: 'Contado',
      total: 50,
      pagado: 50,
      productoId: prodPantalonId,
      varianteId: varPantalonId,
      cantidad: 2,
      precioUnitario: 25,
    );
    await venta(
      id: 'ven-hoy-2',
      clienteId: clienteFinalId,
      tipo: 'Contado',
      total: 30,
      pagado: 30,
      productoId: prodGorraRojaId,
      varianteId: varGorraRojaId,
      cantidad: 3.75,
      precioUnitario: 8,
    );
    await venta(
      id: 'ven-hoy-fiado',
      clienteId: clienteMariaId,
      tipo: 'Fiado',
      total: 100,
      pagado: 20,
      productoId: prodZapatoId,
      varianteId: varZapatoId,
      cantidad: 2.5,
      precioUnitario: 40,
    );
  }

  /// Stock total (todas las variantes) de un producto en una bodega.
  Future<double> stockDe(String productoId, String bodegaId) async {
    final rows = await (db.select(db.inventarios).join([
      innerJoin(
        db.productoVariantes,
        db.productoVariantes.id.equalsExp(db.inventarios.productoVarianteId),
      ),
    ])
          ..where(db.productoVariantes.productoId.equals(productoId) &
              db.inventarios.bodegaId.equals(bodegaId)))
        .get();
    return rows.fold<double>(
      0,
      (sum, r) => sum + r.readTable(db.inventarios).cantidadActual,
    );
  }
}
