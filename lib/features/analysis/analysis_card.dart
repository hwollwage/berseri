import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:flutter/material.dart';

/// Compact summary of a single analysis: skin type, date and conditions.
class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key, required this.record});

  final AnalysisRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skin type', style: _caption(theme)),
                    const SizedBox(height: 4),
                    Text(
                      record.skinTypeLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                record.formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          if (record.conditions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Visible conditions', style: _caption(theme)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final condition in record.conditions)
                  _ConditionChip(label: condition),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

TextStyle? _caption(ThemeData theme) => theme.textTheme.labelSmall?.copyWith(
  color: theme.colorScheme.onSurfaceVariant,
  letterSpacing: 0.7,
  fontWeight: FontWeight.w600,
);

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
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
