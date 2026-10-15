import 'dart:math' as math;

import 'package:berseri/core/components/face_outline.dart';
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
        hair: Color.lerp(cs.primary, cs.onPrimaryContainer, 0.55)!,
        shadow: cs.shadow.withValues(alpha: 0.16),
      ),
    );
  }
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
