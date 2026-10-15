import 'package:berseri/core/components/app_colors.dart';
import 'package:berseri/core/components/face_outline.dart';
import 'package:flutter/material.dart';

import 'package:berseri/features/camera/presentation/widgets/glass_widgets.dart';

const _dimAlpha = 0.5;
const _ringWidth = 3.0;

Rect _frameRect(Size size) {
  final w = size.width * 0.74;
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height * 0.42),
    width: w,
    height: w * faceOutlineAspect,
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
                  top: rect.bottom + 50,
                  left: 24,
                  right: 24,
                  child: Center(child: GlassChip(label: hint!)),
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
    final face = faceOutlinePath(rect.size).shift(rect.topLeft);

    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addPath(face, Offset.zero);
    canvas.drawPath(
      scrim,
      Paint()..color = Colors.black.withValues(alpha: _dimAlpha),
    );

    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.cameraAccent,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.rect != rect;
}
