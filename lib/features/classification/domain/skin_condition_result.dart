import 'dart:io';

class SkinConditionResult {
  const SkinConditionResult(this.conditionScores, {this.croppedFile});

  final Map<String, double> conditionScores;
  final File? croppedFile;
}
