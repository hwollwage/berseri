import 'package:berseri/features/onboarding/presentation/widgets/art/ingredients_art.dart';
import 'package:berseri/features/onboarding/presentation/widgets/art/questionnaire_art.dart';
import 'package:berseri/features/onboarding/presentation/widgets/art/scan_art.dart';
import 'package:berseri/features/onboarding/presentation/widgets/art/welcome_art.dart';
import 'package:flutter/widgets.dart';

/// One onboarding slide: its copy plus the artwork that illustrates it.
class OnboardingSlide {
  const OnboardingSlide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.art,
  });

  final String eyebrow;
  final String title;
  final String body;
  final Widget art;
}

/// The slides, in the order the carousel shows them.
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    eyebrow: 'Welcome',
    title: 'Get to know your skin.',
    body: 'A little insight into what your skin needs.',
    art: WelcomeArt(),
  ),
  OnboardingSlide(
    eyebrow: 'Skin analysis',
    title: 'It starts with a selfie.',
    body: 'A closer look at your skin type and visible concerns.',
    art: ScanArt(),
  ),
  OnboardingSlide(
    eyebrow: 'Questionnaire',
    title: 'Tell us a little more.',
    body: 'A few quick questions to complete your skin profile.',
    art: QuestionnaireArt(),
  ),
  OnboardingSlide(
    eyebrow: 'Ingredients',
    title: 'Know your ingredients.',
    body: 'Learn which ingredients may work for your skin.',
    art: IngredientsArt(),
  ),
];
