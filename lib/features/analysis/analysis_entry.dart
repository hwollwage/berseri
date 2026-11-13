import 'dart:convert';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/analysis/condition_scores.dart';

class IngredientSummary {
  const IngredientSummary({
    required this.id,
    required this.name,
    required this.summary,
  });

  final String id;
  final String name;
  final String summary;
}

class AnalysisEntry {
  const AnalysisEntry({
    required this.id,
    required this.record,
    this.skinTypeConfidence,
    this.ingredients = const <IngredientSummary>[],
    this.questionnaireAnswers = const <String, dynamic>{},
    this.photoUrl,
  });

  factory AnalysisEntry.fromRow(
    Map<String, dynamic> row, {
    Map<String, IngredientSummary> ingredientsById =
        const <String, IngredientSummary>{},
    String? photoUrl,
  }) {
    return AnalysisEntry(
      id: row['id']?.toString() ?? '',
      record: AnalysisRecord(
        date: _createdAt(row['created_at']),
        skinType: (row['skin_type'] as String?)?.trim() ?? '',
        conditions: _visibleConditions(row['conditions']),
      ),
      skinTypeConfidence: (row['skin_type_confidence'] as num?)?.toDouble(),
      ingredients: _ingredients(row, ingredientsById),
      questionnaireAnswers: _asMap(row['questionnaire_answers']),
      photoUrl: photoUrl,
    );
  }

  final String id;
  final AnalysisRecord record;
  final double? skinTypeConfidence;
  final List<IngredientSummary> ingredients;
  final Map<String, dynamic> questionnaireAnswers;
  final String? photoUrl;

  static List<String> _visibleConditions(Object? raw) {
    final found = <String, double?>{};

    void add(Object? label, Object? rawScore) {
      final text = label?.toString().trim() ?? '';
      if (text.isEmpty) return;

      var score = _score(rawScore);
      if (score != null) {
        if (score > 1) score /= 100;
        if (score < visibleConditionScore) return;
      }

      final key = _label(text);
      final previous = found[key];
      if (previous == null || (score != null && score > previous)) {
        found[key] = score ?? previous;
      }
    }

    _collectConditions(raw, add);
    if (found.isEmpty) return const <String>[];
    if (found.values.every((score) => score == null)) {
      return found.keys.toList(growable: false);
    }

    final scored = found.entries.toList()
      ..sort((a, b) => (b.value ?? 0).compareTo(a.value ?? 0));
    return [for (final entry in scored) entry.key];
  }

  static void _collectConditions(
    Object? raw,
    void Function(Object? label, Object? score) add,
  ) {
    switch (raw) {
      case Map map:
        map.forEach((key, value) {
          if (value is Map) {
            add(_conditionName(value) ?? key, _conditionScore(value));
          } else {
            add(key, value);
          }
        });
      case List list:
        for (final entry in list) {
          if (entry is Map) {
            add(_conditionName(entry), _conditionScore(entry));
          } else {
            add(entry, null);
          }
        }
      case String text:
        final trimmed = text.trim();
        if (trimmed.isEmpty) return;

        final decoded = _tryJson(trimmed);
        if (decoded != null) {
          _collectConditions(decoded, add);
          return;
        }
        for (final part in trimmed.split(RegExp(r'[,;]'))) {
          add(part, null);
        }
    }
  }

  static String? _conditionName(Map map) {
    for (final key in const ['label', 'name', 'condition', 'class']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  static Object? _conditionScore(Map map) {
    for (final key in const ['score', 'confidence', 'probability']) {
      final value = map[key];
      if (value is num || value is String) return value;
    }
    return null;
  }

  static double? _score(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }

  static Object? _tryJson(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  static List<IngredientSummary> _ingredients(
    Map<String, dynamic> row,
    Map<String, IngredientSummary> ingredientsById,
  ) {
    final rawIds = row['recommended_ingredient_ids'];
    if (rawIds is! List) return const <IngredientSummary>[];

    return [
      for (final id in rawIds) ?ingredientsById[id?.toString()],
    ];
  }

  static Map<String, dynamic> _asMap(Object? raw) {
    if (raw is Map) return raw.cast<String, dynamic>();
    return const <String, dynamic>{};
  }

  static DateTime _createdAt(Object? raw) {
    final parsed = DateTime.tryParse(raw?.toString() ?? '');
    return parsed?.toLocal() ?? DateTime.now();
  }

  static String _label(String key) => key
      .trim()
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
