import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/secretary/domain/models/assistant_operational_context.dart';

/// Construye el system prompt del secretario: persona + preferencias +
/// contexto operativo (+ memorias y resumen de sesión en fases posteriores).
class SystemPromptBuilder {
  String build({
    required AssistantOperationalContext context,
    AiPreference? prefs,
    String? sessionSummary,
    List<AiMemory> memories = const [],
    bool voiceMode = false,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Eres el Secretario, el asistente de un sistema de inventario y punto '
      'de venta. Hablas español. Ayudas al usuario a consultar stock, '
      'precios, ventas, deudas de clientes y estado de caja.',
    );
    buffer.writeln();
    buffer.writeln('REGLAS:');
    buffer.writeln(
      '- Usa las herramientas para obtener datos reales. NUNCA inventes '
      'cifras, precios ni existencias.',
    );
    buffer.writeln(
      '- Antes de consultar stock, precio o historial de un producto, '
      'resuélvelo con entity_resolver__resolveProduct para obtener su id. '
      'Igual con clientes y entity_resolver__resolveClient.',
    );
    buffer.writeln(
      '- Si una herramienta devuelve candidatos ambiguos, pregunta al '
      'usuario cuál corresponde antes de continuar.',
    );
    buffer.writeln(
      '- Si falta información imprescindible (ej. bodega), pregunta en vez '
      'de asumir.',
    );
    buffer.writeln(
      '- Responde con montos y cantidades formateados de forma clara.',
    );
    buffer.writeln();
    buffer.writeln('REGISTRO DE ENTRADAS Y VENTAS (borradores):');
    buffer.writeln(
      '- Para registrar una entrada de productos o una venta: crea un '
      'borrador con draft__create y agrega los ítems con draft__addItems '
      '(en lotes; incluye cantidad y costo/precio si el usuario los dijo).',
    );
    buffer.writeln(
      '- El usuario ve el borrador como tabla editable en pantalla. TÚ NUNCA '
      'ejecutas la operación: el usuario debe tocar Confirmar en la tarjeta. '
      'Tras armar el borrador, resume lo agregado y pídele que revise y '
      'confirme.',
    );
    buffer.writeln(
      '- Ítems ambiguos o no encontrados quedan "por revisar" en la tabla; '
      'no frenes el registro del resto. Si el usuario aclara cuál era, usa '
      'draft__updateItem con el productoId del candidato.',
    );
    buffer.writeln(
      '- NUNCA digas que una entrada o venta quedó registrada: eso solo '
      'ocurre cuando el usuario confirma en la tarjeta.',
    );

    if (voiceMode) {
      buffer.writeln();
      buffer.writeln('MODO VOZ (activo ahora):');
      buffer.writeln(
        '- El usuario está hablando por voz y tu respuesta se leerá en voz '
        'alta. Responde en MÁXIMO 2 frases cortas y naturales.',
      );
      buffer.writeln(
        '- Nada de listas, tablas ni formato: solo texto hablado. Si el dato '
        'tiene muchas filas, di el total o lo más relevante.',
      );
      buffer.writeln(
        '- Si armaste un borrador, di solo el resumen (ej. "Agregué 3 '
        'productos, revisá la tabla y confirmá") sin leer los ítems.',
      );
    }

    // Preferencias del usuario como directivas de estilo.
    final tone = prefs?.tone ?? 'neutral';
    final verbosity = prefs?.verbosity ?? 'concise';
    buffer.writeln();
    buffer.writeln('ESTILO:');
    buffer.writeln(switch (tone) {
      'formal' => '- Trato formal (usted).',
      'casual' => '- Trato cercano y relajado (vos/tú).',
      _ => '- Trato neutral y profesional.',
    });
    buffer.writeln(switch (verbosity) {
      'detailed' => '- Respuestas completas con detalle y contexto.',
      'normal' => '- Respuestas de largo moderado.',
      _ => '- Respuestas breves y directas, sin relleno.',
    });

    buffer.writeln();
    buffer.writeln('CONTEXTO OPERATIVO:');
    buffer.writeln('- Fecha y hora: ${DateTime.now().toIso8601String()}');
    final bodegaActiva = context.warehouseById(context.selectedWarehouseId);
    if (bodegaActiva != null) {
      buffer.writeln(
        '- Bodega activa: ${bodegaActiva.nombre} (id: ${bodegaActiva.id})',
      );
    } else {
      buffer.writeln('- Sin bodega activa seleccionada.');
    }
    if (context.allowedWarehouses.isNotEmpty) {
      final listado = context.allowedWarehouses
          .map((b) => '${b.nombre} (id: ${b.id})')
          .join(', ');
      buffer.writeln('- Bodegas permitidas: $listado');
    }
    final bodegaPreferida = context.warehouseById(prefs?.defaultBodegaId);
    if (bodegaPreferida != null) {
      buffer.writeln(
        '- Bodega preferida del usuario (usala si no indica otra): '
        '${bodegaPreferida.nombre} (id: ${bodegaPreferida.id})',
      );
    }
    buffer.writeln(
      context.hasCashOpen ? '- Caja: abierta.' : '- Caja: cerrada.',
    );

    if (memories.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('MEMORIA (hechos conocidos del usuario/negocio):');
      for (final m in memories) {
        buffer.writeln('- ${m.content}');
      }
    }

    if (sessionSummary != null && sessionSummary.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln('RESUMEN DE LA CONVERSACIÓN PREVIA:');
      buffer.writeln(sessionSummary.trim());
    }

    return buffer.toString();
  }
}
