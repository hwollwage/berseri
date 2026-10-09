import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Detailed view of a skincare ingredient: key benefits, usage, what it does,
/// and synergistic pairings with other ingredients.
class IngredientDetailPage extends StatelessWidget {
  const IngredientDetailPage({
    super.key,
    required this.ingredient,
  });

  final Ingredient ingredient;

  static const Color _amberAccent = Color(0xFFB45309);

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
                    // Circular back button
                    Material(
                      color: scheme.surfaceContainerLowest,
                      shape: const CircleBorder(),
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: 0.06),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Category label
                    Text(
                      ingredient.category.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _amberAccent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Ingredient title
                    Text(
                      ingredient.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Key attributes table with dividers
                    _AttributeTable(ingredient: ingredient),

                    const SizedBox(height: 28),

                    // What It Does section
                    Text(
                      'What It Does',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _amberAccent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      ingredient.whatItDoes ?? ingredient.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.9),
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Pairs Well With section
                    if (ingredient.pairsWellWith.isNotEmpty) ...[
                      Text(
                        'Pairs Well With',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _amberAccent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final pairing in ingredient.pairsWellWith)
                        _PairingCard(pairing: pairing),
                    ],
                  ],
                ),
              ),
            ),

            // Floating Custom Bottom Nav Bar
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
                    // Already on ingredients detail, pop back to ingredients list
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
      color: scheme.outlineVariant.withValues(alpha: 0.5),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
