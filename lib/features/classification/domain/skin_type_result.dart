class SkinTypeResult {
  const SkinTypeResult(this.scores);

  // Sudah diurutkan dari yang tertinggi.
  final Map<String, double> scores;

  String get topLabel => scores.keys.first;
  double get topScore => scores.values.first;
}
