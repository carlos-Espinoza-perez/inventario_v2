import 'package:flutter/material.dart';

class ClarificationOptionsRow extends StatelessWidget {
  final List<String> options;
  final void Function(String) onSelected;

  const ClarificationOptionsRow({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(
              options[i],
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            backgroundColor: colorScheme.secondaryContainer,
            side: BorderSide.none,
            onPressed: () => onSelected(options[i]),
          );
        },
      ),
    );
  }
}
