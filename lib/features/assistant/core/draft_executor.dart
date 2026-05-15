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
    final saleType = _normalizeSaleType(draft.saleType);
    await useCase.ejecutar(
      cartItems: draft.items.map((i) => i.toSaleCartItem()).toList(),
      nombreCliente: draft.clientName ?? '',
      saleType: saleType,
      total: draft.total,
      depositAmount:
          draft.depositAmount ?? (saleType == 'Contado' ? draft.total : 0),
      bodegaId: draft.bodegaId,
      cajaSesionId: draft.cajaSesionId,
    );
  }

  String _normalizeSaleType(String? value) {
    final normalized = _normalizeDomainValue(value);
    if (normalized == 'fiado') return 'Fiado';
    if (normalized == 'credito') return 'Fiado';
    if (normalized == 'contado') return 'Contado';
    return 'Contado';
  }

  String _normalizeDomainValue(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e');
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
