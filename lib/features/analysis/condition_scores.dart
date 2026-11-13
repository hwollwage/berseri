const double visibleConditionScore = 0.5;

List<String> visibleConditionsOf(Map<String, double> conditionScores) {
  final visible = [
    for (final entry in conditionScores.entries)
      if (entry.value >= visibleConditionScore) entry,
  ]..sort((a, b) => b.value.compareTo(a.value));

  return [for (final entry in visible) entry.key];
}
