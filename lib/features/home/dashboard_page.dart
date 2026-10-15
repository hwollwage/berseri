import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/condition_chip.dart';
import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/core/components/text_link.dart';
import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
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
    final latest = ref.watch(latestAnalysisProvider);

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
                _Header(name: profile?.name),
                const SizedBox(height: 26),
                _Greeting(name: profile?.name),
                const SizedBox(height: 24),
                _ScanCard(onStart: onStartAnalysis),
                const SizedBox(height: 16),
                _LatestScanCard(record: latest),
                const SizedBox(height: 16),
                _LibraryCard(onOpen: onOpenIngredients),
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

class _Header extends StatelessWidget {
  const _Header({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const BrandWordmark(),
        Semantics(
          button: true,
          label: 'Open profile',
          child: ExcludeSemantics(
            child: Material(
              color: scheme.surfaceContainerLowest,
              shape: CircleBorder(
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push('/profile'),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Text(
                      _initials(name),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _initials(String? name) {
  final words = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.isEmpty) return 'B';

  return words.take(2).map((word) => word[0].toUpperCase()).join();
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

class _LatestScanCard extends StatelessWidget {
  const _LatestScanCard({required this.record});

  final AnalysisRecord? record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scan = record;

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
                    if (scan != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        scan.formattedDate,
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

          if (scan == null) ...[
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
          ] else ...[
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
              Text(
                'Visible conditions',
                style: BrandText.fieldLabel(context),
              ),
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
                  extra: AnalysisResult.fromRecord(scan),
                ),
                child: const Text('See detail result'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
                itemCount: ingredientLibrary.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) =>
                    _IngredientPreview(ingredient: ingredientLibrary[index]),
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
