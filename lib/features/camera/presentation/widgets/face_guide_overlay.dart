import 'package:flutter/material.dart';

import 'package:berseri/features/camera/presentation/widgets/glass_widgets.dart';

const _brand = Color(0xFFF4B700);
const _dimAlpha = 0.5;
const _frameRadius = 12.0;
const _bracketArm = 24.0;

Rect _frameRect(Size size) {
  final w = size.width * 0.74;
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height * 0.42),
    width: w,
    height: w * 1.3,
  );
}

class FaceGuideOverlay extends StatelessWidget {
  const FaceGuideOverlay({super.key, this.hint});

  final String? hint;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rect = _frameRect(constraints.biggest);
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _FramePainter(rect)),
              ),
              if (hint != null)
                Positioned(
                  top: rect.bottom +50,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: GlassChip(
                      label: hint!,
                      icon: Icons.face_retouching_natural,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter(this.rect);

  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(_frameRadius),
    );
    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(hole);
    canvas.drawPath(
      scrim,
      Paint()..color = Colors.black.withValues(alpha: _dimAlpha),
    );

    const r = _frameRadius;
    const a = _bracketArm;
    final l = rect.left, t = rect.top, rt = rect.right, b = rect.bottom;

    final brackets = Path()
      // kiri atas
      ..moveTo(l, t + r + a)
      ..lineTo(l, t + r)
      ..arcToPoint(Offset(l + r, t), radius: const Radius.circular(r))
      ..lineTo(l + r + a, t)
      // kanan atas
      ..moveTo(rt - r - a, t)
      ..lineTo(rt - r, t)
      ..arcToPoint(Offset(rt, t + r), radius: const Radius.circular(r))
      ..lineTo(rt, t + r + a)
      // kanan bawah
      ..moveTo(rt, b - r - a)
      ..lineTo(rt, b - r)
      ..arcToPoint(Offset(rt - r, b), radius: const Radius.circular(r))
      ..lineTo(rt - r - a, b)
      // kiri bawah
      ..moveTo(l + r + a, b)
      ..lineTo(l + r, b)
      ..arcToPoint(Offset(l, b - r), radius: const Radius.circular(r))
      ..lineTo(l, b - r - a);

    canvas.drawPath(
      brackets,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = _brand,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.rect != rect;
}