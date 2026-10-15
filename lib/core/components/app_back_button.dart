import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onTap, this.icon});

  final VoidCallback? onTap;

  /// Defaults to [Icons.arrow_back_ios_new_rounded].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Back',
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
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
              icon ?? Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
