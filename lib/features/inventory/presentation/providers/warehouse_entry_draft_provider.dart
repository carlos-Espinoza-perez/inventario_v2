import 'package:flutter_riverpod/flutter_riverpod.dart';

class WarehouseEntryDraftState {
  final String description;
  final List<Map<String, dynamic>> orderLines;

  WarehouseEntryDraftState({
    this.description = '',
    this.orderLines = const [],
  });

  WarehouseEntryDraftState copyWith({
    String? description,
    List<Map<String, dynamic>>? orderLines,
  }) {
    return WarehouseEntryDraftState(
      description: description ?? this.description,
      orderLines: orderLines ?? this.orderLines,
    );
  }
}

class WarehouseEntryDraftNotifier extends FamilyNotifier<WarehouseEntryDraftState, String> {
  @override
  WarehouseEntryDraftState build(String arg) {
    return WarehouseEntryDraftState();
  }

  void updateDescription(String text) {
    state = state.copyWith(description: text);
  }

  void addOrderLine(Map<String, dynamic> line) {
    state = state.copyWith(orderLines: [...state.orderLines, line]);
  }

  void updateOrderLine(int index, Map<String, dynamic> newLine) {
    final newLines = List<Map<String, dynamic>>.from(state.orderLines);
    newLines[index] = newLine;
    state = state.copyWith(orderLines: newLines);
  }

  void removeOrderLine(int index) {
    final newLines = List<Map<String, dynamic>>.from(state.orderLines);
    newLines.removeAt(index);
    state = state.copyWith(orderLines: newLines);
  }

  void clear() {
    state = WarehouseEntryDraftState();
  }
}

final warehouseEntryDraftProvider = NotifierProvider.family<WarehouseEntryDraftNotifier, WarehouseEntryDraftState, String>(() {
  return WarehouseEntryDraftNotifier();
});
