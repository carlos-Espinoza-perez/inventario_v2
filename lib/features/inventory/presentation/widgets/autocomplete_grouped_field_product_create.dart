import 'package:flutter/material.dart';

class _GroupedOption {
  final String label;
  final bool isHeader;
  final String groupName;

  _GroupedOption({
    required this.label,
    this.isHeader = false,
    this.groupName = '',
  });
}

class OpenAutocompleteGroupedField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Map<String, List<String>> groupedOptions;
  final IconData icon;

  const OpenAutocompleteGroupedField({
    super.key,
    required this.controller,
    required this.label,
    required this.groupedOptions,
    required this.icon,
  });

  @override
  State<OpenAutocompleteGroupedField> createState() =>
      _OpenAutocompleteGroupedFieldState();
}

class _OpenAutocompleteGroupedFieldState
    extends State<OpenAutocompleteGroupedField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Función para quitar acentos (á -> a, ü -> u, etc.)
  /// Nota: Mantenemos la 'ñ' porque en español es una letra distinta,
  /// pero si quisieras ignorarla también, agrégala al string 'withDia'.
  String _removeDiacritics(String str) {
    const withDia = 'áéíóúüÁÉÍÓÚÜ';
    const withoutDia = 'aeiouuAEIOUU';

    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<_GroupedOption>(
          textEditingController: widget.controller,
          focusNode: _focusNode,

          displayStringForOption: (option) => option.label,

          // --- LÓGICA DE FILTRADO ACTUALIZADA ---
          optionsBuilder: (TextEditingValue textEditingValue) {
            // 1. Limpiamos lo que el usuario escribió (Query)
            final rawQuery = textEditingValue.text;
            final query = _removeDiacritics(rawQuery).toLowerCase();

            List<_GroupedOption> flatList = [];

            widget.groupedOptions.forEach((group, items) {
              // 2. Filtramos comparando versiones "limpias"
              final filteredItems = items.where((item) {
                final itemClean = _removeDiacritics(item).toLowerCase();
                return itemClean.contains(query);
              }).toList();

              if (filteredItems.isNotEmpty) {
                // Header
                flatList.add(
                  _GroupedOption(
                    label: group,
                    isHeader: true,
                    groupName: group,
                  ),
                );

                // Items
                for (var item in filteredItems) {
                  flatList.add(
                    _GroupedOption(
                      label: item,
                      isHeader: false,
                      groupName: group,
                    ),
                  );
                }
              }
            });

            return flatList;
          },

          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: Icon(
                  widget.icon,
                  size: 20,
                  color: Colors.grey[500],
                ),
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.cyan.shade800, width: 2),
                ),
              ),
            );
          },

          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);

                      // HEADER
                      if (option.isHeader) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          color: Colors.grey[100],
                          child: Text(
                            option.label.toUpperCase(),
                            style: TextStyle(
                              color: Colors.cyan.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        );
                      }

                      // ITEM
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  option.label,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
