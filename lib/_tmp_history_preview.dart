// Throwaway preview harness: renders HistoryPage with sample records so the
// layout can be inspected without running a real scan. Deleted after review.
import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/analysis/history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        analysisHistoryProvider.overrideWith(
          () => _StubHistory([
            AnalysisRecord(
              date: DateTime(2026, 11, 9),
              skinType: 'combination',
              conditions: ['Redness', 'wrinkle'],
            ),
            AnalysisRecord(
              date: DateTime(2026, 11, 2),
              skinType: 'combination',
              conditions: ['Redness', 'wrinkle'],
            ),
            AnalysisRecord(
              date: DateTime(2026, 10, 7),
              skinType: 'combination',
              conditions: ['Redness', 'wrinkle'],
            ),
          ]),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true),
        home: const HistoryPage(),
      ),
    ),
  );
}

class _StubHistory extends AnalysisHistoryNotifier {
  _StubHistory(this._records);

  final List<AnalysisRecord> _records;

  @override
  List<AnalysisRecord> build() => _records;
}
