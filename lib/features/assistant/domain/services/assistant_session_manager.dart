import 'package:uuid/uuid.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import '../models/assistant_draft.dart';
import '../models/assistant_input_event.dart';
import '../models/assistant_session.dart';

class SessionResult {
  final AssistantSession session;
  final String responseText;
  final bool showDraft;

  const SessionResult({
    required this.session,
    required this.responseText,
    this.showDraft = false,
  });
}

class AssistantSessionManager {
  static const _uuid = Uuid();

  const AssistantSessionManager();

  AssistantSession? tryStartSession(AssistantSessionType type) {
    return AssistantSession(
      id: _uuid.v4(),
      type: type,
      state: AssistantSessionState.active,
      draft: AssistantDraft(
        type: _draftTypeFor(type),
        items: const [],
      ),
      startedAt: DateTime.now(),
    );
  }

  Future<SessionResult> processEvent(
    AssistantSession session,
    AssistantInputEvent event,
  ) async {
    final now = DateTime.now();

    final text = switch (event) {
      TextInputEvent(text: final t) => t,
      VoiceInputEvent(transcript: final t) => t,
      BarcodeInputEvent() => null,
    };

    if (text != null) {
      final normalized = _normalize(text);

      if (_isCancel(normalized)) {
        return SessionResult(
          session: session.copyWith(state: AssistantSessionState.cancelled),
          responseText: 'Sesión cancelada. No se guardó nada.',
        );
      }

      if (_isDone(normalized)) {
        if (!session.hasItems) {
          return SessionResult(
            session: session,
            responseText:
                'No hay ítems en el borrador. Agregá al menos uno antes de confirmar.',
          );
        }
        return SessionResult(
          session: session.copyWith(
            state: AssistantSessionState.awaitingConfirmation,
            lastInteractionAt: now,
          ),
          responseText:
              'Tenés ${session.draft.items.length} ítem(s). Revisá y confirmá.',
          showDraft: true,
        );
      }

      if (_isShowDraft(normalized)) {
        return SessionResult(
          session: session.copyWith(lastInteractionAt: now),
          responseText: _buildDraftSummary(session.draft),
        );
      }

      // Estado awaitingQuantity: interpretar texto como cantidad
      if (session.state == AssistantSessionState.awaitingQuantity &&
          session.pendingProduct != null) {
        final cantidad = double.tryParse(text.trim().replaceAll(',', '.'));
        if (cantidad != null && cantidad > 0) {
          return _addItem(session, session.pendingProduct!, cantidad, now);
        }
        return SessionResult(
          session: session,
          responseText: 'No entendí la cantidad. Ingresá solo el número (ej: 24).',
        );
      }

      // Estado active con texto: pedir que use scanner o nombre
      return SessionResult(
        session: session.copyWith(lastInteractionAt: now),
        responseText:
            'Usá el scanner para agregar productos, o decí "listo" para confirmar.',
      );
    }

    // Evento barcode
    if (event is BarcodeInputEvent) {
      return _handleBarcode(session, event, now);
    }

    return SessionResult(
      session: session,
      responseText: 'No entendí ese input.',
    );
  }

  SessionResult _handleBarcode(
    AssistantSession session,
    BarcodeInputEvent event,
    DateTime now,
  ) {
    if (event.resolvedProduct == null) {
      return SessionResult(
        session: session.copyWith(lastInteractionAt: now),
        responseText:
            'No encontré un producto con ese código. Podés buscarlo por nombre.',
      );
    }

    return SessionResult(
      session: session.copyWith(
        state: AssistantSessionState.awaitingQuantity,
        pendingProduct: event.resolvedProduct,
        lastInteractionAt: now,
      ),
      responseText:
          '${event.resolvedProduct!.nombre} encontrado. ¿Cuántas unidades?',
    );
  }

  SessionResult _addItem(
    AssistantSession session,
    Producto producto,
    double cantidad,
    DateTime now,
  ) {
    final newItem = DraftItem(
      productId: producto.id,
      productName: producto.nombre,
      quantity: cantidad,
      unitPrice: producto.ultimoPrecioVenta > 0
          ? producto.ultimoPrecioVenta
          : (producto.precioBase ?? 0.0),
      unitCost: producto.ultimoCosto > 0 ? producto.ultimoCosto : null,
    );

    final updatedDraft = session.draft.copyWith(
      items: [...session.draft.items, newItem],
    );

    return SessionResult(
      session: session.copyWith(
        state: AssistantSessionState.active,
        draft: updatedDraft,
        lastInteractionAt: now,
        clearPendingProduct: true,
      ),
      responseText:
          '✓ ${producto.nombre} × ${cantidad.toStringAsFixed(0)} agregado. '
          '¿Siguiente producto o "listo" para confirmar?',
    );
  }

  String _buildDraftSummary(AssistantDraft draft) {
    if (draft.items.isEmpty) return 'El borrador está vacío.';
    final lines = draft.items
        .map((i) => '• ${i.productName} × ${i.quantity.toStringAsFixed(0)}')
        .join('\n');
    return 'Lo que llevás:\n$lines\n\nDecí "listo" para confirmar o seguí agregando.';
  }

  DraftType _draftTypeFor(AssistantSessionType type) => switch (type) {
        AssistantSessionType.registerEntry => DraftType.inventoryEntry,
        AssistantSessionType.registerSale => DraftType.sale,
        AssistantSessionType.registerOutputAdjustment => DraftType.inventoryEntry,
      };

  String _normalize(String text) =>
      text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  bool _isCancel(String n) =>
      n == 'cancelar' ||
      n == 'cancel' ||
      n.contains('olvida') ||
      n.contains('descart') ||
      n == 'no';

  bool _isDone(String n) =>
      n == 'listo' ||
      n == 'eso es todo' ||
      n == 'confirmar' ||
      n == 'terminar' ||
      n == 'ya termine' ||
      n.contains('ya terminé') ||
      n.contains('eso es todo');

  bool _isShowDraft(String n) =>
      n.contains('que llevo') ||
      n.contains('qué llevo') ||
      n.contains('ver borrador') ||
      n.contains('muestra') ||
      n.contains('cuánto llevo');
}
