// masih placeholder

class SkinClassification {
  final String label;
  final double confidence;

  /// Visible skin conditions reported by the model. May be empty.
  final List<String> conditions;

  const SkinClassification({
    required this.label,
    required this.confidence,
    this.conditions = const <String>[],
  });

  factory SkinClassification.fromJson(Map<String, dynamic> json) {
    return SkinClassification(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      conditions: List<String>.from(
        json['conditions'] as List<dynamic>? ?? const <dynamic>[],
      ),
    );
  }
}