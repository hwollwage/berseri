import 'package:berseri/core/components/app_header.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/condition_chip.dart';
import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/core/components/text_link.dart';
import 'package:berseri/features/analysis/analysis_entry.dart';
import 'package:berseri/features/analysis/analysis_repository.dart';
import 'package:berseri/features/clinics/nearby_clinics_card.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:berseri/features/ingredients/ingredient_repository.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.onStartAnalysis,
    required this.onOpenIngredients,
  });

  final VoidCallback onStartAnalysis;

  final VoidCallback onOpenIngredients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.xl,
                AppSpacing.gutter,
                AppSpacing.navBarInset,
              ),
              children: [
                const AppHeader(),
                const SizedBox(height: 26),
                _Greeting(name: profile?.name),
                const SizedBox(height: 24),
                _ScanCard(onStart: onStartAnalysis),
                const SizedBox(height: 16),
                _LatestScanCard(),
                const SizedBox(height: 16),
                _LibraryCard(onOpen: onOpenIngredients),
                const SizedBox(height: 16),
                NearbyClinicsCard(
                  onSeeAll: () => context.push('/clinics'),
                  onClinicTap: (_) => context.push('/clinics'),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavBar(
                selectedIndex: 0,
                onDestinationSelected: (index) {
                  if (index == 1) onStartAnalysis();
                  if (index == 2) onOpenIngredients();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim() ?? '';
    final salutation = greetingFor(DateTime.now());

    return Semantics(
      header: true,
      child: Text(
        trimmed.isEmpty ? salutation : '$salutation, $trimmed',
        style: BrandText.headline(context),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SKIN SCAN', style: BrandText.eyebrow(context)),
          const SizedBox(height: 10),
          Text(
            'Analyze your skin',
            style: BrandText.headline(context, fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            "Take a quick photo and we'll map your skin type and the "
            'conditions that show.',
            style: BrandText.body(context),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              child: const Text('Start Analysis'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestScanCard extends ConsumerWidget {
  const _LatestScanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final latest = ref.watch(latestAnalysisEntryProvider);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last analysis',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (latest.value case final entry?) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.record.formattedDate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextLink(label: 'History', onTap: () => context.push('/history')),
            ],
          ),
          const SizedBox(height: 18),

          switch (latest) {
            AsyncData(:final value) => _LatestScanBody(entry: value),
            AsyncError() => _LatestScanError(
              onRetry: () => ref.invalidate(latestAnalysisEntryProvider),
            ),
            _ => const _LatestScanLoading(),
          },
        ],
      ),
    );
  }
}

class _LatestScanBody extends StatelessWidget {
  const _LatestScanBody({required this.entry});

  final AnalysisEntry? entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scan = entry?.record;

    if (scan == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No analysis yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your skin type and the conditions we find show up here after '
            'your first scan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skin type', style: BrandText.fieldLabel(context)),
        const SizedBox(height: 4),
        Text(
          scan.skinTypeLabel,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),

        if (scan.conditions.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Visible conditions', style: BrandText.fieldLabel(context)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final condition in scan.conditions)
                ConditionChip(label: condition),
            ],
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => context.push(
              '/analysis-result',
              extra: entry,
            ),
            child: const Text('See detail result'),
          ),
        ),
      ],
    );
  }
}

class _LatestScanLoading extends StatelessWidget {
  const _LatestScanLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('Loading your last analysis…')),
        ],
      ),
    );
  }
}

class _LatestScanError extends StatelessWidget {
  const _LatestScanError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "We couldn't load your last analysis.",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Check your connection and try again.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class _LibraryCard extends ConsumerWidget {
  const _LibraryCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ingredientsAsync = ref.watch(ingredientsProvider);
    final ingredients = ingredientsAsync.value;
    final items = (ingredients != null && ingredients.isNotEmpty)
        ? ingredients
        : ingredientLibrary;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
                AppSpacing.cardPadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Ingredient library',
                          style: BrandText.title(context),
                        ),
                      ),
                      TextLink(label: 'Browse', onTap: onOpen),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'What each ingredient does, and which skin types it suits.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              height: _IngredientPreview.tileHeight(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    _IngredientPreview(ingredient: items[index]),
              ),
            ),

            const SizedBox(height: AppSpacing.cardPadding),
          ],
        ),
      ),
    );
  }
}

class _IngredientPreview extends StatelessWidget {
  const _IngredientPreview({required this.ingredient});

  final Ingredient ingredient;
  static const double _width = 140;
  static const int _nameLines = 2;
  static const EdgeInsets _padding = EdgeInsets.all(AppSpacing.md);

  static TextStyle _labelStyle(BuildContext context) =>
      (Theme.of(context).textTheme.labelSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
      );

  static TextStyle _nameStyle(BuildContext context) =>
      (Theme.of(context).textTheme.titleSmall ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w700,
      );

  static double _lineHeight(BuildContext context, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: 'X', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  static double tileHeight(BuildContext context) =>
      _padding.vertical +
      _lineHeight(context, _labelStyle(context)) +
      AppSpacing.xs +
      _lineHeight(context, _nameStyle(context)) * _nameLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: _width,
      child: Material(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.control),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => IngredientDetailPage(ingredient: ingredient),
            ),
          ),
          child: Padding(
            padding: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ingredient.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _labelStyle(context).copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ingredient.name,
                  maxLines: _nameLines,
                  overflow: TextOverflow.ellipsis,
                  style: _nameStyle(context).copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}