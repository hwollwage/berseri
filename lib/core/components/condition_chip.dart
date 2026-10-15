import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:flutter/material.dart';

class ConditionChip extends StatelessWidget {
  const ConditionChip({super.key, required this.label, this.onPage = false});

  final String label;

  final bool onPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: onPage ? scheme.surfaceContainerLowest : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),

        border: onPage
            ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6))
            : null,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
