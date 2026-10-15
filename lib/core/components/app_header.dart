import 'package:berseri/core/components/brand.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App-level top bar: the BERSERI wordmark on the left, and a circular
/// initial-based avatar that opens the profile on the right.
///
/// Shared by every screen that shows the app chrome (dashboard, ingredient
/// library) so the bar looks identical wherever it appears.
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = ref.watch(userProfileProvider)?.name;

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
