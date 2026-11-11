import 'package:flutter/material.dart';

/// The main concern an ingredient is filed under in the library.
enum IngredientCategory {
  acne('Acne', Icons.healing),
  brightening('Brightening', Icons.auto_awesome),
  wrinkle('Wrinkle', Icons.waves),
  redness('Redness', Icons.local_fire_department),
  hydrating('Hydrating', Icons.water_drop);

  const IngredientCategory(this.label, this.icon);

  /// Display name, also used by the filter chips.
  final String label;

  /// Concern glyph shown on the corner badge of the library cards.
  final IconData icon;
}

/// An ingredient pairing recommendation with rationale.
class IngredientPairing {
  const IngredientPairing({
    required this.name,
    required this.reason,
  });

  /// Name of the paired ingredient.
  final String name;

  /// Why this pairing works well (e.g. "For dark spot", "To lock in hydration").
  final String reason;
}

/// Helper to resolve category and labels from conditions and skin types.
class IngredientCategoryHelper {
  static IngredientCategory determineCategory({
    required Iterable<String> conditions,
    required Iterable<String> skinTypes,
  }) {
    final conditionSet = conditions.map((c) => c.toLowerCase()).toSet();

    if (conditionSet.contains('acne')) return IngredientCategory.acne;
    if (conditionSet.contains('pigmentation') ||
        conditionSet.contains('brightening') ||
        conditionSet.contains('hyperpigmentation')) {
      return IngredientCategory.brightening;
    }
    if (conditionSet.contains('wrinkles') || conditionSet.contains('wrinkle')) {
      return IngredientCategory.wrinkle;
    }
    if (conditionSet.contains('redness')) return IngredientCategory.redness;

    final skinSet = skinTypes.map((s) => s.toLowerCase()).toSet();
    if (skinSet.contains('dry') || skinSet.contains('hydrating')) {
      return IngredientCategory.hydrating;
    }

    return IngredientCategory.brightening;
  }
}

/// A skincare ingredient, described in general terms for reference only.
class Ingredient {
  const Ingredient({
    this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.goodFor,
    this.note = '',
    this.bestFor,
    this.helpsWith,
    this.useTime,
    this.whatItDoes,
    this.pairsWellWith = const <IngredientPairing>[],
    this.avoidWith = const <IngredientPairing>[],
    this.isActive = true,
  });

  /// Unique identifier in database (UUID).
  final String? id;

  final String name;

  /// Concern the ingredient is filed under in the library.
  final IngredientCategory category;

  /// General purpose of the ingredient.
  final String summary;

  /// Skin types or conditions it is commonly used for.
  final List<String> goodFor;

  /// Usage consideration worth knowing before adding it to a routine.
  final String note;

  /// Best suited skin types (e.g. "All skin types", "Oily & acne-prone").
  final String? bestFor;

  /// Specific concern targeted (e.g. "Dehydration", "Acne & breakouts").
  final String? helpsWith;

  /// Recommended time of use (e.g. "Morning and night", "Night only").
  final String? useTime;

  /// Detailed description for the "What It Does" section.
  final String? whatItDoes;

  /// Recommended ingredients to pair with for synergistic benefits.
  final List<IngredientPairing> pairsWellWith;

  /// Ingredients to avoid combining with to prevent irritation or conflict.
  final List<IngredientPairing> avoidWith;

  /// Whether the ingredient is active in the library.
  final bool isActive;

  /// Constructs an [Ingredient] from Supabase database tables:
  /// [row] from `public.ingredients`,
  /// [suitabilities] from `public.ingredient_suitability`,
  /// [pairings] from `public.ingredient_pairings`,
  /// and [idToIngredientLookup] mapping UUID -> ingredient row.
  factory Ingredient.fromDatabase({
    required Map<String, dynamic> row,
    List<Map<String, dynamic>> suitabilities = const [],
    List<Map<String, dynamic>> pairings = const [],
    Map<String, Map<String, dynamic>> idToIngredientLookup = const {},
  }) {
    final id = row['id']?.toString();
    final name = (row['name'] as String?)?.trim() ?? '';
    final summary = (row['summary'] as String?)?.trim() ?? '';
    final useTime = (row['use_time'] as String?)?.trim();
    final whatItDoes = (row['what_it_does'] as String?)?.trim();
    final isActive = row['is_active'] as bool? ?? true;

    final skinTypes = <String>[];
    final conditions = <String>[];

    for (final s in suitabilities) {
      final kind = s['kind']?.toString().toLowerCase().trim();
      final val = s['value']?.toString().toLowerCase().trim();
      if (val == null || val.isEmpty) continue;

      if (kind == 'skin_type') {
        skinTypes.add(_formatSkinType(val));
      } else if (kind == 'condition') {
        conditions.add(_formatCondition(val));
      }
    }

    final goodFor = <String>[
      ...skinTypes,
      ...conditions,
    ];

    final category = IngredientCategoryHelper.determineCategory(
      conditions: conditions,
      skinTypes: skinTypes,
    );

    final pairsWellWith = <IngredientPairing>[];
    final avoidWith = <IngredientPairing>[];

    for (final p in pairings) {
      final kind = p['kind']?.toString().toLowerCase().trim();
      final pairedId = p['paired_ingredient_id']?.toString();
      final paired = idToIngredientLookup[pairedId];
      if (paired == null) continue;

      final pairedName = (paired['name'] as String?)?.trim() ?? '';
      final pairedSummary = (paired['summary'] as String?)?.trim() ?? '';
      if (pairedName.isEmpty) continue;

      final pairing = IngredientPairing(
        name: pairedName,
        reason: pairedSummary,
      );

      if (kind == 'avoid_with') {
        avoidWith.add(pairing);
      } else {
        pairsWellWith.add(pairing);
      }
    }

    String? bestFor;
    if (skinTypes.length >= 4) {
      bestFor = 'All skin types';
    } else if (skinTypes.isNotEmpty) {
      bestFor = '${skinTypes.join(", ")} skin';
    }

    String? helpsWith;
    if (conditions.isNotEmpty) {
      helpsWith = conditions.join(', ');
    }

    return Ingredient(
      id: id,
      name: name,
      category: category,
      summary: summary,
      goodFor: goodFor,
      bestFor: bestFor,
      helpsWith: helpsWith,
      useTime: useTime,
      whatItDoes: whatItDoes,
      pairsWellWith: pairsWellWith,
      avoidWith: avoidWith,
      isActive: isActive,
    );
  }
}

/// General skincare reference, not medical advice.
const List<Ingredient> ingredientLibrary = <Ingredient>[
  Ingredient(
    name: 'Hyaluronic Acid',
    category: IngredientCategory.hydrating,
    summary: 'Holds water in the skin to keep it hydrated and plump.',
    goodFor: <String>['Dry', 'Normal', 'Wrinkles'],
    note: 'Apply to slightly damp skin, then seal with a moisturiser.',
    bestFor: 'All skin types',
    helpsWith: 'Dehydration',
    useTime: 'Morning and night',
    whatItDoes:
        'Hyaluronic acid draws water into the outer layer of skin, helping it feel soft, smooth and bouncy. It works best with a moisturizer that locks that water in.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Niacinamide', reason: 'For dark spot'),
      IngredientPairing(name: 'Alpha Arbutin', reason: 'For brightening'),
      IngredientPairing(name: 'Ceramides', reason: 'To lock in hydration'),
    ],
  ),
  Ingredient(
    name: 'Niacinamide',
    category: IngredientCategory.brightening,
    summary: 'Supports the skin barrier and helps even out skin tone.',
    goodFor: <String>['Oily', 'Combination', 'Hyperpigmentation'],
    note: 'Introduce gradually if your skin is not used to it.',
    bestFor: 'All skin types',
    helpsWith: 'Dark spots & pores',
    useTime: 'Morning and night',
    whatItDoes:
        'Niacinamide (vitamin B3) helps calm redness, refine pore appearance, regulate excess sebum, and fade dark spots over time.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'For extra hydration'),
      IngredientPairing(name: 'Alpha Arbutin', reason: 'For targeted dark spots'),
      IngredientPairing(name: 'Salicylic Acid', reason: 'For clear pores'),
    ],
  ),
  Ingredient(
    name: 'Salicylic Acid',
    category: IngredientCategory.acne,
    summary: 'Helps clear pores and calm breakouts.',
    goodFor: <String>['Oily', 'Acne'],
    note: 'Can be drying, so avoid stacking it with other strong actives.',
    bestFor: 'Oily & acne-prone',
    helpsWith: 'Blackheads & breakouts',
    useTime: 'Night (2-3x a week)',
    whatItDoes:
        'A beta-hydroxy acid (BHA) that penetrates deep into oil-filled pores to dissolve dead skin cells, unclog blockages, and reduce acne inflammation.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Niacinamide', reason: 'To calm inflammation'),
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'To restore moisture'),
      IngredientPairing(name: 'Ceramides', reason: 'To support the barrier'),
    ],
  ),
  Ingredient(
    name: 'Retinol',
    category: IngredientCategory.wrinkle,
    summary: 'Encourages cell turnover and softens the look of fine lines.',
    goodFor: <String>['Wrinkles', 'Normal'],
    note: 'Use at night and always follow up with sunscreen.',
    bestFor: 'Mature & textured skin',
    helpsWith: 'Fine lines & wrinkles',
    useTime: 'Night only',
    whatItDoes:
        'A vitamin A derivative that accelerates cellular renewal, boosts collagen synthesis, and smooths overall skin texture over regular use.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'To prevent dryness'),
      IngredientPairing(name: 'Ceramides', reason: 'To shield barrier'),
      IngredientPairing(name: 'Peptide', reason: 'To enhance firmness'),
    ],
  ),
  Ingredient(
    name: 'Vitamin C',
    category: IngredientCategory.brightening,
    summary: 'An antioxidant that helps brighten dull-looking skin.',
    goodFor: <String>['Normal', 'Combination', 'Hyperpigmentation'],
    note: 'Store away from direct light, as it degrades over time.',
    bestFor: 'Dull & uneven skin',
    helpsWith: 'Hyperpigmentation & glow',
    useTime: 'Morning preferred',
    whatItDoes:
        'A potent antioxidant that neutralizes free radical damage, inhibits melanin production to fade sun spots, and revives radiant glow.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'For dewy hydration'),
      IngredientPairing(name: 'Alpha Arbutin', reason: 'For brightening synergy'),
    ],
  ),
  Ingredient(
    name: 'Ceramides',
    category: IngredientCategory.wrinkle,
    summary: 'Reinforce the skin barrier and reduce moisture loss.',
    goodFor: <String>['Dry', 'Wrinkles'],
    note: 'Layers well with most other ingredients.',
    bestFor: 'Dry & compromised skin',
    helpsWith: 'Barrier repair & dryness',
    useTime: 'Morning and night',
    whatItDoes:
        'Essential lipids that naturally form part of the skin moisture barrier, preventing transepidermal water loss and protecting against irritation.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'To lock in moisture'),
      IngredientPairing(name: 'Retinol', reason: 'To buffer irritation'),
    ],
  ),
  Ingredient(
    name: 'Azelaic Acid',
    category: IngredientCategory.acne,
    summary: 'Helps calm the look of redness and uneven tone.',
    goodFor: <String>['Redness', 'Acne Scars'],
    note: 'Ease into daily use if your skin feels reactive at first.',
    bestFor: 'Sensitive & redness-prone',
    helpsWith: 'Redness & post-acne marks',
    useTime: 'Morning and night',
    whatItDoes:
        'A gentle dicarboxylic acid that soothes flushing, clears breakout-causing bacteria, and fades stubborn post-inflammatory erythema.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Niacinamide', reason: 'For even tone'),
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'For calming moisture'),
    ],
  ),
  Ingredient(
    name: 'Glycolic Acid',
    category: IngredientCategory.acne,
    summary: 'Exfoliates the surface of the skin to smooth texture.',
    goodFor: <String>['Oily', 'Acne Scars'],
    note: 'Keep it to a few times a week and skip retinol on the same night.',
    bestFor: 'Dull & rough texture',
    helpsWith: 'Roughness & dullness',
    useTime: 'Night (1-2x a week)',
    whatItDoes:
        'An alpha-hydroxy acid (AHA) with small molecular size that gently breaks down bonds between dead surface skin cells to reveal smoother skin.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'For rehydration'),
      IngredientPairing(name: 'Ceramides', reason: 'To protect barrier'),
    ],
  ),
  Ingredient(
    name: 'Tea Tree Oil',
    category: IngredientCategory.acne,
    summary: 'A botanical oil used to calm blemish-prone skin.',
    goodFor: <String>['Oily', 'Acne'],
    note: 'Dilute before use, as it can irritate skin applied neat.',
    bestFor: 'Blemish-prone skin',
    helpsWith: 'Active breakouts',
    useTime: 'Morning and night',
    whatItDoes:
        'Contains terpinen-4-ol, a natural antimicrobial compound that helps clear bacteria and reduce swelling around active blemishes.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'To maintain moisture balance'),
      IngredientPairing(name: 'Niacinamide', reason: 'To calm irritation'),
    ],
  ),
  Ingredient(
    name: 'Alpha Arbutin',
    category: IngredientCategory.brightening,
    summary: 'Helps fade the look of dark spots and uneven tone.',
    goodFor: <String>['Normal', 'Hyperpigmentation'],
    note: 'Pair it with sunscreen for the best results.',
    bestFor: 'Hyperpigmentation & spots',
    helpsWith: 'Sun spots & blemish marks',
    useTime: 'Morning and night',
    whatItDoes:
        'A gentle skin-brightening derivative that slows tyrosinase activity to prevent and diminish brown spots without harsh bleaching.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Niacinamide', reason: 'For dark spot clarity'),
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'To boost absorption'),
      IngredientPairing(name: 'Vitamin C', reason: 'For enhanced radiance'),
    ],
  ),
  Ingredient(
    name: 'Peptide',
    category: IngredientCategory.wrinkle,
    summary: 'Supports the skin barrier and helps firm the look of skin.',
    goodFor: <String>['Dry', 'Wrinkles'],
    note: 'Gentle enough to use twice a day with most routines.',
    bestFor: 'Loss of elasticity',
    helpsWith: 'Firmness & fine lines',
    useTime: 'Morning and night',
    whatItDoes:
        'Short chains of amino acids that serve as building blocks for proteins like collagen and elastin, signaling skin to maintain firmness and bounce.',
    pairsWellWith: <IngredientPairing>[
      IngredientPairing(name: 'Hyaluronic Acid', reason: 'For plumpness'),
      IngredientPairing(name: 'Retinol', reason: 'For anti-aging synergy'),
      IngredientPairing(name: 'Niacinamide', reason: 'For healthy barrier'),
    ],
  ),
];

/// Ingredients in the library, filtered by [category] (null keeps every
/// category) and by a free-text [query] against the name, category and the
/// concerns it targets. Results keep the library order.
List<Ingredient> filterIngredients({
  List<Ingredient>? ingredients,
  IngredientCategory? category,
  String query = '',
}) {
  final pool = ingredients ?? ingredientLibrary;
  final needle = query.trim().toLowerCase();

  return pool.where((ingredient) {
    if (category != null && !targetsConcern(ingredient, category)) {
      return false;
    }
    if (needle.isEmpty) return true;

    return ingredient.name.toLowerCase().contains(needle) ||
        ingredient.category.label.toLowerCase().contains(needle) ||
        ingredient.goodFor.any((tag) => tag.toLowerCase().contains(needle));
  }).toList(growable: false);
}

/// Whether [ingredient] targets [category], either as its main category or as
/// one of the concerns it is used for ("Wrinkle" also matches "Wrinkles").
bool targetsConcern(Ingredient ingredient, IngredientCategory category) {
  if (ingredient.category == category) return true;

  return ingredient.goodFor.any(
    (tag) => _matchesCategory(tag, category),
  );
}

bool _matchesCategory(String tag, IngredientCategory category) {
  final cleanTag = _singular(tag);
  final cleanCategory = _singular(category.label);
  if (cleanTag == cleanCategory) return true;

  switch (category) {
    case IngredientCategory.brightening:
      return cleanTag == 'pigmentation' || cleanTag == 'hyperpigmentation';
    case IngredientCategory.hydrating:
      return cleanTag == 'dry' || cleanTag == 'hydration';
    case IngredientCategory.wrinkle:
      return cleanTag == 'wrinkle';
    case IngredientCategory.acne:
      return cleanTag == 'acne';
    case IngredientCategory.redness:
      return cleanTag == 'redness';
  }
}

String _singular(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r's$'), '');

String _formatSkinType(String value) {
  switch (value.toLowerCase()) {
    case 'normal':
      return 'Normal';
    case 'dry':
      return 'Dry';
    case 'oily':
      return 'Oily';
    case 'combination':
      return 'Combination';
    default:
      return value.isNotEmpty
          ? '${value[0].toUpperCase()}${value.substring(1)}'
          : value;
  }
}

String _formatCondition(String value) {
  switch (value.toLowerCase()) {
    case 'acne':
      return 'Acne';
    case 'pigmentation':
      return 'Pigmentation';
    case 'redness':
      return 'Redness';
    case 'wrinkles':
    case 'wrinkle':
      return 'Wrinkles';
    default:
      return value.isNotEmpty
          ? '${value[0].toUpperCase()}${value.substring(1)}'
          : value;
  }
}
