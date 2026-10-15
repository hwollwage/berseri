import 'package:berseri/core/components/app_radius.dart';
import 'package:berseri/core/components/brand.dart';
import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          child: Text(
            label,
            style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: BrandText.accent(context),
            ),
          ),
        ),
      ),
    );
  }
}
