import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';
import 'package:inventario_v2/core/services/app_logger.dart';
import 'package:inventario_v2/features/secretary/data/context/assistant_context_builder.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';

import '../drafts/draft_engine.dart';
import '../presentation/providers/draft_provider.dart';
import '../presentation/providers/secretary_chat_provider.dart';
import 'dictation_fallback.dart';
import 'dictation_parser.dart';
import 'secretary_transcriber.dart';
import 'secretary_tts.dart';

enum DictationPhase { listening, processing, paused }

class DictationState {
  final bool active;
  final DictationPhase phase;
  final String draftType; // 'entrada' | 'venta'
  final String? draftId;
  final String partialText;
  final double soundLevel;

  /// Último feedback corto ("12 pantalones ✓").
  final String lastAck;

  /// Segmentos en el fallback LLM aún sin materializar.
  final int pendingFallbacks;
  final String? error;

  const DictationState({
    this.active = false,
    this.phase = DictationPhase.paused,
    this.draftType = 'entrada',
    this.draftId,
    this.partialText = '',
    this.soundLevel = 0,
    this.lastAck = '',
    this.pendingFallbacks = 0,
    this.error,
  });

  DictationState copyWith({
    bool? active,
    DictationPhase? phase,
    String? draftType,
    String? draftId,
    String? partialText,
    double? soundLevel,
    String? lastAck,
    int? pendingFallbacks,
    String? error,
    bool clearError = false,
  }) {
    return DictationState(
      active: active ?? this.active,
      phase: phase ?? this.phase,
      draftType: draftType ?? this.draftType,
      draftId: draftId ?? this.draftId,
      partialText: partialText ?? this.partialText,
      soundLevel: soundLevel ?? this.soundLevel,
      lastAck: lastAck ?? this.lastAck,
      pendingFallbacks: pendingFallbacks ?? this.pendingFallbacks,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Modo dictado continuo: escucha por segmentos cortos (pausa ~1.2 s), cada
/// segmento pasa por la vía rápida local (DictationParser + resolver) con ack
/// hablado inmediato; lo no entendido cae al fallback LLM en segundo plano.
/// El dictado nunca se frena por una ambigüedad (queda "por revisar").
class DictationController extends StateNotifier<DictationState> {
  final Ref _ref;
  final SecretaryTranscriber _transcriber = SecretaryTranscriber();
  final SecretaryTts _tts = SecretaryTts();
  final DictationFallback _fallback = DictationFallback();

  AssistantOperationalContext? _context;
  int _generation = 0;

  DictationController(this._ref) : super(const DictationState()) {
    _transcriber.onPartialResult = (partial) {
      if (state.active && state.phase == DictationPhase.listening) {
        state = state.copyWith(partialText: partial);
      }
    };
    _transcriber.onSoundLevel = (level) {
      if (state.active && state.phase == DictationPhase.listening) {
        state = state.copyWith(soundLevel: level);
      }
    };
  }

  bool get _esVenta => state.draftType == 'venta';

  /// Abre el modo dictado: garantiza sesión de chat + borrador y escucha.
  Future<void> start(String draftType) async {
    _generation++;
    final gen = _generation;
    state = DictationState(
      active: true,
      phase: DictationPhase.processing,
      draftType: draftType,
    );

    try {
      if (!await _transcriber.initialize()) {
        state = state.copyWith(
          phase: DictationPhase.paused,
          error: 'No se pudo acceder al micrófono. Revisá los permisos.',
        );
        return;
      }
      await _tts.initialize();
      String? bodegaPreferida;
      try {
        final prefs =
            await _ref.read(chatRepositoryProvider).getOrCreatePreferences();
        await _tts.setRate(prefs.ttsRate);
        bodegaPreferida = prefs.defaultBodegaId;
      } catch (_) {
        // Sin sesión activa: velocidad por defecto.
      }

      _context = await _ref.read(assistantContextBuilderProvider).build();

      // El dictado vive dentro de una sesión de chat: al finalizar, la
      // tarjeta queda como mensaje y se confirma desde ahí.
      final chatNotifier = _ref.read(secretaryChatProvider.notifier);
      var sessionId = _ref.read(secretaryChatProvider).sessionId;
      if (sessionId == null) {
        final session = await _ref
            .read(chatRepositoryProvider)
            .createSessionFromMessage(
              draftType == 'venta' ? 'Dictado de venta' : 'Dictado de entrada',
            );
        sessionId = session.id;
        chatNotifier.openSession(sessionId);
      }

      final draft = await _ref.read(draftEngineProvider).createDraft(
            draftType: draftType,
            sessionId: sessionId,
            bodegaId: bodegaPreferida ?? _context?.selectedWarehouseId,
          );
      state = state.copyWith(draftId: draft.id);

      await _speak(
        draftType == 'venta'
            ? 'Dictame los productos de la venta.'
            : 'Dictame los productos de la entrada.',
      );
      await _listenLoop(gen);
    } catch (e, st) {
      AppLogger.error('[Secretary][Dictado] Error al iniciar', e, st);
      state = state.copyWith(
        phase: DictationPhase.paused,
        error: 'No se pudo iniciar el dictado.',
      );
    }
  }

  /// Cierra sin guardar mensaje (la tarjeta ya quedó si se finalizó antes).
  Future<void> stop({bool discardDraft = false}) async {
    _generation++;
    _transcriber.cancel();
    await _tts.stop();
    final draftId = state.draftId;
    if (discardDraft && draftId != null) {
      await _ref.read(draftEngineProvider).discard(draftId);
    }
    state = const DictationState();
  }

  /// Tap en el micrófono: escuchando → cerrar frase ya; en pausa → retomar.
  Future<void> tapMic() async {
    switch (state.phase) {
      case DictationPhase.listening:
        await _transcriber.stopListening();
      case DictationPhase.paused:
        state = state.copyWith(clearError: true);
        await _listenLoop(_generation);
      case DictationPhase.processing:
        break;
    }
  }

  /// Botón "Listo": cierra el dictado dejando la tarjeta en el chat.
  Future<void> finish() async {
    final gen = ++_generation; // corta el loop de escucha
    _transcriber.cancel();
    final draftId = state.draftId;
    final sessionId = _ref.read(secretaryChatProvider).sessionId;
    if (draftId == null || sessionId == null) {
      state = const DictationState();
      return;
    }

    final items =
        await _ref.read(driftDatabaseProvider).secretaryDao.getDraftItems(draftId);
    if (items.isEmpty) {
      await _ref.read(draftEngineProvider).discard(draftId);
      state = const DictationState();
      return;
    }

    final pendientes =
        items.where((i) => i.status != 'ready' || i.productId == null).length;

    // Con confirmBeforeExecute desactivado, el "listo" verbal cuenta como
    // confirmación explícita y se ejecuta directo (solo si no hay ítems por
    // revisar); con el default activado, siempre pasa por el botón.
    var autoExecute = false;
    if (pendientes == 0) {
      try {
        final prefs =
            await _ref.read(chatRepositoryProvider).getOrCreatePreferences();
        autoExecute = !prefs.confirmBeforeExecute;
      } catch (_) {}
    }

    await _ref.read(chatRepositoryProvider).appendAssistantMessage(
          sessionId,
          pendientes > 0
              ? 'Dictado finalizado: ${items.length} ítems, $pendientes por '
                  'revisar. Corregilos en la tabla y confirmá.'
              : 'Dictado finalizado: ${items.length} ítems. Revisá la tabla '
                  'y confirmá.',
          contentType: 'draft_card',
          draftId: draftId,
        );

    if (autoExecute) {
      await _speak('Registrando.');
      await _ref.read(secretaryChatProvider.notifier).confirmDraft(draftId);
    }

    if (gen != _generation) return;
    state = const DictationState();
  }

  Future<void> _listenLoop(int gen) async {
    while (mounted && gen == _generation && state.active) {
      state = state.copyWith(
        phase: DictationPhase.listening,
        partialText: '',
        soundLevel: 0,
        clearError: true,
      );

      // Pausa corta (1.2 s) para reaccionar rápido entre ítems dictados.
      final segment = await _transcriber.listen(
        pauseFor: const Duration(milliseconds: 1200),
        listenFor: const Duration(seconds: 45),
      );
      if (!mounted || gen != _generation || !state.active) return;

      if (segment == null || segment.trim().isEmpty) {
        state = state.copyWith(phase: DictationPhase.paused, partialText: '');
        return;
      }

      state = state.copyWith(
        phase: DictationPhase.processing,
        partialText: segment,
      );

      final command = DictationParser.parseCommand(segment);
      if (command != null) {
        final keepGoing = await _handleCommand(command);
        if (!keepGoing || !mounted || gen != _generation) return;
        continue;
      }

      final correction =
          DictationParser.parseCorrectLastCommand(segment, esVenta: _esVenta);
      if (correction != null) {
        await _handleLastCorrection(correction);
        if (!mounted || gen != _generation || !state.active) return;
        continue;
      }

      await _handleSegment(segment, gen);
      if (!mounted || gen != _generation || !state.active) return;
    }
  }

  /// true = seguir escuchando; false = el comando cerró el dictado.
  Future<bool> _handleCommand(DictationCommand command) async {
    switch (command) {
      case DictationCommand.finish:
        await finish();
        return false;
      case DictationCommand.cancelAll:
        await _speak('Dictado cancelado.');
        await stop(discardDraft: true);
        return false;
      case DictationCommand.undoLast:
        final draftId = state.draftId;
        if (draftId != null) {
          final items = await _ref
              .read(driftDatabaseProvider)
              .secretaryDao
              .getDraftItems(draftId);
          if (items.isNotEmpty) {
            await _ref.read(draftEngineProvider).removeItem(items.last.id);
            await _speak('Borrado.');
            state = state.copyWith(lastAck: 'Último ítem borrado');
          }
        }
        return true;
    }
  }

  /// "Corrige/cambia lo último a …": ajusta cantidad, costo o precio de la
  /// última fila sin borrarla ni pedir que se repita todo el ítem.
  Future<void> _handleLastCorrection(DictationLastCorrection correction) async {
    final draftId = state.draftId;
    if (draftId == null) return;
    final items =
        await _ref.read(driftDatabaseProvider).secretaryDao.getDraftItems(draftId);
    if (items.isEmpty) {
      await _speak('No hay ítems para corregir.');
      return;
    }
    final last = items.last;
    await _ref.read(draftEngineProvider).updateItem(
          last.id,
          cantidad: correction.field == DictationCorrectionField.cantidad
              ? correction.value
              : null,
          costoUnitario: correction.field == DictationCorrectionField.costo
              ? correction.value
              : null,
          precioUnitario: correction.field == DictationCorrectionField.precio
              ? correction.value
              : null,
        );
    final label = switch (correction.field) {
      DictationCorrectionField.cantidad => 'Cantidad',
      DictationCorrectionField.costo => 'Costo',
      DictationCorrectionField.precio => 'Precio',
    };
    final ack = '$label corregido a ${_qty(correction.value)}';
    state = state.copyWith(lastAck: ack);
    await _speak(ack);
  }

  Future<void> _handleSegment(String segment, int gen) async {
    final draftId = state.draftId;
    final context = _context;
    if (draftId == null || context == null) return;

    // Vía rápida: parser local + resolución contra catálogo (sin red).
    final line = DictationParser.parseLine(segment, esVenta: _esVenta);
    if (line != null) {
      final inserted = await _ref.read(draftEngineProvider).addItems(
            draftId: draftId,
            rawItems: [
              RawDraftItem(
                nombre: line.nombre,
                cantidad: line.cantidad,
                costoUnitario: line.costo,
                precioUnitario: line.precio,
              ),
            ],
            context: context,
          );
      if (!mounted || gen != _generation) return;

      final item = inserted.isNotEmpty ? inserted.first : null;
      final needsReview =
          item == null || item.status != 'ready' || item.productId == null;
      final nombre = item?.resolvedName ?? line.nombre;
      final ack = needsReview
          ? '${_qty(line.cantidad)} $nombre, por revisar'
          : '${_qty(line.cantidad)} $nombre';
      state = state.copyWith(lastAck: ack);
      await _speak(ack);
      return;
    }

    // Vía lenta: fallback LLM en segundo plano, el dictado sigue.
    state = state.copyWith(
      lastAck: 'Procesando: "$segment"',
      pendingFallbacks: state.pendingFallbacks + 1,
    );
    _runFallback(segment, draftId, context, gen);
  }

  Future<void> _runFallback(
    String segment,
    String draftId,
    AssistantOperationalContext context,
    int gen,
  ) async {
    // Registro del segmento que no entendió el parser local: insumo para
    // iterar la gramática con datos reales (F8.4; solo local, 14 días).
    unawaited(_logFallbackSegment(segment));
    try {
      final items = await _fallback.extractItems(segment, esVenta: _esVenta);
      if (items.isNotEmpty) {
        await _ref.read(draftEngineProvider).addItems(
              draftId: draftId,
              rawItems: items,
              context: context,
            );
      } else {
        // No perder lo dictado: fila "por revisar" con el texto crudo.
        await _ref.read(draftEngineProvider).addItems(
              draftId: draftId,
              rawItems: [RawDraftItem(nombre: segment, cantidad: 1)],
              context: context,
            );
      }
    } catch (e) {
      AppLogger.warn('[Secretary][Dictado] Fallback falló para "$segment": $e');
    } finally {
      if (mounted && gen == _generation && state.active) {
        state = state.copyWith(
          pendingFallbacks: (state.pendingFallbacks - 1).clamp(0, 99),
        );
      }
    }
  }

  Future<void> _logFallbackSegment(String segment) async {
    try {
      final sessionId = _ref.read(secretaryChatProvider).sessionId;
      if (sessionId == null) return;
      await _ref.read(chatRepositoryProvider).saveTrace(
            sessionId: sessionId,
            toolCallsJson: segment,
            model: 'dictation_fallback',
          );
    } catch (_) {
      // Telemetría best-effort.
    }
  }

  Future<void> _speak(String text) async {
    final gen = _generation;
    var done = false;
    _tts.onSpeakComplete = () => done = true;
    await _tts.speak(text);
    while (!done && mounted && gen == _generation && state.active) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Margen para que la cola del TTS no se cuele en el micrófono.
    await Future.delayed(const Duration(milliseconds: 250));
  }

  String _qty(double q) =>
      q == q.roundToDouble() ? q.toInt().toString() : q.toString();

  @override
  void dispose() {
    _generation++;
    _transcriber.dispose();
    _tts.dispose();
    super.dispose();
  }
}

final dictationProvider =
    StateNotifierProvider<DictationController, DictationState>((ref) {
  return DictationController(ref);
});
