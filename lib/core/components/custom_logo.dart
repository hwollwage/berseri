import 'package:flutter/material.dart';

class BerseriLogo extends StatelessWidget {
  const BerseriLogo({super.key, this.icon = Icons.light_mode});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primaryContainer,
          ),
          child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
        ),

        const SizedBox(width: 10),

        Text.rich(
          TextSpan(
            style: (theme.textTheme.titleLarge ?? const TextStyle()).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'Ber'),
              TextSpan(text: 'seri', style: TextStyle(color: scheme.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
