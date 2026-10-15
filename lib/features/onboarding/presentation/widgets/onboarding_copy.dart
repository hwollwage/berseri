import 'package:berseri/core/components/brand.dart';
import 'package:berseri/features/onboarding/presentation/onboarding_slides.dart';
import 'package:flutter/material.dart';

class OnboardingCopy extends StatelessWidget {
  const OnboardingCopy({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(slide.eyebrow.toUpperCase(), style: BrandText.eyebrow(context)),
        const SizedBox(height: 10),
        Semantics(
          header: true,
          child: Text(
            slide.title,
            style: BrandText.headline(context, fontSize: 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(slide.body, style: BrandText.body(context)),
      ],
    );
  }
}
