import 'dart:math' as math;

import 'package:flutter/material.dart';

class OnboardingArtSlide extends StatelessWidget {
  const OnboardingArtSlide({
    super.key,
    required this.controller,
    required this.index,
    required this.art,
  });

  final PageController controller;
  final int index;
  final Widget art;

  static const Size _canvas = Size(300, 320);
  static const double _maxScale = 1.45;
  static const double _parallax = 26;
  static const double _fadePerPage = 0.55;

  double get _offset {
    if (!controller.hasClients) return 0;
    final page = controller.page;
    if (page == null) return 0;
    return (page - index).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fit = math.min(
            constraints.maxHeight / _canvas.height,
            constraints.maxWidth / _canvas.width,
          );
          final scale = math.min(fit, _maxScale);
          return Center(
            child: SizedBox(
              width: _canvas.width * scale,
              height: _canvas.height * scale,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox.fromSize(size: _canvas, child: art),
              ),
            ),
          );
        },
      ),
    );

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return content;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final offset = _offset;
        return Opacity(
          opacity: (1 - offset.abs() * _fadePerPage).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _parallax * offset),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}
