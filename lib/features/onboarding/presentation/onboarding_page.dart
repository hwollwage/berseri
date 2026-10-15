import 'package:berseri/features/onboarding/presentation/onboarding_slides.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_art_slide.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_header.dart';
import 'package:berseri/features/onboarding/presentation/widgets/onboarding_sheet.dart';
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
  static const Duration _slideDuration = Duration(milliseconds: 340);
  static const Duration _entranceDuration = Duration(milliseconds: 620);

  final PageController _controller = PageController();
  late final AnimationController _entrance;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  int _index = 0;

  bool get _isLastSlide => _index == onboardingSlides.length - 1;

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
                    OnboardingHeader(
                      showSkip: !_isLastSlide,
                      onSkip: _openSignIn,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: onboardingSlides.length,
                        onPageChanged: (index) =>
                            setState(() => _index = index),
                        itemBuilder: (context, index) => OnboardingArtSlide(
                          controller: _controller,
                          index: index,
                          art: onboardingSlides[index].art,
                        ),
                      ),
                    ),
                    OnboardingSheet(
                      slide: onboardingSlides[_index],
                      index: _index,
                      count: onboardingSlides.length,
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
