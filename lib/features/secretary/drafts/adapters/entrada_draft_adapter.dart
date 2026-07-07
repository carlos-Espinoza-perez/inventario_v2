import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';
import 'package:inventario_v2/features/inventory/domain/use_cases/registrar_entrada_use_case.dart';

import 'draft_type_adapter.dart';

/// Entrada de inventario dictada → RegistrarEntradaUseCase existente.
class EntradaDraftAdapter implements DraftTypeAdapter {
  final Ref _ref;

  EntradaDraftAdapter(this._ref);

  @override
  String get type => 'entrada';

  @override
  double? defaultUnitCost(Producto producto) =>
      producto.ultimoCosto > 0 ? producto.ultimoCosto : null;

  @override
  double? defaultUnitPrice(Producto producto) {
    if (producto.ultimoPrecioVenta > 0) return producto.ultimoPrecioVenta;
    final base = producto.precioBase;
    return (base != null && base > 0) ? base : null;
  }

  @override
  List<String> validate(SecretaryDraft draft, List<SecretaryDraftItem> items) {
    final errors = <String>[];
    if (draft.bodegaId == null || draft.bodegaId!.isEmpty) {
      errors.add('Falta indicar la bodega de destino.');
    }
    if (items.any((i) => (i.unitCost ?? i.unitPrice) == null)) {
      errors.add('Hay ítems sin costo ni precio.');
    }
    return errors;
  }

  @override
  Future<String> execute(
    SecretaryDraft draft,
    List<SecretaryDraftItem> items,
    AssistantOperationalContext context,
  ) async {
    final meta = draft.metaJson != null
        ? Map<String, dynamic>.from(jsonDecode(draft.metaJson!))
        : const <String, dynamic>{};
    final descripcion = (meta['descripcion'] as String?)?.trim();

    final useCase = _ref.read(registrarEntradaUseCaseProvider);
    await useCase.ejecutar(
      bodegaId: draft.bodegaId!,
      descripcion: descripcion?.isNotEmpty == true
          ? descripcion!
          : 'Entrada registrada por Secretario IA',
      // Mismo formato de orderLines que usa la pantalla de entrada manual.
      orderLines: [
        for (final item in items)
          {
            'productId': item.productId!,
            'cost': item.unitCost ?? item.unitPrice ?? 0.0,
            'price': item.unitPrice ?? item.unitCost ?? 0.0,
            'items': List.generate(
              item.quantity.toInt(),
              (_) => <String, dynamic>{},
            ),
          },
      ],
    );
    return 'entrada:${draft.bodegaId}';
  }
}
