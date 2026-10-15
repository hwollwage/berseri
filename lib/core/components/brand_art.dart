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

class Spinning extends StatelessWidget {
  const Spinning({super.key, required this.child, this.cycles = 1});

  final Widget child;
  final double cycles;

  @override
  Widget build(BuildContext context) {
    final clock = Ambient.of(context);
    if (clock == null) return child;

    return AnimatedBuilder(
      animation: clock,
      builder: (context, child) => Transform.rotate(
        angle: clock.value * cycles * 2 * math.pi,
        child: child,
      ),
      child: child,
    );
  }
}

// Shapes
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(color),
    );
  }
}

/// A thin dashed circle, used as a soft "scan reticle" behind the artwork.
class DashedRing extends StatelessWidget {
  const DashedRing({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DashedRingPainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  const _SparklePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final waist = r * 0.16;

    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + waist, c.dy - waist, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + waist, c.dy + waist, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - waist, c.dy + waist, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - waist, c.dy - waist, c.dx, c.dy - r)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => oldDelegate.color != color;
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const segments = 72;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final rect = (Offset.zero & size).deflate(1);
    const sweep = 2 * math.pi / segments;

    for (var i = 0; i < segments; i += 2) {
      canvas.drawArc(rect, i * sweep, sweep * 0.7, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
