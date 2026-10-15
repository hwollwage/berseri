import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/features/onboarding/presentation/widgets/art/face_art.dart';
import 'package:flutter/material.dart';

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
