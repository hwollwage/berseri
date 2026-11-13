enum SkinType {
  normal('normal'),
  dry('dry'),
  oily('oily'),
  combination('combination');

  const SkinType(this.value);

  final String value;

  String get label => value[0].toUpperCase() + value.substring(1);
}

class SkinTypeEstimate {
  const SkinTypeEstimate({required this.skinType, required this.confidence});

  final SkinType skinType;

  final double confidence;

  String get label => skinType.label;
}
