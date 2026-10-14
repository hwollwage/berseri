import 'package:berseri/features/ingredients/ingredients_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The grid row height is derived from the card's own text metrics, so this
  // guards the two against drifting apart when padding or type sizes change.
  for (final scale in <double>[0.85, 1.0, 1.3, 1.6, 2.0, 3.1]) {
    testWidgets('ingredient cards fit the grid at text scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(397 * 3, 798 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize / tester.view.devicePixelRatio,
            textScaler: TextScaler.linear(scale),
          ),
          child: const MaterialApp(home: IngredientsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Niacinamide'), findsOneWidget);
    });
  }
}
