import 'skin_type.dart';

class QuestionOption {
  final String label; // teks di first page
  final String summary; // teks singkat di pagess ripew

  final String value;

  final SkinType? skinType;

  const QuestionOption(
    this.label, {
    required this.value,
    String? summary,
    this.skinType,
  }) : summary = summary ?? label;
}

class Question {
  final String id;
  final String title;
  final String summaryLabel;
  final List<QuestionOption> options;

  const Question({
    required this.id,
    required this.title,
    required this.summaryLabel,
    required this.options,
  });
}
