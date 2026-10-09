import 'package:berseri/features/analysis/analysis_card.dart';
import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full detail of the latest analysis plus rule-based ingredient suggestions.
class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final record = ref.watch(latestAnalysisProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(title: const Text('Analysis Result')),
      body: record == null
          ? Center(
              child: Text(
                'No analysis to show yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                AnalysisCard(record: record),
                const SizedBox(height: 28),
                Text(
                  'Suggested ingredients',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'General reference based on your skin type and detected '
                  'conditions, not medical advice.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                if (matchesFor(record).isEmpty)
                  Text(
                    'Nothing matched yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else
                  for (final ingredient in matchesFor(record))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _IngredientRow(ingredient: ingredient),
                    ),
              ],
            ),
    );
  }
}

/// Ingredients whose targets cover the record's skin type or conditions.
List<Ingredient> matchesFor(AnalysisRecord record) {
  final tags = <String>{
    record.skinTypeLabel.toLowerCase(),
    for (final condition in record.conditions) condition.toLowerCase(),
  };

  return ingredientLibrary
      .where(
        (ingredient) => ingredient.goodFor.any(
          (target) => tags.contains(target.toLowerCase()),
        ),
      )
      .toList(growable: false);
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ingredient.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ingredient.summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
