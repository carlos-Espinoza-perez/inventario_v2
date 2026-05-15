import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_draft.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_input_event.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_session.dart';
import 'package:inventario_v2/features/assistant/domain/services/assistant_session_manager.dart';

void main() {
  group('AssistantSessionManager', () {
    test('arma un borrador de venta desde scanner, cantidad y listo', () async {
      const manager = AssistantSessionManager();
      final session = manager.tryStartSession(
        AssistantSessionType.registerSale,
      );

      expect(session, isNotNull);
      expect(session!.state, AssistantSessionState.active);
      expect(session.draft.type, DraftType.sale);

      final scanned = await manager.processEvent(
        session,
        BarcodeInputEvent(
          barcode: '7501000111111',
          resolvedProduct: _producto(
            id: 'prod-1',
            nombre: 'Cafe molido',
            precioVenta: 120,
          ),
        ),
      );

      expect(scanned.session.state, AssistantSessionState.awaitingQuantity);
      expect(scanned.responseText, contains('Cafe molido'));

      final quantity = await manager.processEvent(
        scanned.session,
        const TextInputEvent('3'),
      );

      expect(quantity.session.state, AssistantSessionState.active);
      expect(quantity.session.draft.items, hasLength(1));
      expect(quantity.session.draft.items.single.productName, 'Cafe molido');
      expect(quantity.session.draft.items.single.quantity, 3);
      expect(quantity.session.draft.total, 360);

      final done = await manager.processEvent(
        quantity.session,
        const TextInputEvent('listo'),
      );

      expect(done.showDraft, isTrue);
      expect(done.session.state, AssistantSessionState.awaitingConfirmation);
      expect(done.responseText, contains('1'));
    });

    test(
      'rechaza cantidades invalidas sin perder el producto pendiente',
      () async {
        const manager = AssistantSessionManager();
        final session = manager.tryStartSession(
          AssistantSessionType.registerEntry,
        )!;
        final scanned = await manager.processEvent(
          session,
          BarcodeInputEvent(
            barcode: 'ABC-001',
            resolvedProduct: _producto(
              id: 'prod-2',
              nombre: 'Azucar 1kg',
              precioVenta: 45,
              costo: 30,
            ),
          ),
        );

        final invalid = await manager.processEvent(
          scanned.session,
          const TextInputEvent('dos cajas'),
        );

        expect(invalid.session.state, AssistantSessionState.awaitingQuantity);
        expect(invalid.session.pendingProduct?.nombre, 'Azucar 1kg');
        expect(invalid.responseText, contains('cantidad'));
      },
    );

    test(
      'mantiene vacio el borrador cuando el codigo no resuelve producto',
      () async {
        const manager = AssistantSessionManager();
        final session = manager.tryStartSession(
          AssistantSessionType.registerSale,
        )!;

        final result = await manager.processEvent(
          session,
          const BarcodeInputEvent(barcode: 'NO-EXISTE'),
        );

        expect(result.session.draft.items, isEmpty);
        expect(result.responseText, contains('No encontr'));
      },
    );

    test(
      'convierte una salida o ajuste en sesion acumulativa de inventario',
      () {
        const manager = AssistantSessionManager();
        final session = manager.tryStartSession(
          AssistantSessionType.registerOutputAdjustment,
        );

        expect(session, isNotNull);
        expect(session!.draft.type, DraftType.inventoryEntry);
      },
    );
  });

  group('AssistantDraft.fromMap', () {
    test('normaliza una venta con abono parcial como fiado', () {
      final draft = AssistantDraft.fromMap({
        '__draft_type': 'sale',
        'client_name': 'Maria',
        'deposit_amount': '100',
        'items': [
          {
            'product_id': 'prod-1',
            'product_name': 'Cafe molido',
            'quantity': '2',
            'unit_price': '80',
          },
        ],
      });

      expect(draft.type, DraftType.sale);
      expect(draft.clientName, 'Maria');
      expect(draft.depositAmount, 100);
      expect(draft.saleType, 'Fiado');
      expect(draft.total, 160);
    });

    test('normaliza una entrada con costo y precio', () {
      final draft = AssistantDraft.fromMap({
        '__draft_type': 'inventory_entry',
        'description': 'Compra proveedor',
        'items': [
          {
            'productoId': 'prod-2',
            'productoNombre': 'Azucar 1kg',
            'cantidad': 4,
            'costo': 30,
            'precio': 45,
          },
        ],
      });

      expect(draft.type, DraftType.inventoryEntry);
      expect(draft.description, 'Compra proveedor');
      expect(draft.items.single.unitCost, 30);
      expect(draft.items.single.unitPrice, 45);
    });
  });
}

Producto _producto({
  required String id,
  required String nombre,
  required double precioVenta,
  double costo = 0,
}) {
  final now = DateTime(2026, 1, 1);
  return Producto(
    id: id,
    createdAt: now,
    updatedAt: now,
    syncStatus: 'synced',
    empresaId: 'empresa-1',
    nombre: nombre,
    precioBase: precioVenta,
    ultimoCosto: costo,
    ultimoPrecioVenta: precioVenta,
    estado: true,
  );
}
