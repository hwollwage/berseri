import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/core/components/face_art.dart';
import 'package:berseri/core/components/glow_orb.dart';
import 'package:flutter/material.dart';

class WelcomeArt extends StatelessWidget {
  const WelcomeArt({super.key});

  static const Offset _centre = Offset(150, 160);
  static const double _plate = 184;
  static const double _faceWidth = 132;

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
              left: _centre.dx - _plate / 2,
              top: _centre.dy - _plate / 2,
              child: const _Plate(size: _plate),
            ),
            Positioned(
              left: _centre.dx - _faceWidth / 2,
              top: _centre.dy - _faceWidth * FaceArt.aspect / 2,
              child: const FaceArt(width: _faceWidth),
            ),
          ],
        ),
      ),
    );
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.surfaceContainerLowest,
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }
}
