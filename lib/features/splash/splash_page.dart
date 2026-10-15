import 'dart:async';

import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/core/components/glow_orb.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const Duration introDuration = Duration(milliseconds: 2200);
  static const Duration holdDuration = Duration(milliseconds: 2600);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _glowFade;
  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _headlineFade;
  late final Animation<Offset> _headlineSlide;
  late final Animation<double> _bodyFade;
  late final Animation<Offset> _bodySlide;
  late final Animation<double> _progress;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: SplashPage.introDuration,
    );

    _glowFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.60, curve: Curves.easeOut),
    );
    _heroFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.55, curve: Curves.easeOut),
    );
    _heroScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _headlineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
    );
    _headlineSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.78, curve: Curves.easeOutCubic),
      ),
    );
    _bodyFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.80, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.00, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1.0;
    } else if (!_controller.isAnimating && _controller.value == 0.0) {
      _controller.forward();
    }

    _navTimer ??= Timer(SplashPage.holdDuration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    context.go('/onboarding');
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient glows, same treatment as the onboarding.
          Positioned(
            top: -120,
            right: -100,
            child: FadeTransition(
              opacity: _glowFade,
              child: GlowOrb(
                size: 340,
                color: cs.primary.withValues(alpha: isDark ? 0.30 : 0.26),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -110,
            child: FadeTransition(
              opacity: _glowFade,
              child: GlowOrb(
                size: 320,
                color: cs.tertiary.withValues(alpha: isDark ? 0.22 : 0.20),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: BrandWordmark(),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 3),

                        Center(
                          child: FadeTransition(
                            opacity: _heroFade,
                            child: ScaleTransition(
                              scale: _heroScale,
                              child: const _Hero(),
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),

                        FadeTransition(
                          opacity: _headlineFade,
                          child: SlideTransition(
                            position: _headlineSlide,
                            child: Semantics(
                              header: true,
                              child: Text(
                                'Understand your skin,\n'
                                'find the routine that fits it.',
                                style: BrandText.headline(
                                  context,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        FadeTransition(
                          opacity: _bodyFade,
                          child: SlideTransition(
                            position: _bodySlide,
                            child: Text(
                              'Powered by on-device skin analysis.',
                              style: BrandText.body(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        FadeTransition(
                          opacity: _bodyFade,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: AnimatedBuilder(
                              animation: _progress,
                              builder: (context, _) => LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 6,
                                backgroundColor: cs.onSurface.withValues(
                                  alpha: 0.14,
                                ),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Ambient(
      period: const Duration(seconds: 6),
      child: SizedBox(
        width: 216,
        height: 216,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Spinning(
              cycles: 1,
              child: DashedRing(
                size: 200,
                color: cs.primary.withValues(alpha: 0.4),
              ),
            ),
            const Floating(
              amplitude: 5,
              cycles: 1.2,
              child: _BerseriMark(size: 104),
            ),
            Positioned(
              left: 4,
              top: 34,
              child: Floating(
                amplitude: 4,
                cycles: 1.8,
                phase: 0.2,
                child: Pulsing(
                  amount: 0.25,
                  cycles: 1.8,
                  phase: 0.2,
                  child: Sparkle(
                    size: 16,
                    color: cs.primary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 40,
              child: Floating(
                amplitude: 3,
                cycles: 2.2,
                phase: 0.65,
                child: Pulsing(
                  amount: 0.3,
                  cycles: 2.2,
                  phase: 0.65,
                  child: Sparkle(
                    size: 12,
                    color: cs.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BerseriMark extends StatelessWidget {
  const _BerseriMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(cs.primary, Colors.white, isDark ? 0.10 : 0.22)!,
            cs.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: isDark ? 0.45 : 0.35),
            blurRadius: 42,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.08,
            child: Container(
              width: size * 0.62,
              height: size * 0.34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.38),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Icon(
            Icons.face_retouching_natural,
            size: size * 0.52,
            color: cs.onPrimary,
          ),
        ],
      ),
    );
  }
}
