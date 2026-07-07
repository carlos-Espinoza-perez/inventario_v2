import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/core/presentation/mixins/app_bar_config_mixin.dart';
import 'package:inventario_v2/core/providers/app_bar_provider.dart';
import 'package:inventario_v2/core/providers/drift_provider.dart';

/// Diagnóstico del secretario (F7.2/F8): métricas del día y trazas por turno
/// (tools, tokens, latencia, payload enviado, errores). Todo es local
/// (chat_turn_traces, retención 14 días); nada de esto se sincroniza.
class SecretaryDiagnosticsScreen extends ConsumerStatefulWidget {
  const SecretaryDiagnosticsScreen({super.key});

  @override
  ConsumerState<SecretaryDiagnosticsScreen> createState() =>
      _SecretaryDiagnosticsScreenState();
}

class _SecretaryDiagnosticsScreenState
    extends ConsumerState<SecretaryDiagnosticsScreen>
    with AppBarConfigMixin {
  // Tarifas gpt-4o-mini por millón de tokens (referencia para costo estimado).
  static const _inPricePerM = 0.15;
  static const _outPricePerM = 0.60;

  @override
  void configureAppBar() {
    ref
        .read(appBarProvider.notifier)
        .setOptions(title: 'Diagnóstico del secretario', showBackButton: true);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(configureAppBar);
  }

  @override
  Widget build(BuildContext context) {
    final tracesFuture = ref
        .watch(driftDatabaseProvider)
        .secretaryDao
        .getRecentTraces();

    return Scaffold(
      body: FutureBuilder<List<ChatTurnTrace>>(
        future: tracesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final traces = snapshot.data!;
          if (traces.isEmpty) {
            return const Center(
              child: Text('Sin trazas todavía. Usá el chat y volvé.'),
            );
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final todayTraces = traces
              .where((t) => t.createdAt.isAfter(today))
              .toList();
          final turns = todayTraces
              .where((t) => t.model != 'dictation_fallback')
              .toList();
          final tokensIn = turns.fold<int>(0, (s, t) => s + (t.tokensIn ?? 0));
          final tokensOut = turns.fold<int>(
            0,
            (s, t) => s + (t.tokensOut ?? 0),
          );
          final cost =
              tokensIn / 1e6 * _inPricePerM + tokensOut / 1e6 * _outPricePerM;
          final latencies = [
            for (final t in turns)
              if (t.latencyMs != null) t.latencyMs!,
          ];
          final avgLatency = latencies.isEmpty
              ? 0
              : latencies.reduce((a, b) => a + b) ~/ latencies.length;
          final errors = turns.where((t) => t.errorText != null).length;
          final fallbacks = todayTraces
              .where((t) => t.model == 'dictation_fallback')
              .length;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoy',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 6),
                      Text('Turnos: ${turns.length} · Errores: $errors'),
                      Text(
                        'Tokens: $tokensIn entrada / $tokensOut salida '
                        '(~\$${cost.toStringAsFixed(4)})',
                      ),
                      Text('Latencia promedio: $avgLatency ms'),
                      Text('Dictado → fallback LLM: $fallbacks segmentos'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final t in traces) _TraceTile(trace: t),
            ],
          );
        },
      ),
    );
  }
}

class _TraceTile extends StatelessWidget {
  final ChatTurnTrace trace;

  const _TraceTile({required this.trace});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFallback = trace.model == 'dictation_fallback';
    final hasError = trace.errorText != null;
    final hh = trace.createdAt.hour.toString().padLeft(2, '0');
    final mm = trace.createdAt.minute.toString().padLeft(2, '0');

    return ListTile(
      dense: true,
      leading: Icon(
        hasError
            ? Icons.error_outline
            : isFallback
            ? Icons.record_voice_over_outlined
            : Icons.check_circle_outline,
        color: hasError
            ? scheme.error
            : isFallback
            ? scheme.tertiary
            : Colors.green,
        size: 20,
      ),
      title: Text(
        isFallback
            ? 'Dictado → fallback: "${trace.toolCallsJson ?? ''}"'
            : hasError
            ? 'Turno con error'
            : 'Turno OK · ${trace.latencyMs ?? '-'} ms',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '$hh:$mm · ${trace.tokensIn ?? 0}/${trace.tokensOut ?? 0} tok · '
        'ref ${trace.id.substring(0, 8)}',
      ),
      onTap: () => _showDetail(context),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Traza ${trace.id.substring(0, 8)}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              [
                'Fecha: ${trace.createdAt}',
                'Modelo: ${trace.model ?? '-'}',
                'Latencia: ${trace.latencyMs ?? '-'} ms',
                'Tokens: ${trace.tokensIn ?? 0} in / ${trace.tokensOut ?? 0} out',
                if (trace.errorText != null) '\nERROR:\n${trace.errorText}',
                if (trace.toolCallsJson != null)
                  '\nTOOL CALLS:\n${trace.toolCallsJson}',
                if (trace.toolResultsJson != null)
                  '\nTOOL RESULTS:\n${trace.toolResultsJson}',
                if (trace.requestJson != null)
                  '\nREQUEST (payload al LLM):\n${trace.requestJson}',
              ].join('\n'),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
