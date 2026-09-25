// masih placeholder

class SkinClassification {
  final String label;
  final double confidence;

  const SkinClassification({
    required this.label,
    required this.confidence,
  });

  factory SkinClassification.fromJson(Map<String, dynamic> json) {
    return SkinClassification(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}