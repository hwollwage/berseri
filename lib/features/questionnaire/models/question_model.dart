class QuestionOption {
  final String label;   // teks di first page
  final String summary; // teks singkat di pagess ripew

  const QuestionOption(this.label, {String? summary})
      : summary = summary ?? label;
}

class Question {
  final String title;
  final String summaryLabel;
  final List<QuestionOption> options;

  const Question({
    required this.title,
    required this.summaryLabel,
    required this.options,
  });
}