import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/ingredients/ingredient.dart';

class RecommendedIngredient {
  final String name;
  final String purpose;
  const RecommendedIngredient(this.name, this.purpose);
}

List<Ingredient> matchedIngredientsFor(AnalysisRecord record) {
  final tags = <String>{
    record.skinTypeLabel.toLowerCase(),
    for (final condition in record.conditions) condition.toLowerCase(),
  };

  return ingredientLibrary
      .where(
        (ingredient) => ingredient.goodFor.any(
          (target) => tags.contains(target.toLowerCase()),
        ),
      )
      .toList(growable: false);
}

class AnalysisResult {
  final String skinTypeLabel;
  final List<String> conditions;
  final List<RecommendedIngredient> ingredients;
  final DateTime date;
  final String? imagePath;

  const AnalysisResult({
    required this.skinTypeLabel,
    required this.conditions,
    required this.ingredients,
    required this.date,
    this.imagePath,
  });

  factory AnalysisResult.fromRecord(AnalysisRecord record) {
    return AnalysisResult(
      skinTypeLabel: record.skinTypeLabel,
      conditions: record.conditions,
      ingredients: matchedIngredientsFor(record)
          .map(
            (ingredient) =>
                RecommendedIngredient(ingredient.name, ingredient.summary),
          )
          .toList(growable: false),
      date: record.date,
      imagePath: record.photoPath,
    );
  }

  factory AnalysisResult.demo({String? imagePath}) => AnalysisResult(
        skinTypeLabel: 'Normal',
        conditions: const ['Redness', 'Dark Spot', 'Acne'],
        ingredients: const [
          RecommendedIngredient('Niacinamide', 'For dark spot'),
          RecommendedIngredient('Alpha Arbutin', 'For Brightening'),
        ],
        date: DateTime.now(),
        imagePath: imagePath,
      );
}