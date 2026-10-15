import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Accent amber. Seeds the light scheme's `primary`.
  static const Color amber = Color(0xFFF59E0B);

  /// Brightened amber
  static const Color amberBright = Color(0xFFFBBF24);

  /// Deeper amber for small accent text sitting on the light cream and white
  static const Color amberDeep = Color(0xFF9A5B00);

  static const Color cameraAccent = Color(0xFFF4B700);
  static const Color cameraAccentPressed = Color(0xFFD9A400);

  /// Only the questionnaire question pages use it. The summary that follows
  /// them is an ordinary cream page — see `SummaryPage`.
  static const Color sheetBackdrop = Color(0xFF292828);
}