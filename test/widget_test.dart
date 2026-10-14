import 'package:berseri/features/analysis/analysis_history_provider.dart';
import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/home/dashboard_page.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('greets the signed-in user by name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(() => _StubProfile('Ayu')),
          analysisHistoryProvider.overrideWith(
            () => _StubHistory(const <AnalysisRecord>[]),
          ),
        ],
        child: MaterialApp(
          home: DashboardPage(onStartAnalysis: () {}, onOpenIngredients: () {}),
        ),
      ),
    );

    // Name is inside a RichText – match via richText finder
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Ayu'),
      ),
      findsOneWidget,
    );
    expect(find.text('Analyze Your Skin'), findsOneWidget);
    expect(find.text('No analysis yet'), findsOneWidget);
  });

  testWidgets('shows the latest analysis when one exists', (tester) async {
    final record = AnalysisRecord(
      date: DateTime(2026, 10, 5),
      skinType: 'combination',
      conditions: const <String>['Acne', 'Redness'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analysisHistoryProvider.overrideWith(
            () => _StubHistory(<AnalysisRecord>[record]),
          ),
        ],
        child: MaterialApp(
          home: DashboardPage(onStartAnalysis: () {}, onOpenIngredients: () {}),
        ),
      ),
    );

    expect(find.text('Combination'), findsOneWidget);
    // formattedDate is lowercased in the card: "5 oct 2026"
    expect(find.text('5 oct 2026'), findsOneWidget);
    expect(find.text('Acne'), findsOneWidget);
    expect(find.text('Redness'), findsOneWidget);
    expect(find.text('See Detail Result'), findsOneWidget);
    expect(find.text('No analysis yet'), findsNothing);
  });

  testWidgets('starts analysis from the card button', (tester) async {
    var started = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DashboardPage(
            onStartAnalysis: () => started = true,
            onOpenIngredients: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Start Analysis'));
    await tester.pump();

    expect(started, isTrue);
  });
}

class _StubProfile extends UserProfileNotifier {
  _StubProfile(this._name);

  final String _name;

  @override
  UserProfile? build() => UserProfile(name: _name);
}

class _StubHistory extends AnalysisHistoryNotifier {
  _StubHistory(this._records);

  final List<AnalysisRecord> _records;

  @override
  List<AnalysisRecord> build() => _records;
}
