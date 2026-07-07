import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';
import 'package:inventario_v2/features/sales/domain/use_cases/registrar_venta_use_case.dart';

import 'draft_type_adapter.dart';

/// Venta dictada → RegistrarVentaUseCase existente (valida caja abierta,
/// resuelve cliente por nombre y descuenta stock en la transacción).
class VentaDraftAdapter implements DraftTypeAdapter {
  final Ref _ref;

  VentaDraftAdapter(this._ref);

  @override
  String get type => 'venta';

  @override
  double? defaultUnitCost(Producto producto) =>
      producto.ultimoCosto > 0 ? producto.ultimoCosto : null;

  @override
  double? defaultUnitPrice(Producto producto) {
    if (producto.ultimoPrecioVenta > 0) return producto.ultimoPrecioVenta;
    final base = producto.precioBase;
    return (base != null && base > 0) ? base : null;
  }

  Map<String, dynamic> _meta(SecretaryDraft draft) => draft.metaJson != null
      ? Map<String, dynamic>.from(jsonDecode(draft.metaJson!))
      : const <String, dynamic>{};

  @override
  List<String> validate(SecretaryDraft draft, List<SecretaryDraftItem> items) {
    final errors = <String>[];
    final meta = _meta(draft);
    final saleType = _normalizeSaleType(meta['saleType'] as String?);
    final clienteNombre = (meta['clienteNombre'] as String?)?.trim() ?? '';

    if (saleType == 'Fiado' && clienteNombre.isEmpty) {
      errors.add('Para venta al fiado falta el nombre del cliente.');
    }
    if (items.any((i) => (i.unitPrice ?? 0) <= 0)) {
      errors.add('Hay ítems sin precio de venta.');
    }
    return errors;
  }

  @override
  Future<String> execute(
    SecretaryDraft draft,
    List<SecretaryDraftItem> items,
    AssistantOperationalContext context,
  ) async {
    final meta = _meta(draft);
    final saleType = _normalizeSaleType(meta['saleType'] as String?);
    final clienteNombre = (meta['clienteNombre'] as String?)?.trim() ?? '';
    final total = items.fold<double>(
      0,
      (sum, i) => sum + i.quantity * (i.unitPrice ?? 0),
    );
    final deposito = (meta['depositAmount'] as num?)?.toDouble() ??
        (saleType == 'Contado' ? total : 0.0);

    final useCase = _ref.read(registrarVentaUseCaseProvider);
    await useCase.ejecutar(
      // Mismo formato de cartItems que usa el checkout del POS.
      cartItems: [
        for (final item in items)
          {
            'id': item.productId!,
            'qty': item.quantity,
            'price': item.unitPrice ?? 0.0,
            if (item.productoVarianteId != null)
              'variantId': item.productoVarianteId,
          },
      ],
      nombreCliente: clienteNombre,
      saleType: saleType,
      total: total,
      depositAmount: deposito,
      bodegaId: draft.bodegaId,
      cajaSesionId: context.openCashSessionId,
    );
    return 'venta:$total';
  }

  String _normalizeSaleType(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');
    if (normalized == 'fiado' || normalized == 'credito') return 'Fiado';
    return 'Contado';
  }
}
