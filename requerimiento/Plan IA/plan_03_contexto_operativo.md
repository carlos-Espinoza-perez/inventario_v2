# Plan 03 - Contexto operativo del Secretario
**Origen:** `requerimiento/Add IA/03_contexto_operativo.md`

---

## Objetivo

Implementar `AssistantOperationalContext` y el mecanismo para construirlo leyendo los providers reales del proyecto. La resolución del contexto ocurre en la capa `data/`, **no en `domain/`**, porque necesita leer `Ref` de Riverpod — un detalle de infraestructura que la capa de dominio no debe conocer.

---

## Fuentes de datos confirmadas

| Dato | Provider / método real |
|---|---|
| `empresaId` | `authControllerProvider.notifier.sesionActiva?.empresa.id` |
| `usuarioId` | `authControllerProvider.notifier.usuarioActual?.id` |
| `permissionCodes` | `authorizationStateProvider` → `AsyncValue<AuthorizationState>` → `.permissions` |
| `selectedWarehouseId` | `selectedBodegaProvider` → `StateProvider<Bodega?>` → `.id` |
| `allowedWarehouseIds` | `validBodegasIdsProvider` → `FutureProvider<Set<String>>` |
| `openCashSessionId` | `dashboardProvider` → `FutureProvider<DashboardState>` → `.cajaAbierta?.id` |

**Importante:** `authorizationStateProvider` y `dashboardProvider` son `FutureProvider.autoDispose`. Se deben leer con `.future` para obtener el valor real.

---

## Archivos a crear

| Archivo | Capa | Propósito |
|---|---|---|
| `lib/features/assistant/domain/models/assistant_operational_context.dart` | domain | Clase de datos pura, sin dependencias de framework |
| `lib/features/assistant/data/assistant_context_builder.dart` | data | Lee providers reales y construye el contexto |

---

## Paso 1 — AssistantOperationalContext (capa domain, sin Ref)

```dart
// lib/features/assistant/domain/models/assistant_operational_context.dart

class AssistantOperationalContext {
  final String empresaId;
  final String usuarioId;
  final Set<String> permissionCodes;
  final String? selectedWarehouseId;
  final Set<String> allowedWarehouseIds;
  final String? openCashSessionId;

  const AssistantOperationalContext({
    required this.empresaId,
    required this.usuarioId,
    required this.permissionCodes,
    required this.selectedWarehouseId,
    required this.allowedWarehouseIds,
    required this.openCashSessionId,
  });

  bool hasPermission(String code) {
    // Admins con permiso '*' tienen acceso a todo
    if (permissionCodes.contains('*')) return true;
    return permissionCodes.contains(code);
  }

  bool hasAnyPermission(List<String> codes) => codes.any(hasPermission);

  bool get hasCashOpen => openCashSessionId != null;
  bool get hasWarehouseSelected => selectedWarehouseId != null;
  bool get isValid => empresaId.isNotEmpty && usuarioId.isNotEmpty;
}
```

---

## Paso 2 — AssistantContextBuilder (capa data, con Ref)

```dart
// lib/features/assistant/data/assistant_context_builder.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventario_v2/features/auth/presentation/providers/auth_provider.dart';
import 'package:inventario_v2/features/auth/presentation/providers/authorization_provider.dart';
import 'package:inventario_v2/features/inventory/data/providers/bodega_provider.dart';
import 'package:inventario_v2/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../domain/models/assistant_operational_context.dart';

class AssistantContextBuilder {
  final Ref _ref;

  const AssistantContextBuilder(this._ref);

  Future<AssistantOperationalContext> build() async {
    // 1. Sesión activa (síncrona — authControllerProvider es keepAlive)
    final authNotifier = _ref.read(authControllerProvider.notifier);
    final sesion = authNotifier.sesionActiva;
    final empresaId = sesion?.empresa.id ?? '';
    final usuarioId = authNotifier.usuarioActual?.id ?? '';

    // 2. Permisos (FutureProvider — usar .future)
    final authState = await _ref.read(authorizationStateProvider.future);
    final permissionCodes = authState.permissions;

    // 3. Bodega seleccionada (StateProvider — síncrono)
    final bodega = _ref.read(selectedBodegaProvider);
    final selectedWarehouseId = bodega?.id;

    // 4. Bodegas permitidas (FutureProvider)
    final allowedIds = await _ref.read(validBodegasIdsProvider.future);

    // 5. Caja abierta (FutureProvider)
    AssistantOperationalContext context;
    try {
      final dashboard = await _ref.read(dashboardProvider.future);
      final openCashSessionId = dashboard.cajaAbierta?.id;
      context = AssistantOperationalContext(
        empresaId: empresaId,
        usuarioId: usuarioId,
        permissionCodes: permissionCodes,
        selectedWarehouseId: selectedWarehouseId,
        allowedWarehouseIds: allowedIds,
        openCashSessionId: openCashSessionId,
      );
    } catch (_) {
      // Si el dashboard falla, construir contexto sin caja
      context = AssistantOperationalContext(
        empresaId: empresaId,
        usuarioId: usuarioId,
        permissionCodes: permissionCodes,
        selectedWarehouseId: selectedWarehouseId,
        allowedWarehouseIds: allowedIds,
        openCashSessionId: null,
      );
    }

    return context;
  }
}

final assistantContextBuilderProvider = Provider<AssistantContextBuilder>(
  (ref) => AssistantContextBuilder(ref),
);
```

---

## Paso 3 — Actualizar AssistantOrchestrator para recibir contexto

El orquestador vive en `domain/services/` y **recibe** el contexto ya construido como parámetro. No lo construye él mismo.

```dart
// lib/features/assistant/domain/services/assistant_orchestrator.dart

import '../models/assistant_intent.dart';
import '../models/assistant_operational_context.dart';
import '../models/assistant_response.dart';
import 'assistant_parser.dart';
import '../../data/assistant_query_repository.dart';

class AssistantOrchestrator {
  final AssistantParser _parser;
  final AssistantQueryRepository _queryRepository;

  const AssistantOrchestrator({
    required AssistantParser parser,
    required AssistantQueryRepository queryRepository,
  });

  Future<AssistantResponse> handle(
    String rawText,
    AssistantOperationalContext context,
  ) async {
    // 1. Validar contexto mínimo
    if (!context.isValid) {
      return AssistantResponse.error(
        'No hay sesión activa. Iniciá sesión antes de usar el Secretario.',
      );
    }

    // 2. Parsear intent
    final intent = _parser.parse(rawText);

    if (intent.isUnsupported) {
      return AssistantResponse(
        text: 'No entendí esa consulta. Podés preguntar por stock, precio, '
            'deudas, ventas o el estado de la caja.',
      );
    }

    // 3. Validar permisos según intent
    final permissionError = _checkPermission(intent, context);
    if (permissionError != null) return AssistantResponse.error(permissionError);

    // 4. Validaciones de contexto específicas por intent
    final contextError = _checkContext(intent, context);
    if (contextError != null) return AssistantResponse(text: contextError);

    // 5. Ejecutar consulta
    return _queryRepository.execute(intent, context);
  }

  String? _checkPermission(
      AssistantIntent intent, AssistantOperationalContext ctx) {
    const productIntents = {
      AssistantIntentType.queryStockProduct,
      AssistantIntentType.queryPriceProduct,
      AssistantIntentType.queryLastSaleProduct,
      AssistantIntentType.queryProductHistory,
    };
    const commercialIntents = {
      AssistantIntentType.queryReceivableBalanceClient,
      AssistantIntentType.queryReceivablesSummary,
      AssistantIntentType.querySalesSummary,
      AssistantIntentType.queryCashStatus,
    };

    if (productIntents.contains(intent.type)) {
      if (!ctx.hasAnyPermission(['product.read', 'warehouse.read'])) {
        return 'No tenés permiso para consultar productos.';
      }
    }
    if (commercialIntents.contains(intent.type)) {
      if (!ctx.hasAnyPermission(['report.read', 'sale.read'])) {
        return 'No tenés permiso para consultar información comercial.';
      }
    }
    return null;
  }

  String? _checkContext(
      AssistantIntent intent, AssistantOperationalContext ctx) {
    if (intent.type == AssistantIntentType.queryStockProduct &&
        !ctx.hasWarehouseSelected) {
      return 'Para consultar stock necesito saber en cuál bodega. '
          'Seleccioná una bodega antes de continuar.';
    }
    if (intent.type == AssistantIntentType.queryCashStatus &&
        !ctx.hasCashOpen) {
      return 'No hay caja abierta en este momento.';
    }
    return null;
  }
}
```

---

## Paso 4 — Actualizar AssistantProvider para construir contexto

```dart
// En assistant_provider.dart — método sendMessage actualizado

Future<void> sendMessage(String text) async {
  if (text.trim().isEmpty) return;

  // Agregar mensaje del usuario
  final userMsg = AssistantMessage(
    id: _uuid.v4(),
    role: MessageRole.user,
    text: text.trim(),
    timestamp: DateTime.now(),
  );
  state = state.copyWith(
    messages: [...state.messages, userMsg],
    isLoading: true,
  );

  try {
    // Construir contexto antes de llamar al orquestador
    final context = await _contextBuilder.build();
    final response = await _orchestrator.handle(text.trim(), context);

    final reply = AssistantMessage(
      id: _uuid.v4(),
      role: response.isError ? MessageRole.error : MessageRole.assistant,
      text: response.text,
      timestamp: DateTime.now(),
      clarificationOptions: response.clarificationOptions,
    );
    state = state.copyWith(
      messages: [...state.messages, reply],
      isLoading: false,
    );
  } catch (_) {
    final errMsg = AssistantMessage(
      id: _uuid.v4(),
      role: MessageRole.error,
      text: 'Ocurrió un error inesperado. Intentá de nuevo.',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, errMsg],
      isLoading: false,
    );
  }
}
```

El `AssistantNotifier` recibe tanto `AssistantOrchestrator` como `AssistantContextBuilder`:

```dart
class AssistantNotifier extends StateNotifier<AssistantState> {
  final AssistantOrchestrator _orchestrator;
  final AssistantContextBuilder _contextBuilder;
  static const _uuid = Uuid();

  AssistantNotifier(this._orchestrator, this._contextBuilder)
      : super(const AssistantState());
  // ...
}

final assistantProvider =
    StateNotifierProvider<AssistantNotifier, AssistantState>((ref) {
  return AssistantNotifier(
    ref.watch(assistantOrchestratorProvider),
    ref.watch(assistantContextBuilderProvider),
  );
});
```

---

## Tabla de permisos requeridos por intent

| Intent | Permisos aceptados |
|---|---|
| `queryStockProduct` | `product.read` OR `warehouse.read` |
| `queryPriceProduct` | `product.read` OR `warehouse.read` |
| `queryLastSaleProduct` | `product.read` OR `warehouse.read` |
| `queryProductHistory` | `product.read` OR `warehouse.read` |
| `queryReceivableBalanceClient` | `report.read` OR `sale.read` |
| `queryReceivablesSummary` | `report.read` OR `sale.read` |
| `querySalesSummary` | `report.read` OR `sale.read` |
| `queryCashStatus` | `sale.read` |
| `actionRegisterSale` | `sale.create` |
| `actionRegisterSale` (crédito) | `sale.create` + `sale.credit` |
| `actionRegisterEntry` | `warehouse.update` |
| `actionRegisterOutputAdjustment` | `warehouse.update` |

> Los admins tienen `*` en `permissions`, lo que ya maneja `hasPermission('*')` como true para todo.

---

## Criterio de cierre

- [ ] `AssistantOperationalContext` se construye desde providers reales (no stubs)
- [ ] `empresaId` y `usuarioId` vienen de `authControllerProvider.notifier`
- [ ] Permisos vienen de `authorizationStateProvider` con `.future`
- [ ] Bodega usa `selectedBodegaProvider` (StateProvider, lectura síncrona)
- [ ] Caja usa `dashboardProvider` con `.future`
- [ ] Contexto vacío/inválido bloquea todas las consultas con mensaje claro
- [ ] `Ref` nunca entra a la capa `domain/`
