import 'package:berseri/core/components/custom_nav_bar.dart';
import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Landing screen: brand greeting, the primary scan CTA card, and the
/// latest analysis summary card matching the refreshed aesthetic design.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    super.key,
    required this.onStartAnalysis,
    required this.onOpenIngredients,
  });

  /// Switches the shell to the Analyze tab.
  final VoidCallback onStartAnalysis;

  /// Switches the shell to the Ingredients tab.
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
              children: [
                _Greeting(name: profile?.name),
                const SizedBox(height: 22),
                _AnalyzeCard(onStart: onStartAnalysis),
                const SizedBox(height: 16),
                _LastAnalysisCard(
                  record: latest,
                  onStartAnalysis: onStartAnalysis,
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

// ─────────────────────────────────────────────────────────────
// Greeting row
// ─────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final displayName =
        (name != null && name!.trim().isNotEmpty) ? name!.trim() : 'Jane';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berseri',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
                children: [
                  TextSpan(
                    text: 'Hi, ',
                    style: TextStyle(color: scheme.onSurface),
                  ),
                  TextSpan(
                    text: displayName,
                    style: TextStyle(color: scheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.push('/profile'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.outlineVariant,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 26,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Analyze CTA card
// ─────────────────────────────────────────────────────────────

class _AnalyzeCard extends StatelessWidget {
  const _AnalyzeCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative circles – top-right corner
          Positioned(
            top: -28,
            right: -18,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A)
                    .withValues(alpha: isDark ? 0.15 : 0.75),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 24,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: isDark ? 0.45 : 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title – constrained so the decorative circles don't overlap
                Padding(
                  padding: const EdgeInsets.only(right: 80),
                  child: Text(
                    'Analyze Your Skin',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: Text(
                    'Take a quick photo to discover what your skin needs today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                _PillButton(
                  label: 'Start Analysis',
                  onTap: onStart,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Last-analysis summary card
// ─────────────────────────────────────────────────────────────

class _LastAnalysisCard extends StatelessWidget {
  const _LastAnalysisCard({
    required this.record,
    required this.onStartAnalysis,
  });

  final AnalysisRecord? record;
  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Analysis',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record != null
                        ? record!.formattedDate.toLowerCase()
                        : 'not analyzed yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/history'),
                child: Text(
                  'History',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),

          if (record != null) ...[
            const SizedBox(height: 20),

            // ── Skin type ────────────────────────────────────
            Text(
              'Skin Type',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              record!.skinTypeLabel,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: scheme.onSurface,
              ),
            ),

            if (record!.conditions.isNotEmpty) ...[
              const SizedBox(height: 16),

              // ── Visible conditions ────────────────────────
              Text(
                'Visible Conditions',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final condition in record!.conditions)
                    _ConditionChip(label: condition),
                ],
              ),
            ],

            const SizedBox(height: 22),

            // ── CTA button ────────────────────────────────────
            _PillButton(
              label: 'See Detail Result',
              onTap: () => context.push('/result'),
              color: scheme.primary,
              fullWidth: true,
            ),
          ] else ...[
            const SizedBox(height: 20),
            Text(
              'No analysis yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your skin type and conditions will show up here after your first scan.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            _PillButton(
              label: 'Scan Now',
              onTap: onStartAnalysis,
              color: scheme.primary,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────────

/// Amber pill button used in both cards.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final child = Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 0 : 20,
            vertical: 13,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}

/// Rounded pill chip for a skin condition label.
class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF352C1F)
            : const Color(0xFFFBEFD9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: isDark
              ? const Color(0xFFFFE7B8)
              : const Color(0xFF292524),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
