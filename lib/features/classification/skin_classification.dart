// masih placeholder

class SkinClassification {
  final String label;
  final double confidence;

  /// Visible skin conditions reported by the model (multi-label). Empty when
  /// the response does not include them.
  final List<String> conditions;

  const SkinClassification({
    required this.label,
    required this.confidence,
    this.conditions = const <String>[],
  });

  factory SkinClassification.fromJson(Map<String, dynamic> json) {
    final raw = json['conditions'];

    return SkinClassification(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      conditions: raw is List
          ? raw.whereType<String>().toList(growable: false)
          : const <String>[],
    );
  }
}
