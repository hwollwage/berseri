import 'package:flutter/material.dart';

class BerseriLogo extends StatelessWidget {
  final VoidCallback? onIconTap;
  final IconData icon;

  const BerseriLogo({super.key, this.onIconTap, this.icon = Icons.light_mode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: .min,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onIconTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: Icon(icon, size: 20, color: cs.onPrimaryContainer),
          ),
        ),

        const SizedBox(width: 10),

        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            children: [
              const TextSpan(text: 'Ber'),
              TextSpan(
                text: 'seri',
                style: TextStyle(color: cs.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
