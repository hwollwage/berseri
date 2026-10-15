import 'package:berseri/core/components/brand_art.dart';
import 'package:berseri/core/components/glow_orb.dart';
import 'package:berseri/features/onboarding/presentation/widgets/art/face_art.dart';
import 'package:flutter/material.dart';

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
