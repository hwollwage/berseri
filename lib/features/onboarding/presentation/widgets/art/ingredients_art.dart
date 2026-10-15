import 'package:berseri/core/components/brand_art.dart';
import 'package:flutter/material.dart';

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
