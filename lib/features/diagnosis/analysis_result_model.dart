class RecommendedIngredient {
  final String name;
  final String purpose;
  const RecommendedIngredient(this.name, this.purpose);
}

class AnalysisResult {
  final String skinType;
  final List<String> conditions;
  final List<RecommendedIngredient> ingredients;
  final DateTime date;
  final String? imagePath;

  const AnalysisResult({
    required this.skinType,
    required this.conditions,
    required this.ingredients,
    required this.date,
    this.imagePath,
  });

  // Data contoh buat ngetes UI. Ganti dengan hasil dari backend nanti.
  factory AnalysisResult.demo({String? imagePath}) => AnalysisResult(
        skinType: 'Normal',
        conditions: const ['Redness', 'Dark Spot', 'Acne'],
        ingredients: const [
          RecommendedIngredient('Niacinamide', 'For dark spot'),
          RecommendedIngredient('Alpha Arbutin', 'For Brightening'),
        ],
        date: DateTime.now(),
        imagePath: imagePath,
      );
}