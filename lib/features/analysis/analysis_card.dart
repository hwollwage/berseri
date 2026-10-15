import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/condition_chip.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(AppRadius.card),
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
                    Text('Skin type', style: BrandText.fieldLabel(context)),
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
            Text('Visible conditions', style: BrandText.fieldLabel(context)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final condition in record.conditions)
                  ConditionChip(label: condition),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
