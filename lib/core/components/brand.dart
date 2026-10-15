import 'package:berseri/core/components/app_colors.dart';
import 'package:flutter/material.dart';

abstract final class BrandText {
  static Color accent(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? theme.colorScheme.primary
        : AppColors.amberDeep;
  }

  static TextStyle wordmark(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 3,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle eyebrow(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.8,
      color: accent(context),
    );
  }

  static TextStyle fieldLabel(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle headline(BuildContext context, {double fontSize = 30}) {
    final theme = Theme.of(context);
    return (theme.textTheme.headlineMedium ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.6,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle title(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.titleMedium ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: theme.colorScheme.onSurface,
    );
  }

  static TextStyle body(BuildContext context) {
    final theme = Theme.of(context);
    return (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.55,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('BERSERI', style: BrandText.wordmark(context));
  }
}
