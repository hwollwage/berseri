import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

TextStyle _accentTitle(BuildContext context) =>
    BrandText.title(context).copyWith(color: BrandText.accent(context));

class IngredientDetailPage extends StatelessWidget {
  const IngredientDetailPage({
    super.key,
    required this.ingredient,
  });

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBackButton(),

                    const SizedBox(height: 24),

                    Text(
                      ingredient.category.label,
                      style: _accentTitle(context),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ingredient.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 20),
                    _AttributeTable(ingredient: ingredient),

                    const SizedBox(height: 28),

                    Text(
                      'What It Does',
                      style: _accentTitle(context),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      ingredient.whatItDoes ?? ingredient.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (ingredient.pairsWellWith.isNotEmpty) ...[
                      Text(
                        'Pairs Well With',
                        style: _accentTitle(context),
                      ),
                      const SizedBox(height: 12),
                      for (final pairing in ingredient.pairsWellWith)
                        _PairingCard(pairing: pairing),
                    ],
                  ],
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomNavBar(
                selectedIndex: 2,
                onDestinationSelected: (index) {
                  if (index == 0) {
                    context.go('/');
                  } else if (index == 1) {
                    context.push('/camera');
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributeTable extends StatelessWidget {
  const _AttributeTable({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bestFor = ingredient.bestFor ??
        (ingredient.goodFor.isNotEmpty ? ingredient.goodFor.join(', ') : 'All skin types');
    final helpsWith = ingredient.helpsWith ?? ingredient.category.label;
    final useTime = ingredient.useTime ?? 'Morning and night';

    return Column(
      children: [
        _buildDivider(scheme),
        _AttributeRow(label: 'Best for', value: bestFor),
        _buildDivider(scheme),
        _AttributeRow(label: 'Helps with', value: helpsWith),
        _buildDivider(scheme),
        _AttributeRow(label: 'Use', value: useTime),
        _buildDivider(scheme),
      ],
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Divider(
      height: 1,
      thickness: 1,
      color: scheme.outlineVariant.withValues(alpha: 0.6),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PairingCard extends StatelessWidget {
  const _PairingCard({required this.pairing});

  final IngredientPairing pairing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () {
            final target = ingredientLibrary.firstWhere(
              (item) => item.name.toLowerCase() == pairing.name.toLowerCase(),
              orElse: () => Ingredient(
                name: pairing.name,
                category: IngredientCategory.brightening,
                summary: pairing.reason,
                goodFor: const [],
                note: '',
              ),
            );

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => IngredientDetailPage(ingredient: target),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                      pairing.name.isNotEmpty ? pairing.name[0].toUpperCase() : '?',
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
                        pairing.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pairing.reason,
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
        ),
      ),
    );
  }
}
