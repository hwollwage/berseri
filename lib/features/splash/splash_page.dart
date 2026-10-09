import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated launch screen for Berseri.
///
/// Plays a short, staggered intro (mark -> wordmark -> tagline -> progress)
/// then hands control to the app via [GoRouter]. Honors the platform
/// "reduce motion" setting by jumping straight to the final frame.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// How long the intro animation runs.
  static const Duration introDuration = Duration(milliseconds: 2200);

  /// How long the splash stays on screen before routing onward.
  static const Duration holdDuration = Duration(milliseconds: 2600);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _markScale;
  late final Animation<double> _markFade;
  late final Animation<double> _glowFade;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _progress;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: SplashPage.introDuration,
    );

    // Staggered intervals: mark pops in first, then the wordmark,
    // tagline, and finally the progress bar fills.
    _markScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.55, curve: Curves.easeOutBack),
    );
    _markFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
    );
    _glowFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.10, 0.70, curve: Curves.easeOut),
    );
    _nameFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.60, 1.00, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Respect "reduce motion": show the settled state, no animation.
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _controller.value = 1.0;
    } else if (!_controller.isAnimating && _controller.value == 0.0) {
      _controller.forward();
    }

    _navTimer ??= Timer(SplashPage.holdDuration, _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    // No auth gate yet — land on home. Swap to '/auth/login' once
    // session restoration is wired up.
    context.go('/');
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

    // Warm, "glow" palette derived from the amber seed so the splash
    // feels like the rest of the app in both modes.
    final topColor = isDark ? const Color(0xFF1C1405) : const Color(0xFFFFFBF2);
    final midColor = isDark
        ? Color.alphaBlend(cs.primary.withValues(alpha: 0.10), const Color(0xFF120D03))
        : Color.alphaBlend(cs.primary.withValues(alpha: 0.14), Colors.white);
    final bottomColor =
        isDark ? const Color(0xFF0E0A02) : const Color(0xFFFFF3D6);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topColor, midColor, bottomColor],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient glow orbs behind the mark.
            Positioned(
              top: -90,
              right: -70,
              child: FadeTransition(
                opacity: _glowFade,
                child: _GlowOrb(
                  size: 320,
                  color: cs.primary.withValues(alpha: isDark ? 0.32 : 0.28),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: FadeTransition(
                opacity: _glowFade,
                child: _GlowOrb(
                  size: 300,
                  color: cs.tertiary.withValues(alpha: isDark ? 0.24 : 0.22),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Brand mark.
                  FadeTransition(
                    opacity: _markFade,
                    child: ScaleTransition(
                      scale: _markScale,
                      child: const _BerseriMark(size: 112),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Wordmark.
                  FadeTransition(
                    opacity: _nameFade,
                    child: SlideTransition(
                      position: _nameSlide,
                      child: Semantics(
                        header: true,
                        label: 'Berseri',
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: cs.onSurface,
                            ),
                            children: [
                              const TextSpan(text: 'Ber'),
                              TextSpan(
                                text: 'seri',
                                style: TextStyle(color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline.
                  FadeTransition(
                    opacity: _taglineFade,
                    child: SlideTransition(
                      position: _taglineSlide,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48),
                        child: Text(
                          'Understand your skin,\nfind the routine that fits it.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Progress + caption pinned near the bottom.
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 132,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: AnimatedBuilder(
                              animation: _progress,
                              builder: (context, _) => LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 4,
                                backgroundColor:
                                    cs.onSurface.withValues(alpha: 0.08),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(cs.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Powered by on-device skin analysis',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The app's brand mark: a rounded gradient badge with a soft inner glow
/// and a face-analysis glyph.
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
          colors: [cs.primary, cs.tertiary],
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
          // Inner highlight for a glossy, skincare-product feel.
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

/// A blurred, radial "glow" used as ambient background decoration.
class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
