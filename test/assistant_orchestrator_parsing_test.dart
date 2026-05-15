import 'package:flutter_test/flutter_test.dart';
import 'package:inventario_v2/features/assistant/core/stepwise_orchestrator.dart';

void main() {
  group('ReactDecision.fromJson', () {
    test(
      'acepta tool call aunque action venga con el id de la herramienta',
      () {
        final decision = ReactDecision.fromJson({
          'action': 'entity_resolver.resolveProduct',
          'tool': 'entity_resolver.resolveProduct',
          'params': {'query': 'deshodorantes'},
          'reasoning': 'Resolver producto',
        });

        expect(decision.action, ReactAction.useTool);
        expect(decision.toolId, 'entity_resolver.resolveProduct');
        expect(decision.toolParams?['query'], 'deshodorantes');
      },
    );

    test(
      'acepta tool call cuando action es invalido pero tool esta presente',
      () {
        final decision = ReactDecision.fromJson({
          'action': 'resolve_product',
          'tool': 'entity_resolver.resolveProduct',
          'params': {'query': 'desodorante'},
          'reasoning': 'Resolver producto',
        });

        expect(decision.action, ReactAction.useTool);
        expect(decision.toolId, 'entity_resolver.resolveProduct');
      },
    );
  });
}
