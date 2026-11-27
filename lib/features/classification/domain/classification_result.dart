import 'dart:io';

class ClassificationResult {
  const ClassificationResult({
    required this.skinType,
    required this.skinTypeConfidence,
    required this.conditionScores,
    this.croppedFile,
  });

  final String skinType;
  final double skinTypeConfidence;
  final Map<String, double> conditionScores;
  final File? croppedFile;
}
