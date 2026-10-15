import 'package:berseri/features/onboarding/presentation/onboarding_slides.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_copy.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_progress.dart';
import 'package:flutter/material.dart';

class OnboardingSheet extends StatelessWidget {
  const OnboardingSheet({
    super.key,
    required this.slide,
    required this.index,
    required this.count,
    required this.isLast,
    required this.onNext,
    required this.onStart,
  });

  final OnboardingSlide slide;
  final int index;
  final int count;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onStart;

  static const double _copySlot = 130;

  static const Duration _swapDuration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final swap = MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : _swapDuration;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _copySlot),
            child: AnimatedSwitcher(
              duration: swap,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topLeft,
                children: [...previous, ?current],
              ),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: OnboardingCopy(key: ValueKey(index), slide: slide),
            ),
          ),

          const SizedBox(height: 16),

          Semantics(
            label: 'Step ${index + 1} of $count',
            child: OnboardingProgress(index: index, count: count),
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: swap,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: SizedBox(
              key: ValueKey(isLast),
              width: double.infinity,
              child: FilledButton(
                onPressed: isLast ? onStart : onNext,
                child: Text(isLast ? 'Get started' : 'Next'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
