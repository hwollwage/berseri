import 'dart:math' as math;

import 'package:berseri/core/components/brand.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_art.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  /// Existing users land here from "Skip".
  static const String signInRoute = '/auth/login';

  /// New users land here from "Get started".
  static const String signUpRoute = '/auth/register';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  static const List<_SlideData> _slides = [
    _SlideData(
      eyebrow: 'Welcome',
      title: 'Get to know your skin.',
      body: 'A little insight into what your skin needs.',
      art: WelcomeArt(),
    ),
    _SlideData(
      eyebrow: 'Skin analysis',
      title: 'It starts with a selfie.',
      body: 'A closer look at your skin type and visible concerns.',
      art: ScanArt(),
    ),
    _SlideData(
      eyebrow: 'Questionnaire',
      title: 'Tell us a little more.',
      body: 'A few quick questions to complete your skin profile.',
      art: QuestionnaireArt(),
    ),
    _SlideData(
      eyebrow: 'Ingredients',
      title: 'Know your ingredients.',
      body: 'Learn which ingredients may work for your skin.',
      art: IngredientsArt(),
    ),
  ];

  static const Duration _slideDuration = Duration(milliseconds: 340);
  static const Duration _entranceDuration = Duration(milliseconds: 620);

  final PageController _controller = PageController();
  late final AnimationController _entrance;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  int _index = 0;

  bool get _isLastSlide => _index == _slides.length - 1;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(vsync: this, duration: _entranceDuration);
    _entranceFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOut),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Respect "reduce motion": show the settled state, no animation.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _entrance.value = 1.0;
    } else if (!_entrance.isAnimating && _entrance.value == 0.0) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openSignIn() => context.go(OnboardingPage.signInRoute);

  void _openSignUp() => context.go(OnboardingPage.signUpRoute);

  Future<void> _next() => _controller.nextPage(
    duration: _slideDuration,
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Barely-there warmth at the top so the cream is not a flat fill.
          // The artwork carries its own halo, so the page stays clean behind
          // it instead of doubling up into a muddy wash.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.85),
                  radius: 1.1,
                  colors: [
                    cs.primary.withValues(alpha: isDark ? 0.16 : 0.11),
                    cs.surface.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _entranceFade,
              child: SlideTransition(
                position: _entranceSlide,
                child: Column(
                  children: [
                    _Header(showSkip: !_isLastSlide, onSkip: _openSignIn),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _slides.length,
                        onPageChanged: (index) =>
                            setState(() => _index = index),
                        itemBuilder: (context, index) => _ArtSlide(
                          controller: _controller,
                          index: index,
                          art: _slides[index].art,
                        ),
                      ),
                    ),
                    _Sheet(
                      slide: _slides[_index],
                      index: _index,
                      count: _slides.length,
                      isLast: _isLastSlide,
                      onNext: _next,
                      onStart: _openSignUp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One slide's copy and the artwork that illustrates it.
class _SlideData {
  const _SlideData({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.art,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget art;
}

class _Header extends StatelessWidget {
  const _Header({required this.showSkip, required this.onSkip});

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
                  // The hero wash sits behind this row, so "Skip" needs to
                  // hold its own weight against a warm background.
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

class _ArtSlide extends StatelessWidget {
  const _ArtSlide({
    required this.controller,
    required this.index,
    required this.art,
  });

  final PageController controller;
  final int index;
  final Widget art;

  double get _offset {
    if (!controller.hasClients) return 0;
    final page = controller.page;
    if (page == null) return 0;
    return (page - index).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fit = math.min(
            constraints.maxHeight / 320,
            constraints.maxWidth / 300,
          );
          final scale = math.min(fit, 1.45);
          return Center(
            child: SizedBox(
              width: 300 * scale,
              height: 320 * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(width: 300, height: 320, child: art),
              ),
            ),
          );
        },
      ),
    );

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return content;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = _offset;
        return Opacity(
          opacity: (1 - offset.abs() * 0.55).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 26 * offset),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.slide,
    required this.index,
    required this.count,
    required this.isLast,
    required this.onNext,
    required this.onStart,
  });

  final _SlideData slide;
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
              child: _Copy(key: ValueKey(index), slide: slide),
            ),
          ),

          const SizedBox(height: 16),

          Semantics(
            label: 'Step ${index + 1} of $count',
            child: _Progress(index: index, count: count),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isLast ? 'Get started' : 'Next'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({super.key, required this.slide});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(slide.eyebrow.toUpperCase(), style: BrandText.eyebrow(context)),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            slide.title,
            style: BrandText.headline(context, fontSize: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(slide.body, style: BrandText.body(context)),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.index, required this.count});

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
