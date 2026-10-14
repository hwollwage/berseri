// Throwaway: proves the seeded placeholder history reaches both screens.
import 'package:berseri/features/analysis/history_page.dart';
import 'package:berseri/features/home/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard renders the seeded last analysis', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DashboardPage(onStartAnalysis: () {}, onOpenIngredients: () {}),
        ),
      ),
    );

    expect(find.text('Combination'), findsOneWidget);
    expect(find.text('Redness'), findsOneWidget);
    expect(find.text('Wrinkle'), findsOneWidget);
    expect(find.text('No analysis yet'), findsNothing);
  });

  testWidgets('history renders seeded month groups', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HistoryPage())),
    );

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Combination'), findsOneWidget);
    expect(find.text('Oily'), findsOneWidget);
    expect(find.text('Dry'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });
}
