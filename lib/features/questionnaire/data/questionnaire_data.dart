import '../models/question_model.dart';
import '../models/skin_type.dart';

const List<Question> questions = [
  Question(
    id: 'after_washing',
    title: 'After washing your face, how does your skin feel after 30 minutes?',
    summaryLabel: 'After washing your face',
    options: [
      QuestionOption('Tight or dry', value: 'tight_dry', skinType: SkinType.dry),
      QuestionOption(
        'Comfortable',
        value: 'comfortable',
        skinType: SkinType.normal,
      ),
      QuestionOption(
        'Oily all over',
        value: 'oily_all_over',
        skinType: SkinType.oily,
      ),
      QuestionOption(
        'Oily mainly around the T-zone',
        value: 't_zone',
        summary: 'Oily in the T-zone',
        skinType: SkinType.combination,
      ),
    ],
  ),
  Question(
    id: 'through_the_day',
    title: 'How does your skin usually feel throughout the day?',
    summaryLabel: 'Skin throughout the day',
    options: [
      QuestionOption('Dry or flaky', value: 'dry_flaky', skinType: SkinType.dry),
      QuestionOption(
        'Feels comfortable',
        value: 'comfortable',
        summary: 'Comfortable',
        skinType: SkinType.normal,
      ),
      QuestionOption(
        'Gets oily quickly',
        value: 'oily_quickly',
        skinType: SkinType.oily,
      ),
      QuestionOption(
        'Oily around the T-zone, but normal/dry elsewhere',
        value: 't_zone_only',
        summary: 'Oily in the T-zone',
        skinType: SkinType.combination,
      ),
    ],
  ),
  Question(
    id: 'oily_frequency',
    title: 'How often does your skin feel oily?',
    summaryLabel: 'Where your skin gets oily',
    options: [
      QuestionOption('Rarely', value: 'rarely', skinType: SkinType.normal),
      QuestionOption('Sometimes', value: 'sometimes', skinType: SkinType.normal),
      QuestionOption('Often', value: 'often', skinType: SkinType.oily),
      QuestionOption(
        'Almost every day',
        value: 'almost_daily',
        skinType: SkinType.oily,
      ),
    ],
  ),
  Question(
    id: 'end_of_day',
    title: 'How does your skin usually feel by the end of the day?',
    summaryLabel: 'End of the day',
    options: [
      QuestionOption(
        'Dry and tight',
        value: 'dry_tight',
        skinType: SkinType.dry,
      ),
      QuestionOption(
        'Comfortable',
        value: 'comfortable',
        skinType: SkinType.normal,
      ),
      QuestionOption(
        'Oily all over',
        value: 'oily_all_over',
        skinType: SkinType.oily,
      ),
      QuestionOption(
        'Oily mainly around the T-zone',
        value: 't_zone',
        summary: 'Oily in the T-zone',
        skinType: SkinType.combination,
      ),
    ],
  ),
  Question(
    id: 'after_moisturizer',
    title: 'How does your skin feel after using a moisturizer?',
    summaryLabel: 'After applying moisturizer',
    options: [
      QuestionOption(
        'Still feels tight or dry',
        value: 'still_tight',
        skinType: SkinType.dry,
      ),
      QuestionOption(
        'Feels comfortable',
        value: 'comfortable',
        summary: 'Comfortable',
        skinType: SkinType.normal,
      ),
      QuestionOption(
        'Feels oily or heavy',
        value: 'oily_heavy',
        skinType: SkinType.oily,
      ),
      QuestionOption(
        'Oily in some areas but comfortable in others',
        value: 'mixed',
        summary: 'Oily in some areas',
        skinType: SkinType.combination,
      ),
    ],
  ),
];

SkinTypeEstimate resolveSkinType(Map<String, String> answers) {
  final votes = <SkinType, int>{};
  var total = 0;

  for (final question in questions) {
    final answer = answers[question.id];
    if (answer == null) continue;

    for (final option in question.options) {
      if (option.value != answer) continue;
      final skinType = option.skinType;
      if (skinType != null) {
        votes[skinType] = (votes[skinType] ?? 0) + 1;
        total++;
      }
      break;
    }
  }

  if (total == 0) {
    return const SkinTypeEstimate(skinType: SkinType.normal, confidence: 0);
  }

  var best = SkinType.normal;
  var bestCount = 0;
  var tied = false;
  for (final entry in votes.entries) {
    if (entry.value > bestCount) {
      best = entry.key;
      bestCount = entry.value;
      tied = false;
    } else if (entry.value == bestCount) {
      tied = true;
    }
  }

  return SkinTypeEstimate(
    skinType: tied ? SkinType.combination : best,
    confidence: bestCount / total,
  );
}

Map<String, String> answersByQuestion(List<int?> answers) {
  final result = <String, String>{};

  for (var i = 0; i < questions.length && i < answers.length; i++) {
    final index = answers[i];
    if (index == null) continue;

    final options = questions[i].options;
    if (index < 0 || index >= options.length) continue;

    result[questions[i].id] = options[index].value;
  }

  return result;
}
