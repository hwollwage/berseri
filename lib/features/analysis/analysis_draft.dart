import 'package:image_picker/image_picker.dart';

import 'package:berseri/features/questionnaire/models/skin_type.dart';

class AnalysisDraft {
  const AnalysisDraft({
    this.photo,
    this.conditionScores = const <String, double>{},
    this.answers = const <String, String>{},
    this.skinType,
    this.skinTypeConfidence,
  });

  final XFile? photo;
  final Map<String, double> conditionScores;
  final Map<String, String> answers;
  final SkinType? skinType;
  final double? skinTypeConfidence;

  AnalysisDraft withAnswers({
    required Map<String, String> answers,
    required SkinType skinType,
    required double skinTypeConfidence,
  }) {
    return AnalysisDraft(
      photo: photo,
      conditionScores: conditionScores,
      answers: answers,
      skinType: skinType,
      skinTypeConfidence: skinTypeConfidence,
    );
  }
}
