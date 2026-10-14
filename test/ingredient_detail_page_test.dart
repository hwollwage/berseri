import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders IngredientDetailPage with all sections matching screenshot', (
    tester,
  ) async {
    const ingredient = Ingredient(
      name: 'Hyaluronic Acid',
      category: IngredientCategory.hydrating,
      summary: 'Holds water in the skin to keep it hydrated and plump.',
      goodFor: <String>['Dry', 'Normal', 'Wrinkles'],
      note: 'Apply to slightly damp skin.',
      bestFor: 'All skin types',
      helpsWith: 'Dehydration',
      useTime: 'Morning and night',
      whatItDoes:
          'Hyaluronic acid draws water into the outer layer of skin, helping it feel soft, smooth and bouncy.',
      pairsWellWith: <IngredientPairing>[
        IngredientPairing(name: 'Niacinamide', reason: 'For dark spot'),
        IngredientPairing(name: 'Alpha Arbutin', reason: 'For brightening'),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: IngredientDetailPage(ingredient: ingredient),
      ),
    );

    // Verify header
    expect(find.text('Hydrating'), findsOneWidget);
    expect(find.text('Hyaluronic Acid'), findsOneWidget);

    // Verify metadata table
    expect(find.text('Best for'), findsOneWidget);
    expect(find.text('All skin types'), findsOneWidget);
    expect(find.text('Helps with'), findsOneWidget);
    expect(find.text('Dehydration'), findsOneWidget);
    expect(find.text('Use'), findsOneWidget);
    expect(find.text('Morning and night'), findsOneWidget);

    // Verify What It Does
    expect(find.text('What It Does'), findsOneWidget);
    expect(
      find.text(
        'Hyaluronic acid draws water into the outer layer of skin, helping it feel soft, smooth and bouncy.',
      ),
      findsOneWidget,
    );

    // Verify Pairs Well With
    expect(find.text('Pairs Well With'), findsOneWidget);
    expect(find.text('Niacinamide'), findsOneWidget);
    expect(find.text('For dark spot'), findsOneWidget);
    expect(find.text('Alpha Arbutin'), findsOneWidget);
    expect(find.text('For brightening'), findsOneWidget);

    // Verify back button exists
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
  });
}
