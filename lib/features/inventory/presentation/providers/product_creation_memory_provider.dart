import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCreationMemoryState {
  final String categoryName;
  final String subCategoryName;
  final String brandName;

  ProductCreationMemoryState({
    this.categoryName = '',
    this.subCategoryName = '',
    this.brandName = '',
  });

  ProductCreationMemoryState copyWith({
    String? categoryName,
    String? subCategoryName,
    String? brandName,
  }) {
    return ProductCreationMemoryState(
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      brandName: brandName ?? this.brandName,
    );
  }
}

class ProductCreationMemoryNotifier extends Notifier<ProductCreationMemoryState> {
  @override
  ProductCreationMemoryState build() {
    return ProductCreationMemoryState();
  }

  void saveMemory({
    required String categoryName,
    required String subCategoryName,
    required String brandName,
  }) {
    state = state.copyWith(
      categoryName: categoryName,
      subCategoryName: subCategoryName,
      brandName: brandName,
    );
  }

  void clearMemory() {
    state = ProductCreationMemoryState();
  }
}

final productCreationMemoryProvider =
    NotifierProvider<ProductCreationMemoryNotifier, ProductCreationMemoryState>(
  () => ProductCreationMemoryNotifier(),
);
