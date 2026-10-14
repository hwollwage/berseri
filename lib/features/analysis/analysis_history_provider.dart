import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder records so the dashboard's last-analysis card and the history
/// screen can be reviewed before a real scan exists. Delete this list and the
/// seed in [AnalysisHistoryNotifier.build] once persistence lands.
final List<AnalysisRecord> _placeholderHistory = <AnalysisRecord>[
  AnalysisRecord(
    date: DateTime(2026, 10, 7),
    skinType: 'combination',
    conditions: <String>['Redness', 'Wrinkle'],
  ),
  AnalysisRecord(
    date: DateTime(2026, 10, 2),
    skinType: 'oily',
    conditions: <String>['Acne', 'Blackheads'],
  ),
  AnalysisRecord(
    date: DateTime(2026, 9, 24),
    skinType: 'dry',
    conditions: <String>['Dryness'],
  ),
  AnalysisRecord(
    date: DateTime(2026, 9, 12),
    skinType: 'normal',
    conditions: <String>['Redness'],
  ),
];

/// Analyses kept for the running session, newest first.
///
/// Offline persistence (sqflite) is not wired up yet, so records live in
/// memory and are gone after a restart.
class AnalysisHistoryNotifier extends Notifier<List<AnalysisRecord>> {
  @override
  List<AnalysisRecord> build() => List<AnalysisRecord>.of(_placeholderHistory);

  void add(AnalysisRecord record) =>
      state = <AnalysisRecord>[record, ...state];

  void clear() => state = const <AnalysisRecord>[];
}

final analysisHistoryProvider =
    NotifierProvider<AnalysisHistoryNotifier, List<AnalysisRecord>>(
      AnalysisHistoryNotifier.new,
    );

/// Most recent analysis, or `null` when nothing has been saved yet.
final latestAnalysisProvider = Provider<AnalysisRecord?>((ref) {
  final history = ref.watch(analysisHistoryProvider);
  return history.isEmpty ? null : history.first;
});
