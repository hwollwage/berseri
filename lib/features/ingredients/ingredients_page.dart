import 'package:berseri/core/components/app_header.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:berseri/features/ingredients/ingredient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientsPage extends ConsumerStatefulWidget {
  const IngredientsPage({super.key});

  @override
  ConsumerState<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends ConsumerState<IngredientsPage> {
  final TextEditingController _searchController = TextEditingController();

  IngredientCategory? _category;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(IngredientCategory? category) {
    if (category == _category) return;
    setState(() => _category = category);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: const AppHeader(),
            ),

            const SizedBox(height: 26),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Ingredients',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Search ingredients',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _category == null,
                    onTap: () => _selectCategory(null),
                  ),
                  for (final category in IngredientCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: category.label,
                        selected: _category == category,
                        onTap: () => _selectCategory(category),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: ingredientsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _ErrorState(
                  message: 'Failed to load ingredients',
                  onRetry: () => ref.invalidate(ingredientsProvider),
                ),
                data: (ingredients) {
                  final source = ingredients.isNotEmpty
                      ? ingredients
                      : ingredientLibrary;
                  final results = filterIngredients(
                    ingredients: source,
                    category: _category,
                    query: _query,
                  );

                  if (results.isEmpty) {
                    return _EmptyResults(query: _query);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(ingredientsProvider);
                      await ref.read(ingredientsProvider.future);
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: _IngredientCard.gridExtent(context),
                          ),
                      itemCount: results.length,
                      itemBuilder: (context, index) => _IngredientCard(
                        ingredient: results[index],
                        onTap: () => _openDetail(context, results[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Ingredient ingredient) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => IngredientDetailPage(ingredient: ingredient),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerLowest,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? scheme.primary : scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.ingredient, required this.onTap});

  static const double _labelFontSize = 11;
  static const double _labelHeight = 1.45;

  static const double _nameFontSize = 19;
  static const double _nameHeight = 1.15;

  static const int _nameLines = 2;

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(14, 12, 12, 14);

  static const double _labelGap = 8;
  static const double _badgeSize = 32;

  static TextStyle labelStyle(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
      fontSize: _labelFontSize,
      height: _labelHeight,
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    );
  }

  static TextStyle nameStyle(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
      fontSize: _nameFontSize,
      fontWeight: FontWeight.w700,
      height: _nameHeight,
      letterSpacing: -0.4,
    );
  }

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

  static double _nameBlockHeight(BuildContext context) =>
      _lineHeight(context, nameStyle(context)) * _nameLines;

  static double gridExtent(BuildContext context) =>
      _padding.vertical +
      _badgeSize +
      _labelGap +
      _nameBlockHeight(context);

  final Ingredient ingredient;
  final VoidCallback onTap;

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
        onTap: onTap,
        child: Padding(
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      ingredient.category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: _badgeSize,
                    width: _badgeSize,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ingredient.category.icon,
                      size: 16,
                      color: scheme.onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _labelGap),
              Text(
                ingredient.name,
                maxLines: _nameLines,
                overflow: TextOverflow.ellipsis,
                style: nameStyle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 32, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              query.isEmpty
                  ? 'No ingredients in this category yet.'
                  : 'No ingredients match "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: scheme.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
