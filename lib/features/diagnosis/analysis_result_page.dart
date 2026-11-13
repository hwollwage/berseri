import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/condition_chip.dart';
import 'package:berseri/features/analysis/analysis_entry.dart';
import 'package:berseri/features/diagnosis/widgets/skin_photo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalysisResultPage extends StatelessWidget {
  const AnalysisResultPage({super.key, required this.entry});

  final AnalysisEntry? entry;

  @override
  Widget build(BuildContext context) {
    final loaded = entry;
    if (loaded == null) {
      return const _Unavailable(
        title: 'Result not available',
        body: 'Open an analysis from your history to see its result.',
      );
    }
    return _ResultView(entry: loaded);
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.gutter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(
                onTap: () => context.canPop() ? context.pop() : context.go('/'),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.entry});

  final AnalysisEntry entry;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. `Oct 7, 2026` — the same format the history list uses.
  String get _dateText {
    final date = entry.record.date;
    return '${_months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final record = entry.record;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(
                onTap: () => context.canPop() ? context.pop() : context.go('/'),
              ),

              const SizedBox(height: 24),

              // ── Skin type & scan date ───────────────────────────────────
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
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _dateText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _PhotoCard(url: entry.photoUrl),
              const SizedBox(height: 28),

              Text('Visible conditions', style: BrandText.title(context)),
              const SizedBox(height: 10),
              if (record.conditions.isEmpty)
                Text(
                  'Nothing detected.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final condition in record.conditions)
                      ConditionChip(label: condition, onPage: true),
                  ],
                ),

              const SizedBox(height: 28),

              Text('Recommended ingredients', style: BrandText.title(context)),
              const SizedBox(height: 10),
              if (entry.ingredients.isEmpty)
                Text(
                  'Nothing matched yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                for (final ingredient in entry.ingredients)
                  _IngredientCard(ingredient: ingredient),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.url});
  final String? url;
  static const double _aspectRatio = 3 / 4;
  static const double _maxHeight = 480;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: Material(
          color: scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: SkinPhoto(url: url),
          ),
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ingredient});

  final IngredientSummary ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  ingredient.name.isNotEmpty
                      ? ingredient.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ingredient.summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
