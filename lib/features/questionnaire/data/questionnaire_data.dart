import '../models/question_model.dart';

const List<Question> questions = [
  Question(
    title: 'After washing your face, how does your skin feel after 30 minutes?',
    summaryLabel: 'After washing your face',
    options: [
      QuestionOption('Tight or dry'),
      QuestionOption('Comfortable'),
      QuestionOption('Oily all over'),
      QuestionOption('Oily mainly around the T-zone', summary: 'Oily in the T-zone'),
    ],
  ),
  Question(
    title: 'How does your skin usually feel throughout the day?',
    summaryLabel: 'Skin throughout the day',
    options: [
      QuestionOption('Dry or flaky'),
      QuestionOption('Feels comfortable', summary: 'Comfortable'),
      QuestionOption('Gets oily quickly'),
      QuestionOption('Oily around the T-zone, but normal/dry elsewhere',
          summary: 'Oily in the T-zone'),
    ],
  ),
  Question(
    title: 'How often does your skin feel oily?',
    summaryLabel: 'Where your skin gets oily',
    options: [
      QuestionOption('Rarely'),
      QuestionOption('Sometimes'),
      QuestionOption('Often'),
      QuestionOption('Almost every day'),
    ],
  ),
  Question(
    title: 'How does your skin usually feel by the end of the day?',
    summaryLabel: 'End of the day',
    options: [
      QuestionOption('Dry and tight'),
      QuestionOption('Comfortable'),
      QuestionOption('Oily all over'),
      QuestionOption('Oily mainly around the T-zone', summary: 'Oily in the T-zone'),
    ],
  ),
  Question(
    title: 'How does your skin feel after using a moisturizer?',
    summaryLabel: 'After applying moisturizer',
    options: [
      QuestionOption('Still feels tight or dry'),
      QuestionOption('Feels comfortable', summary: 'Comfortable'),
      QuestionOption('Feels oily or heavy'),
      QuestionOption('Oily in some areas but comfortable in others',
          summary: 'Oily in some areas'),
    ],
  ),
];