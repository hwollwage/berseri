import 'dart:math' as math;

import 'package:flutter/material.dart';

class Ambient extends StatefulWidget {
  const Ambient({
    super.key,
    required this.child,
    this.period = const Duration(seconds: 9),
  });

  final Widget child;

  final Duration period;

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AmbientScope>()?.clock;

  @override
  State<Ambient> createState() => _AmbientState();
}

class _AmbientState extends State<Ambient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: widget.period);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      if (_clock.isAnimating) _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      // No scope: descendants stay still.
      return widget.child;
    }

    return _AmbientScope(clock: _clock, child: widget.child);
  }
}

class _AmbientScope extends InheritedWidget {
  const _AmbientScope({required this.clock, required super.child});

  final Animation<double> clock;

  @override
  bool updateShouldNotify(_AmbientScope oldWidget) => clock != oldWidget.clock;
}

// Motion

class Floating extends StatelessWidget {
  const Floating({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.drift = 0,
    this.cycles = 1,
    this.phase = 0,
  });

  final Widget child;

  /// Vertical travel
  final double amplitude;

  /// Horizontal travel
  final double drift;

  final double cycles;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final clock = Ambient.of(context);
    if (clock == null) return child;

    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) {
        final t = clock.value * cycles + phase;
        return Transform.translate(
          offset: Offset(
            math.cos(2 * math.pi * t) * drift,
            math.sin(2 * math.pi * t) * amplitude,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class Pulsing extends StatelessWidget {
  const Pulsing({
    super.key,
    required this.child,
    this.amount = 0.06,
    this.cycles = 1,
    this.phase = 0,
  });

  final Widget child;
  final double amount;
  final double cycles;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final clock = Ambient.of(context);
    if (clock == null) return child;

    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) {
        final t = clock.value * cycles + phase;
        return Transform.scale(
          scale: 1 + math.sin(2 * math.pi * t) * amount,
          child: child,
        );
      },
      child: child,
    );
  }
}

class ScanSweep extends StatelessWidget {
  const ScanSweep({
    super.key,
    required this.line,
    required this.glow,
    this.trail = 34,
    this.thickness = 1.8,
    this.cycles = 1,
  });

  final Color line;
  final Color glow;
  final double trail;
  final double thickness;

  final double cycles;

  @override
  Widget build(BuildContext context) {
    final clock = Ambient.of(context);
    if (clock == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxHeight - trail - thickness;

        return AnimatedBuilder(
          animation: clock,
          builder: (context, _) => Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: (clock.value * cycles % 1) * travel,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: const [0, 0.12, 0.88, 1],
                  ).createShader(bounds),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: trail,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [glow.withValues(alpha: 0), glow],
                          ),
                        ),
                      ),
                      Container(
                        height: thickness,
                        decoration: BoxDecoration(
                          color: line,
                          boxShadow: [
                            BoxShadow(
                              color: glow,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
