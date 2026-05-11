import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: colorScheme.errorContainer.withValues(alpha: 0.85),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 14,
            color: colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            'Sin conexión — modo básico activo',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
