class AnalysisRecord {
  const AnalysisRecord({
    required this.date,
    required this.skinType,
    this.conditions = const <String>[],
  });

  final DateTime date;
  final String skinType;
  final List<String> conditions;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get formattedDate =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  String get shortDate =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  static const List<String> _fullMonths = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String get monthLabel => '${_fullMonths[date.month - 1]} ${date.year}';
  (int, int) get monthKey => (date.year, date.month);

  String get skinTypeLabel => skinType.isEmpty
      ? skinType
      : skinType[0].toUpperCase() + skinType.substring(1);
}
