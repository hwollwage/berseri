import 'package:flutter/material.dart';

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({
    super.key,
    required this.index,
    required this.count,
  });

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < count; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              height: 4,
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: i <= index
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
      ],
    );
  }
}
