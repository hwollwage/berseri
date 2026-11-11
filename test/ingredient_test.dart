import 'package:berseri/features/analysis/analysis_record.dart';
import 'package:berseri/features/diagnosis/analysis_result_model.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:berseri/features/ingredients/ingredient_detail_page.dart';
import 'package:berseri/features/ingredients/ingredient_repository.dart';
import 'package:berseri/features/ingredients/ingredients_page.dart';
import 'package:berseri/features/profile/user_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubProfile extends UserProfileNotifier {
  _StubProfile(this._name);
  final String _name;
  @override
  UserProfile? build() => UserProfile(name: _name);
}

void main() {
  group('Ingredient.fromDatabase', () {
    test('correctly maps raw database rows to Ingredient', () {
      final ingredientRow = <String, dynamic>{
        'id': 'uuid-1',
        'name': 'Centella Asiatica',
        'summary': 'Calms and soothes sensitive skin.',
        'use_time': 'Morning and night',
        'what_it_does': 'Rich in madecassoside, reduces redness and reinforces skin.',
        'is_active': true,
      };

      final suitabilityRows = <Map<String, dynamic>>[
        {'ingredient_id': 'uuid-1', 'kind': 'skin_type', 'value': 'dry'},
        {'ingredient_id': 'uuid-1', 'kind': 'skin_type', 'value': 'oily'},
        {'ingredient_id': 'uuid-1', 'kind': 'condition', 'value': 'redness'},
        {'ingredient_id': 'uuid-1', 'kind': 'condition', 'value': 'acne'},
      ];

      final pairedRow = <String, dynamic>{
        'id': 'uuid-2',
        'name': 'Hyaluronic Acid',
        'summary': 'Hydrates deeply.',
      };

      final pairingRows = <Map<String, dynamic>>[
        {
          'ingredient_id': 'uuid-1',
          'paired_ingredient_id': 'uuid-2',
          'kind': 'pairs_well',
        },
      ];

      final idToLookup = <String, Map<String, dynamic>>{
        'uuid-2': pairedRow,
      };

      final ingredient = Ingredient.fromDatabase(
        row: ingredientRow,
        suitabilities: suitabilityRows,
        pairings: pairingRows,
        idToIngredientLookup: idToLookup,
      );

      expect(ingredient.id, 'uuid-1');
      expect(ingredient.name, 'Centella Asiatica');
      expect(ingredient.summary, 'Calms and soothes sensitive skin.');
      expect(ingredient.useTime, 'Morning and night');
      expect(ingredient.whatItDoes, contains('Rich in madecassoside'));
      expect(ingredient.goodFor, containsAll(['Dry', 'Oily', 'Redness', 'Acne']));
      expect(ingredient.pairsWellWith.length, 1);
      expect(ingredient.pairsWellWith.first.name, 'Hyaluronic Acid');
      expect(ingredient.pairsWellWith.first.reason, 'Hydrates deeply.');
    });

    test('determines category according to conditions and skin types', () {
      expect(
        IngredientCategoryHelper.determineCategory(
          conditions: ['acne'],
          skinTypes: ['oily'],
        ),
        IngredientCategory.acne,
      );

      expect(
        IngredientCategoryHelper.determineCategory(
          conditions: ['pigmentation'],
          skinTypes: ['normal'],
        ),
        IngredientCategory.brightening,
      );

      expect(
        IngredientCategoryHelper.determineCategory(
          conditions: ['wrinkles'],
          skinTypes: ['dry'],
        ),
        IngredientCategory.wrinkle,
      );

      expect(
        IngredientCategoryHelper.determineCategory(
          conditions: ['redness'],
          skinTypes: ['normal'],
        ),
        IngredientCategory.redness,
      );

      expect(
        IngredientCategoryHelper.determineCategory(
          conditions: [],
          skinTypes: ['dry'],
        ),
        IngredientCategory.hydrating,
      );
    });
  });

  group('filterIngredients', () {
    final customList = <Ingredient>[
      const Ingredient(
        name: 'Alpha Arbutin',
        category: IngredientCategory.brightening,
        summary: 'Brightens skin',
        goodFor: ['Normal', 'Pigmentation'],
        note: '',
      ),
      const Ingredient(
        name: 'Salicylic Acid',
        category: IngredientCategory.acne,
        summary: 'Clears acne',
        goodFor: ['Oily', 'Acne'],
        note: '',
      ),
    ];

    test('filters custom ingredient list by query and category', () {
      final resAcne = filterIngredients(
        ingredients: customList,
        category: IngredientCategory.acne,
      );
      expect(resAcne.length, 1);
      expect(resAcne.first.name, 'Salicylic Acid');

      final resQuery = filterIngredients(
        ingredients: customList,
        query: 'arbutin',
      );
      expect(resQuery.length, 1);
      expect(resQuery.first.name, 'Alpha Arbutin');
    });

    test('falls back to ingredientLibrary when ingredients parameter is omitted', () {
      final res = filterIngredients(query: 'Niacinamide');
      expect(res.isNotEmpty, isTrue);
      expect(res.first.name, 'Niacinamide');
    });
  });

  group('matchedIngredientsFor', () {
    test('uses custom ingredient pool when supplied', () {
      final record = AnalysisRecord(
        date: DateTime.now(),
        skinType: 'oily',
        conditions: const ['acne'],
      );

      final pool = <Ingredient>[
        const Ingredient(
          name: 'Custom BHA',
          category: IngredientCategory.acne,
          summary: 'Custom summary',
          goodFor: ['Oily', 'Acne'],
          note: '',
        ),
      ];

      final matched = matchedIngredientsFor(record, pool);
      expect(matched.length, 1);
      expect(matched.first.name, 'Custom BHA');
    });
  });

  group('IngredientsPage Widget Test', () {
    testWidgets('renders dynamic ingredients from ingredientsProvider', (
      tester,
    ) async {
      final mockData = <Ingredient>[
        const Ingredient(
          name: 'Dynamic Niacinamide',
          category: IngredientCategory.brightening,
          summary: 'From Supabase database',
          goodFor: ['Oily', 'Pigmentation'],
          note: '',
        ),
        const Ingredient(
          name: 'Dynamic Salicylic Acid',
          category: IngredientCategory.acne,
          summary: 'From Supabase database',
          goodFor: ['Oily', 'Acne'],
          note: '',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith(() => _StubProfile('Tester')),
            ingredientsProvider.overrideWith((ref) => Future.value(mockData)),
          ],
          child: const MaterialApp(
            home: IngredientsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dynamic Niacinamide'), findsOneWidget);
      expect(find.text('Dynamic Salicylic Acid'), findsOneWidget);

      // Test searching
      await tester.enterText(find.byType(TextField), 'Salicylic');
      await tester.pumpAndSettle();

      expect(find.text('Dynamic Salicylic Acid'), findsOneWidget);
      expect(find.text('Dynamic Niacinamide'), findsNothing);
    });

    testWidgets('shows error state when ingredientsProvider throws', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith(() => _StubProfile('Tester')),
            ingredientsProvider.overrideWith(
              (ref) => Future.error(Exception('Network error')),
            ),
          ],
          child: const MaterialApp(
            home: IngredientsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load ingredients'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('IngredientDetailPage Widget Test', () {
    testWidgets('displays ingredient details and pairing links', (
      tester,
    ) async {
      const ingredient = Ingredient(
        name: 'Ceramides',
        category: IngredientCategory.wrinkle,
        summary: 'Reinforces the skin barrier',
        goodFor: ['Dry', 'Wrinkles'],
        note: '',
        useTime: 'Morning and night',
        whatItDoes: 'Essential lipids that naturally form part of skin.',
        pairsWellWith: [
          IngredientPairing(
            name: 'Hyaluronic Acid',
            reason: 'To lock in moisture',
          ),
        ],
        avoidWith: [
          IngredientPairing(
            name: 'Strong Acid',
            reason: 'May cause stinging',
          ),
        ],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IngredientDetailPage(ingredient: ingredient),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ceramides'), findsOneWidget);
      expect(find.text('Reinforces the skin barrier'), findsNothing); // whatItDoes takes precedence
      expect(find.text('Essential lipids that naturally form part of skin.'), findsOneWidget);
      expect(find.text('Pairs Well With'), findsOneWidget);
      expect(find.text('Hyaluronic Acid'), findsOneWidget);
      expect(find.text('Avoid With'), findsOneWidget);
      expect(find.text('Strong Acid'), findsOneWidget);
    });

    testWidgets('separates "helps with" with comma instead of & and fits narrow mobile screens', (
      tester,
    ) async {
      // Set narrow screen size (e.g. small mobile)
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const ingredient = Ingredient(
        name: 'Multi-Target Active',
        category: IngredientCategory.brightening,
        summary: 'Targeted care',
        goodFor: ['Acne', 'Redness', 'Pigmentation', 'Wrinkles'],
        note: '',
        helpsWith: 'Dark spots & enlarged pores & stubborn texture',
        bestFor: 'Oily, Combination, Normal & Sensitive skin types',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IngredientDetailPage(ingredient: ingredient),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check comma separation
      expect(
        find.text('Dark spots, enlarged pores, stubborn texture'),
        findsOneWidget,
      );
      expect(
        find.text('Oily, Combination, Normal, Sensitive skin types'),
        findsOneWidget,
      );

      // Verify no RenderFlex overflow exception was thrown
      expect(tester.takeException(), isNull);
    });
  });
}
