import 'dart:convert';

import 'package:inventario_v2/core/constants/permission_codes.dart';
import 'package:inventario_v2/core/db/app_database.dart';
import 'package:inventario_v2/features/assistant/data/entity_resolver.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_entry_models.dart';
import 'package:inventario_v2/features/assistant/domain/models/assistant_operational_context.dart';
import 'package:inventario_v2/features/inventory/domain/use_cases/registrar_entrada_use_case.dart';

import 'assistant_entry_draft_repository.dart';
import 'product_category_resolver.dart';

class AssistantEntryWorkflowService {
  final AppDatabase _db;
  final AssistantEntryDraftRepository _draftRepository;
  final EntityResolver _entityResolver;
  final ProductCategoryResolver _categoryResolver;
  final RegistrarEntradaUseCase _registrarEntradaUseCase;

  AssistantEntryWorkflowService({
    required AppDatabase db,
    required AssistantEntryDraftRepository draftRepository,
    required EntityResolver entityResolver,
    required ProductCategoryResolver categoryResolver,
    required RegistrarEntradaUseCase registrarEntradaUseCase,
  }) : _db = db,
       _draftRepository = draftRepository,
       _entityResolver = entityResolver,
       _categoryResolver = categoryResolver,
       _registrarEntradaUseCase = registrarEntradaUseCase;

  Future<AssistantEntryWorkflowResult> process({
    required String message,
    required AssistantOperationalContext context,
    bool forceStart = false,
  }) async {
    final normalized = _normalize(message);
    final bodegaId = context.selectedWarehouseId;
    if (bodegaId == null || bodegaId.isEmpty) {
      if (_looksLikeEntryStart(normalized)) {
        return const AssistantEntryWorkflowResult(
          handled: true,
          responseText: 'En que bodega queres registrar esta entrada?',
        );
      }
      return const AssistantEntryWorkflowResult.notHandled();
    }

    final activeSession = await _draftRepository.getActive(
      empresaId: context.empresaId,
      usuarioId: context.usuarioId,
      bodegaId: bodegaId,
    );

    if (activeSession != null && _isCancel(normalized)) {
      await _draftRepository.cancelSession(activeSession.id);
      return const AssistantEntryWorkflowResult(
        handled: true,
        responseText: 'Entrada cancelada. No se guardo nada.',
        cancelled: true,
      );
    }

    if (activeSession != null && _isShowDraft(normalized)) {
      final draft = await _draftRepository.getDraft(activeSession.id);
      return AssistantEntryWorkflowResult(
        handled: true,
        responseText: _formatDraft(draft),
        draft: draft,
      );
    }

    if (activeSession != null && _isConfirm(normalized)) {
      return _confirm(activeSession.id, context);
    }

    if (activeSession != null && _isCategoryChange(normalized)) {
      final categoryName = _extractCategoryName(message);
      if (categoryName == null) {
        return const AssistantEntryWorkflowResult(
          handled: true,
          responseText:
              'Decime la categoria que queres usar. Ej: cambiar categoria a Calzado.',
        );
      }
      final category = await _categoryResolver.resolveOrCreate(
        name: categoryName,
        empresaId: context.empresaId,
        usuarioId: context.usuarioId,
      );
      await _draftRepository.updateCategory(
        sessionId: activeSession.id,
        categoryId: category.id,
        categoryName: category.nombre,
      );
      final draft = await _draftRepository.getDraft(activeSession.id);
      return AssistantEntryWorkflowResult(
        handled: true,
        responseText:
            'Categoria actualizada a ${category.nombre}.\n\n${_formatDraft(draft)}',
        draft: draft,
      );
    }

    final parsedItems = _parseItems(
      message,
      allowBareItem: activeSession != null,
    );
    if (parsedItems.isEmpty) {
      if (forceStart && activeSession == null) {
        await _draftRepository.startOrResume(
          empresaId: context.empresaId,
          usuarioId: context.usuarioId,
          bodegaId: bodegaId,
        );
        return const AssistantEntryWorkflowResult(
          handled: true,
          responseText:
              'Perfecto, voy armando una entrada de inventario. Decime producto, cantidad, costo y precio.',
        );
      }
      if (activeSession != null && _looksLikeEntryStart(message)) {
        return const AssistantEntryWorkflowResult(
          handled: true,
          responseText:
              'Decime producto, cantidad, costo y precio. Ej: entraron 10 zapatos a 100 para vender a 200.',
        );
      }
      return const AssistantEntryWorkflowResult.notHandled();
    }

    if (!_canCreateEntry(context)) {
      return const AssistantEntryWorkflowResult(
        handled: true,
        responseText:
            'No tenes permisos suficientes para preparar entradas de inventario.',
      );
    }

    final session =
        activeSession ??
        await _draftRepository.startOrResume(
          empresaId: context.empresaId,
          usuarioId: context.usuarioId,
          bodegaId: bodegaId,
        );

    final addedLines = <AssistantEntryDraftLine>[];
    for (final item in parsedItems) {
      addedLines.add(await _addParsedItem(session.id, item, context));
    }

    final draft = await _draftRepository.getDraft(session.id);
    return AssistantEntryWorkflowResult(
      handled: true,
      responseText: _formatAddedItems(addedLines, draft),
      draft: draft,
    );
  }

  Future<bool> hasActiveSession(AssistantOperationalContext context) async {
    final bodegaId = context.selectedWarehouseId;
    if (bodegaId == null || bodegaId.isEmpty) return false;
    final active = await _draftRepository.getActive(
      empresaId: context.empresaId,
      usuarioId: context.usuarioId,
      bodegaId: bodegaId,
    );
    return active != null;
  }

  Future<AssistantEntryDraftLine> _addParsedItem(
    String sessionId,
    _ParsedEntryItem item,
    AssistantOperationalContext context,
  ) async {
    final result = await _entityResolver.resolveProduct(
      item.productName,
      empresaId: context.empresaId,
    );

    if (result.isResolved && result.selected != null) {
      final product = result.selected!;
      final category = product.categoriaId == null
          ? await _categoryResolver.suggest(
              productName: product.nombre,
              empresaId: context.empresaId,
            )
          : await _categoryFromId(product.categoriaId!, context.empresaId);
      return _draftRepository.addItem(
        sessionId: sessionId,
        proposedName: item.productName,
        productId: product.id,
        resolvedName: product.nombre,
        categoryId: category.id,
        categoryName: category.name,
        quantity: item.quantity,
        unitCost:
            item.unitCost ??
            (product.ultimoCosto > 0 ? product.ultimoCosto : null),
        unitPrice:
            item.unitPrice ??
            (product.ultimoPrecioVenta > 0
                ? product.ultimoPrecioVenta
                : product.precioBase),
        isNewProduct: false,
      );
    }

    if (result.isAmbiguous) {
      final names = result.candidates
          .whereType<Producto>()
          .map((product) => product.nombre)
          .toList();
      return _draftRepository.addItem(
        sessionId: sessionId,
        proposedName: item.productName,
        productId: null,
        resolvedName: null,
        categoryId: null,
        categoryName: null,
        quantity: item.quantity,
        unitCost: item.unitCost,
        unitPrice: item.unitPrice,
        isNewProduct: false,
        candidates: names,
      );
    }

    final category = await _categoryResolver.suggest(
      productName: item.productName,
      empresaId: context.empresaId,
    );
    return _draftRepository.addItem(
      sessionId: sessionId,
      proposedName: item.productName,
      productId: null,
      resolvedName: _titleCase(item.productName),
      categoryId: category.id,
      categoryName: category.name,
      quantity: item.quantity,
      unitCost: item.unitCost,
      unitPrice: item.unitPrice,
      isNewProduct: true,
    );
  }

  Future<AssistantSuggestedCategory> _categoryFromId(
    String categoryId,
    String empresaId,
  ) async {
    final category = await _db.inventoryDao.getCategoriaById(categoryId);
    if (category != null) {
      return AssistantSuggestedCategory(
        id: category.id,
        name: category.nombre,
        score: 1,
      );
    }
    return _categoryResolver.suggest(
      productName: 'General',
      empresaId: empresaId,
    );
  }

  Future<AssistantEntryWorkflowResult> _confirm(
    String sessionId,
    AssistantOperationalContext context,
  ) async {
    final draft = await _draftRepository.getDraft(sessionId);
    if (draft.isEmpty) {
      return const AssistantEntryWorkflowResult(
        handled: true,
        responseText: 'El borrador esta vacio. Agrega al menos un producto.',
      );
    }
    if (draft.hasBlockingIssues) {
      return AssistantEntryWorkflowResult(
        handled: true,
        responseText:
            'No puedo guardar todavia. Completa los pendientes:\n${_formatPending(draft)}',
        draft: draft,
      );
    }
    if (draft.lines.any((line) => line.isNewProduct) &&
        !context.hasPermission(PermissionCode.productCreate)) {
      return const AssistantEntryWorkflowResult(
        handled: true,
        responseText:
            'El borrador incluye productos nuevos y tu usuario no tiene permiso para crear productos.',
      );
    }

    final bodegaIds = await _db.authDao.getValidBodegasIds();
    final orderLines = <Map<String, dynamic>>[];
    for (final line in draft.lines) {
      var productId = line.productId;
      if (productId == null || productId.isEmpty) {
        final category = await _categoryResolver.resolveOrCreate(
          name: line.categoryName ?? 'General',
          empresaId: context.empresaId,
          usuarioId: context.usuarioId,
        );
        final product = await _db.inventoryDao.saveProductLifecycle(
          empresaId: context.empresaId,
          usuarioRegistroId: context.usuarioId,
          nombre: line.displayName,
          categoriaId: category.id,
          especificacionJson: jsonEncode({
            'category': category.nombre,
            'createdBy': 'assistant_entry_flow',
          }),
          imagenLocal: null,
          imagenUrl: null,
          ultimoCosto: line.unitCost ?? 0,
          precioBase: line.unitPrice ?? 0,
          defaultSku: null,
          bodegaIds: bodegaIds,
        );
        productId = product.id;
      }

      orderLines.add({
        'productId': productId,
        'cost': line.unitCost ?? 0,
        'price': line.unitPrice ?? 0,
        'items': List.generate(
          line.quantity.toInt(),
          (_) => <String, dynamic>{},
        ),
      });
    }

    await _registrarEntradaUseCase.ejecutar(
      bodegaId: draft.bodegaId,
      descripcion: 'Entrada registrada por Secretario IA',
      orderLines: orderLines,
    );
    await _draftRepository.markSessionConfirmed(sessionId);

    return AssistantEntryWorkflowResult(
      handled: true,
      responseText:
          'Listo. Registre la entrada de ${draft.lines.length} producto(s) en inventario.',
      draft: draft,
      confirmed: true,
    );
  }

  List<_ParsedEntryItem> _parseItems(
    String message, {
    bool allowBareItem = false,
  }) {
    final normalized = _normalize(message);
    if (!allowBareItem && !_looksLikeEntryStart(normalized)) return const [];
    final cleaned = normalized.replaceFirst(
      RegExp(
        r'^(?:tambien|también|ademas|además|y|y\s+tambien|y\s+también)\s+',
      ),
      '',
    );

    final segments = cleaned
        .split(RegExp(r'\s+(?:tambien|también|y luego|ademas|además)\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    final items = <_ParsedEntryItem>[];
    for (final segment in segments) {
      final parsed = _parseSingleItem(segment);
      if (parsed != null) items.add(parsed);
    }
    return items;
  }

  _ParsedEntryItem? _parseSingleItem(String message) {
    final quantity = _extractQuantity(message);
    if (quantity == null) return null;

    var rest = message.substring(quantity.endIndex).trim();
    rest = rest.replaceFirst(RegExp(r'^(?:de|unidades?\s+de)\s+'), '');
    final unitCost = _extractCost(rest);
    final unitPrice = _extractPrice(rest);

    final productName = rest
        .split(
          RegExp(
            r'\s+(?:a|en|costo|costaron|compre|compré|para|precio|vender|darlos)\b',
          ),
        )
        .first
        .replaceAll(RegExp(r'\b(?:los|las|el|la)\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (productName.length < 3) return null;
    return _ParsedEntryItem(
      productName: productName,
      quantity: quantity.value,
      unitCost: unitCost,
      unitPrice: unitPrice,
    );
  }

  _ParsedQuantity? _extractQuantity(String message) {
    final dozen = RegExp(r'(\d+(?:[.,]\d+)?)\s+docenas?').firstMatch(message);
    if (dozen != null) {
      final raw = dozen.group(1)!;
      final value = (double.tryParse(raw.replaceAll(',', '.')) ?? 0) * 12;
      if (value > 0) return _ParsedQuantity(value, dozen.end);
    }

    final units = RegExp(r'(\d+(?:[.,]\d+)?)').firstMatch(message);
    if (units != null) {
      final value = double.tryParse(units.group(1)!.replaceAll(',', '.'));
      if (value != null && value > 0) return _ParsedQuantity(value, units.end);
    }
    return null;
  }

  double? _extractCost(String message) {
    final patterns = [
      RegExp(r'(?:a|en|costo|costaron|compre|compré)\s+(\d+(?:[.,]\d+)?)'),
      RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:cordobas|córdobas|pesos|usd)'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return double.tryParse(match.group(1)!.replaceAll(',', '.'));
      }
    }
    return null;
  }

  double? _extractPrice(String message) {
    final match = RegExp(
      r'(?:para\s+(?:darlos|venderlos|vender|dar)\s+a|precio\s+venta|vender\s+a)\s+(\d+(?:[.,]\d+)?)',
    ).firstMatch(message);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }

  String _formatAddedItems(
    List<AssistantEntryDraftLine> added,
    AssistantEntrySessionDraft draft,
  ) {
    final addedText = added
        .map((line) {
          final status = line.isReady
              ? 'listo'
              : 'pendiente: ${_pendingReason(line)}';
          final marker = line.isNewProduct
              ? 'producto nuevo'
              : 'producto existente';
          return '- ${line.displayName} x${_qty(line.quantity)} ($marker, categoria: ${line.categoryName ?? 'pendiente'}, $status)';
        })
        .join('\n');
    return 'Agregue al borrador:\n$addedText\n\n${_formatDraftFooter(draft)}';
  }

  String _formatDraft(AssistantEntrySessionDraft draft) {
    if (draft.isEmpty) return 'El borrador de entrada esta vacio.';
    final lines = draft.lines
        .map((line) {
          final cost = line.unitCost == null
              ? 'costo pendiente'
              : 'costo C\$${line.unitCost!.toStringAsFixed(2)}';
          final price = line.unitPrice == null
              ? 'precio pendiente'
              : 'precio C\$${line.unitPrice!.toStringAsFixed(2)}';
          final category = line.categoryName ?? 'categoria pendiente';
          final type = line.isNewProduct ? 'nuevo' : 'existente';
          return '- ${line.displayName} x${_qty(line.quantity)} ($type, $category, $cost, $price)';
        })
        .join('\n');
    return 'Borrador de entrada:\n$lines\n\n${_formatDraftFooter(draft)}';
  }

  String _formatDraftFooter(AssistantEntrySessionDraft draft) {
    if (draft.hasBlockingIssues) {
      return 'Pendientes:\n${_formatPending(draft)}';
    }
    return 'Decime "confirmar entrada" para guardar o "cancelar entrada" para descartarla.';
  }

  String _formatPending(AssistantEntrySessionDraft draft) {
    return draft.lines
        .where((line) => !line.isReady)
        .map((line) {
          if (line.candidates.isNotEmpty) {
            return '- ${line.proposedName}: elegir producto (${line.candidates.join(', ')}) o crear nuevo.';
          }
          return '- ${line.displayName}: ${_pendingReason(line)}.';
        })
        .join('\n');
  }

  String _pendingReason(AssistantEntryDraftLine line) {
    if (line.status == 'needs_product_selection') return 'elegir producto';
    if (line.status == 'needs_category') return 'falta categoria';
    if (line.status == 'needs_cost') return 'falta costo';
    if (line.status == 'needs_price') return 'falta precio de venta';
    return 'requiere revision';
  }

  String? _extractCategoryName(String message) {
    final match = RegExp(
      r'(?:categoria|categoría)\s+(?:a|por|como)?\s*([a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+)$',
      caseSensitive: false,
    ).firstMatch(message);
    return match?.group(1)?.trim();
  }

  bool _canCreateEntry(AssistantOperationalContext context) {
    return context.hasPermission(PermissionCode.warehouseUpdate) ||
        context.hasPermission(PermissionCode.productCreate);
  }

  bool _looksLikeEntryStart(String message) {
    return RegExp(
      r'\b(entrar|entro|entró|entraron|ingresaron|entrada|compre|compré|compra|llego|llegó|recibi|recibí|tambien|también)\b',
      caseSensitive: false,
    ).hasMatch(message);
  }

  bool _isShowDraft(String value) =>
      value.contains('que llevo') ||
      value.contains('qué llevo') ||
      value.contains('ver borrador') ||
      value.contains('muestra');

  bool _isConfirm(String value) =>
      value == 'confirmar' ||
      value == 'listo' ||
      value.contains('confirmar entrada') ||
      value.contains('guardar entrada');

  bool _isCancel(String value) =>
      value.contains('cancelar') ||
      value.contains('descartar') ||
      value.contains('olvida');

  bool _isCategoryChange(String value) =>
      value.contains('categoria') || value.contains('categoría');

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _qty(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();
}

class _ParsedQuantity {
  final double value;
  final int endIndex;

  const _ParsedQuantity(this.value, this.endIndex);
}

class _ParsedEntryItem {
  final String productName;
  final double quantity;
  final double? unitCost;
  final double? unitPrice;

  const _ParsedEntryItem({
    required this.productName,
    required this.quantity,
    required this.unitCost,
    required this.unitPrice,
  });
}
