import 'dart:math' as math;

import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/core/components/face_outline.dart';
import 'package:berseri/core/components/glow_orb.dart';
import 'package:flutter/material.dart';

class FaceArt extends StatelessWidget {
  const FaceArt({super.key, this.width = 92});

  final double width;

  static const double aspect = faceOutlineAspect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomPaint(
      size: Size(width, width * aspect),
      painter: _FacePainter(
        fill: Color.lerp(cs.surfaceContainerLowest, cs.primaryContainer, 0.22)!,
        outline: Color.lerp(
          cs.primary,
          cs.onPrimaryContainer,
          0.22,
        )!.withValues(alpha: 0.9),
        ink: cs.onSurface.withValues(alpha: 0.85),
        blush: cs.primary.withValues(alpha: 0.45),
        // Both ends are scheme colours, so the hair stays on-palette.
        hair: Color.lerp(cs.primary, cs.onPrimaryContainer, 0.55)!,
        shadow: cs.shadow.withValues(alpha: 0.16),
      ),
    );
  }
}


class WelcomeArt extends StatelessWidget {
  const WelcomeArt({super.key});

  static const Offset _centre = Offset(150, 160);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Ambient(
      child: Floating(
        amplitude: 6,
        cycles: 1.5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _centre.dx - 112,
              top: _centre.dy - 112,
              child: Pulsing(
                amount: 0.05,
                cycles: 1,
                child: GlowOrb(
                  size: 224,
                  color: cs.primary.withValues(alpha: 0.30),
                ),
              ),
            ),
            Positioned(
              left: _centre.dx - 98,
              top: _centre.dy - 98,
              child: Spinning(
                cycles: 1,
                child: DashedRing(
                  size: 196,
                  color: cs.primary.withValues(alpha: 0.42),
                ),
              ),
            ),
            Positioned(
              left: _centre.dx - 62,
              top: _centre.dy - 62 * FaceArt.aspect,
              child: const FaceArt(width: 124),
            ),
          ],
        ),
      ),
    );
  }
}


class ScanArt extends StatelessWidget {
  const ScanArt({super.key});
  static const Rect _viewfinder = Rect.fromLTWH(62, 46, 176, 216);
  static const double _beamInset = 12;
  static const double _faceWidth = 92;

  static const Offset _headCentre = Offset(0.5, 0.5062);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final face = Size(_faceWidth, _faceWidth * FaceArt.aspect);
    final beam = _viewfinder.deflate(_beamInset);

    return Ambient(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: _viewfinder.left,
            top: _viewfinder.top,
            child: Pulsing(
              amount: 0.02,
              cycles: 1,
              child: CustomPaint(
                size: _viewfinder.size,
                painter: _BracketsPainter(
                  color: cs.primary.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            left: _viewfinder.center.dx - face.width * _headCentre.dx,
            top: _viewfinder.center.dy - face.height * _headCentre.dy,
            child: const Floating(
              amplitude: 3,
              cycles: 1.4,
              child: FaceArt(width: _faceWidth),
            ),
          ),
          Positioned(
            left: beam.left,
            top: beam.top,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: beam.width,
                height: beam.height,
                child: _ScanLine(
                  line: cs.primary.withValues(alpha: 0.9),
                  glow: cs.primary.withValues(alpha: 0.22),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 96,
            child: const Floating(
              amplitude: 4,
              cycles: 1.9,
              phase: 0.3,
              child: _Chip(label: 'Skin type'),
            ),
          ),
          Positioned(
            right: 0,
            top: 212,
            child: const Floating(
              amplitude: 4,
              cycles: 1.6,
              phase: 0.7,
              child: _Chip(label: 'Conditions', filled: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.line, required this.glow});

  final Color line;
  final Color glow;

  /// Height of the soft trail sitting above the hairline.
  static const double _trail = 34;
  static const double _thickness = 1.8;

  @override
  Widget build(BuildContext context) {
    final clock = Ambient.of(context);
    if (clock == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final travel = constraints.maxHeight - _trail - _thickness;

        return AnimatedBuilder(
          animation: clock,
          builder: (context, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: clock.value * travel,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  // Fade the ends so the beam does not stop dead at the edge.
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
                        height: _trail,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [glow.withValues(alpha: 0), glow],
                          ),
                        ),
                      ),
                      Container(
                        height: _thickness,
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

class QuestionnaireArt extends StatelessWidget {
  const QuestionnaireArt({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Ambient(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 10,
            top: 26,
            child: Container(
              width: 280,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: i == 4 ? 0 : 6),
                            decoration: BoxDecoration(
                              color: i < 2
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _AnswerRow(label: 'Tight and dry'),
                  const _AnswerRow(label: 'Oily in the T-zone', selected: true),
                  const _AnswerRow(label: 'Oily all over', last: true),
                ],
              ),
            ),
          ),
          Positioned(
            right: 2,
            top: 214,
            child: const Floating(
              amplitude: 5,
              cycles: 1.7,
              child: Pulsing(
                amount: 0.05,
                cycles: 1.7,
                child: _QuestionBadge(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IngredientsArt extends StatelessWidget {
  const IngredientsArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Ambient(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hero, dead centre. The eye lands here first.
          const Positioned(
            left: 98,
            top: 100,
            child: Floating(
              amplitude: 8,
              drift: 3,
              cycles: 1.1,
              child: _IngredientBubble(
                label: 'Hyaluronic Acid',
                size: 104,
                tone: _BubbleTone.accent,
              ),
            ),
          ),
          // Satellites, one per corner of the cluster.
          const Positioned(
            left: 10,
            top: 20,
            child: Floating(
              amplitude: 6,
              drift: 3,
              cycles: 1.4,
              phase: 0.35,
              child: _IngredientBubble(label: 'Niacinamide', size: 86),
            ),
          ),
          const Positioned(
            left: 214,
            top: 34,
            child: Floating(
              amplitude: 7,
              drift: 2,
              cycles: 0.9,
              phase: 0.6,
              child: _IngredientBubble(
                label: 'Centella',
                size: 76,
                tone: _BubbleTone.soft,
              ),
            ),
          ),
          const Positioned(
            left: 22,
            top: 214,
            child: Floating(
              amplitude: 7,
              drift: 3,
              cycles: 1.25,
              phase: 0.15,
              child: _IngredientBubble(label: 'Vitamin C', size: 78),
            ),
          ),
          const Positioned(
            left: 200,
            top: 208,
            child: Floating(
              amplitude: 6,
              drift: 2,
              cycles: 1.05,
              phase: 0.8,
              child: _IngredientBubble(
                label: 'Ceramides',
                size: 84,
                tone: _BubbleTone.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.filled = false});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final foreground = filled ? cs.onPrimary : cs.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? cs.primary : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? cs.onPrimary : cs.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.label,
    this.selected = false,
    this.last = false,
  });

  final String label;
  final bool selected;

  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (selected) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(shape: BoxShape.circle, color: cs.onPrimary),
        child: Icon(Icons.check, size: 13, color: cs.primary),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.outline),
      ),
    );
  }
}

class _QuestionBadge extends StatelessWidget {
  const _QuestionBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        '?',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}

enum _BubbleTone {
  plain,
  accent,
  soft,
}

class _IngredientBubble extends StatelessWidget {
  const _IngredientBubble({
    required this.label,
    required this.size,
    this.tone = _BubbleTone.plain,
  });

  final String label;
  final double size;
  final _BubbleTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (background, foreground) = switch (tone) {
      _BubbleTone.plain => (cs.surfaceContainerLowest, cs.onSurface),
      _BubbleTone.accent => (cs.primary, cs.onPrimary),
      _BubbleTone.soft => (cs.primaryContainer, cs.onPrimaryContainer),
    };

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      padding: EdgeInsets.all(size * 0.09),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: size * 0.115,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: foreground,
        ),
      ),
    );
  }
}

class _BracketsPainter extends CustomPainter {
  const _BracketsPainter({required this.color});

  final Color color;

  static const double _arm = 28;
  static const double _radius = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final corners = <Path>[
      Path()
        ..moveTo(0, _arm)
        ..lineTo(0, _radius)
        ..quadraticBezierTo(0, 0, _radius, 0)
        ..lineTo(_arm, 0),
      Path()
        ..moveTo(w - _arm, 0)
        ..lineTo(w - _radius, 0)
        ..quadraticBezierTo(w, 0, w, _radius)
        ..lineTo(w, _arm),
      Path()
        ..moveTo(w, h - _arm)
        ..lineTo(w, h - _radius)
        ..quadraticBezierTo(w, h, w - _radius, h)
        ..lineTo(w - _arm, h),
      Path()
        ..moveTo(_arm, h)
        ..lineTo(_radius, h)
        ..quadraticBezierTo(0, h, 0, h - _radius)
        ..lineTo(0, h - _arm),
    ];

    for (final path in corners) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BracketsPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FacePainter extends CustomPainter {
  const _FacePainter({
    required this.fill,
    required this.outline,
    required this.ink,
    required this.blush,
    required this.hair,
    required this.shadow,
  });

  final Color fill;
  final Color outline;
  final Color ink;
  final Color blush;
  final Color hair;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final head = faceOutlinePath(size);

    canvas.drawPath(
      head,
      Paint()
        ..color = shadow
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.07),
    );

    canvas.drawPath(head, Paint()..color = fill);
    canvas.drawPath(
      head,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.026,
    );

    canvas.save();
    canvas.clipPath(head);
    final fringe = Path()
      ..moveTo(0, h * 0.30)
      ..quadraticBezierTo(w * 0.28, h * 0.33, w * 0.50, h * 0.21)
      ..quadraticBezierTo(w * 0.70, h * 0.10, w * 0.84, h * 0.21)
      ..quadraticBezierTo(w * 0.93, h * 0.27, w * 1.0, h * 0.25)
      ..lineTo(w * 1.0, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(fringe, Paint()..color = hair);
    canvas.restore();

    for (final x in const [0.19, 0.81]) {
      final rect = Rect.fromCenter(
        center: Offset(w * x, h * 0.66),
        width: w * 0.26,
        height: h * 0.11,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [blush, blush.withValues(alpha: 0)],
          ).createShader(rect),
      );
    }

    final eyeStroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    for (final x in const [0.34, 0.66]) {
      final eye = Rect.fromCircle(
        center: Offset(w * x, h * 0.55),
        radius: w * 0.085,
      );
      canvas.drawArc(eye, math.pi, math.pi, false, eyeStroke);
    }

    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.665), radius: w * 0.10),
      0,
      math.pi,
      false,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_FacePainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.outline != outline ||
      oldDelegate.ink != ink ||
      oldDelegate.blush != blush ||
      oldDelegate.hair != hair ||
      oldDelegate.shadow != shadow;
}
