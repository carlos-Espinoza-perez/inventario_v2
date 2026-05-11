import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_draft.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/inventory/domain/use_cases/registrar_entrada_use_case.dart';
import 'package:inventario_v2/features/sales/domain/use_cases/registrar_venta_use_case.dart';

class DraftExecutor {
  final Ref _ref;

  DraftExecutor(this._ref);

  Future<void> execute(AssistantDraft draft) async {
    switch (draft.type) {
      case DraftType.sale:
        await _executeSale(draft);
      case DraftType.inventoryEntry:
        await _executeEntry(draft);
    }
  }

  Future<void> _executeSale(AssistantDraft draft) async {
    final useCase = _ref.read(registrarVentaUseCaseProvider);
    await useCase.ejecutar(
      cartItems: draft.items.map((i) => i.toSaleCartItem()).toList(),
      nombreCliente: draft.clientName ?? '',
      saleType: draft.saleType ?? 'Contado',
      total: draft.total,
      depositAmount: draft.total,
    );
  }

  Future<void> _executeEntry(AssistantDraft draft) async {
    final useCase = _ref.read(registrarEntradaUseCaseProvider);
    final bodega = _ref.read(selectedBodegaProvider);
    final bodegaId = bodega?.serverId ?? '';

    await useCase.ejecutar(
      bodegaId: bodegaId,
      descripcion: draft.description ?? 'Entrada registrada por Secretario IA',
      orderLines: draft.items.map((i) => i.toEntryOrderLine()).toList(),
    );
  }
}

final draftExecutorProvider = Provider<DraftExecutor>((ref) {
  return DraftExecutor(ref);
});
