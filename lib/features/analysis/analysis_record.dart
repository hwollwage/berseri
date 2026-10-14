import 'package:berseri/features/classification/skin_classification.dart';

/// One finished skin analysis, as shown on the dashboard and in the history.
class AnalysisRecord {
  const AnalysisRecord({
    required this.date,
    required this.skinType,
    this.conditions = const <String>[],
    this.photoPath,
  });

  /// Builds a record from the ML result of a finished scan.
  factory AnalysisRecord.fromClassification(
    SkinClassification result, {
    DateTime? date,
    String? photoPath,
  }) {
    return AnalysisRecord(
      date: date ?? DateTime.now(),
      skinType: result.label,
      conditions: result.conditions,
      photoPath: photoPath,
    );
  }

  final DateTime date;

  /// Raw skin type label reported by the model, e.g. `combination`.
  final String skinType;

  /// Visible skin conditions reported by the model. May be empty.
  final List<String> conditions;

  /// Path of the scanned photo, when one was kept. `null` for records saved
  /// without an image (or when the platform cannot read the file).
  final String? photoPath;

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

  /// e.g. `5 Oct 2026`.
  String get formattedDate =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// e.g. `Oct 7, 2026`, used by the history list.
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

  /// Month heading the record is filed under in the history, e.g.
  /// `October 2026`.
  String get monthLabel => '${_fullMonths[date.month - 1]} ${date.year}';

  /// Year and month, used to group history entries.
  (int, int) get monthKey => (date.year, date.month);

  /// `combination` -> `Combination`.
  String get skinTypeLabel => skinType.isEmpty
      ? skinType
      : skinType[0].toUpperCase() + skinType.substring(1);
}
