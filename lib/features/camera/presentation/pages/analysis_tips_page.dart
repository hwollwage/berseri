import 'package:berseri/core/components/app_back_button.dart';
import 'package:berseri/core/components/app_spacing.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:flutter/material.dart';

class AnalysisTipsPage extends StatelessWidget {
  const AnalysisTipsPage({super.key, required this.onReady});

  final VoidCallback onReady;

  static const List<({String title, String description})> _tips = [
    (
      title: 'Use good lighting',
      description:
          'Take the photo in a bright, evenly lit place. Avoid very dark or '
          'harsh lighting.',
    ),
    (
      title: 'Take the photo without makeup',
      description:
          'Avoid makeup or skincare products that may cover your skin, so '
          'your skin can be captured clearly.',
    ),
    (
      title: 'Keep your face clear',
      description:
          'Remove anything covering your face, such as masks, glasses, or '
          'hair.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),

              const SizedBox(height: AppSpacing.xxxl),

              // ── Kicker ──────────────────────────────────────────────────
              Text(
                'Before You Start',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BrandText.accent(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Headline ────────────────────────────────────────────────
              Text(
                'Get The Most\nAccurate Result',
                style: BrandText.headline(context, fontSize: 32),
              ),
              const SizedBox(height: 36),

              const Divider(),

              // ── Tips ────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final (index, tip) in _tips.indexed) ...[
                        _TipItem(
                          number: '${index + 1}',
                          title: tip.title,
                          description: tip.description,
                        ),
                        const Divider(),
                      ],
                    ],
                  ),
                ),
              ),

              // ── "I'm Ready" ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.sm,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onReady,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("I'm Ready"),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(Icons.chevron_right, size: 22),
                      ],
                    ),
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

/// One numbered tip: the index, what to do, and why.
class _TipItem extends StatelessWidget {
  const _TipItem({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number.', style: BrandText.title(context)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BrandText.title(context)),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
