/// Samakan dengan confidenceThreshold di SkinConditionService (0.05).
/// Skor YOLO setelah Sigmoid pada kondisi kulit ringan jarang melebihi 0.15,
/// sehingga threshold diturunkan dari 0.25 → 0.05.
const double visibleConditionScore = 0.05;

List<String> visibleConditionsOf(Map<String, double> conditionScores) {
  final visible = [
    for (final entry in conditionScores.entries)
      if (entry.value >= visibleConditionScore) entry,
  ]..sort((a, b) => b.value.compareTo(a.value));

  return [for (final entry in visible) entry.key];
}
