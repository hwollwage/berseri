import 'package:berseri/core/components/brand.dart';
import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/core/components/face_art.dart';
import 'package:flutter/material.dart';

class ScanArt extends StatelessWidget {
  const ScanArt({super.key});

  static const Size _reticle = Size(
    _faceWidth + _margin * 2,
    _faceWidth * FaceArt.aspect + _margin * 2,
  );

  static const double _faceWidth = 128;
  static const double _margin = 26;
  static const Offset _headCentre = Offset(0.5, 0.5062);
  static const double _sweepInset = 14;
  static const double _gap = 22;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final face = Size(_faceWidth, _faceWidth * FaceArt.aspect);

    return Ambient(
      child: Center(
        child: SizedBox(
          width: _reticle.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: _Readout('Skin type'),
              ),
              const SizedBox(height: _gap),
              SizedBox.fromSize(
                size: _reticle,
                child: Stack(
                  children: [
                    Pulsing(
                      amount: 0.015,
                      cycles: 1,
                      child: CustomPaint(
                        size: _reticle,
                        painter: _BracketsPainter(
                          color: cs.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _reticle.width / 2 - face.width * _headCentre.dx,
                      top: _reticle.height / 2 - face.height * _headCentre.dy,
                      child: const Floating(
                        amplitude: 3,
                        cycles: 1.4,
                        child: FaceArt(width: _faceWidth),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: (Offset.zero & _reticle).deflate(_sweepInset),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ScanSweep(
                          line: cs.primary,
                          glow: cs.primary.withValues(alpha: 0.34),
                          trail: 52,
                          thickness: 2.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: _gap),
              const Align(
                alignment: Alignment.centerRight,
                child: _Readout('Conditions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A micro label, set in the same eyebrow style as the slide's own copy.
class _Readout extends StatelessWidget {
  const _Readout(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      label.toUpperCase(),
      style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: BrandText.accent(context),
      ),
    );
  }
}

class _BracketsPainter extends CustomPainter {
  const _BracketsPainter({required this.color});

  final Color color;

  static const double _arm = 30;
  static const double _radius = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
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
