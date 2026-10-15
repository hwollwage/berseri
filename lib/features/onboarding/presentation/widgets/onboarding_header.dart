import 'package:berseri/core/components/brand.dart';
import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.showSkip,
    required this.onSkip,
  });

  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 12, 0),
      child: Row(
        children: [
          const BrandWordmark(),
          const Spacer(),
          AnimatedOpacity(
            opacity: showSkip ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !showSkip,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurface.withValues(alpha: 0.72),
                ),
                child: const Text('Skip'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
