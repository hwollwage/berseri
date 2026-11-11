import 'dart:developer' as developer;

import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:berseri/features/ingredients/ingredient.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IngredientRepository {
  IngredientRepository([this._client]);

  final SupabaseClient? _client;

  Future<List<Ingredient>> fetchIngredients() async {
    final client = _client;
    if (client == null) {
      return ingredientLibrary;
    }

    try {
      final results = await Future.wait([
        client
            .from('ingredients')
            .select()
            .eq('is_active', true)
            .order('name'),
        client.from('ingredient_suitability').select(),
        client.from('ingredient_pairings').select(),
      ]);

      final ingredientRows =
          (results[0] as List).cast<Map<String, dynamic>>();
      final suitabilityRows =
          (results[1] as List).cast<Map<String, dynamic>>();
      final pairingsRows =
          (results[2] as List).cast<Map<String, dynamic>>();

      if (ingredientRows.isEmpty) {
        return const <Ingredient>[];
      }

      final idToIngredient = <String, Map<String, dynamic>>{};
      for (final row in ingredientRows) {
        final id = row['id']?.toString();
        if (id != null) {
          idToIngredient[id] = row;
        }
      }

      final suitabilityByIngredient = <String, List<Map<String, dynamic>>>{};
      for (final row in suitabilityRows) {
        final ingId = row['ingredient_id']?.toString();
        if (ingId != null) {
          suitabilityByIngredient.putIfAbsent(ingId, () => []).add(row);
        }
      }

      final pairingsByIngredient = <String, List<Map<String, dynamic>>>{};
      for (final row in pairingsRows) {
        final ingId = row['ingredient_id']?.toString();
        if (ingId != null) {
          pairingsByIngredient.putIfAbsent(ingId, () => []).add(row);
        }
      }

      return ingredientRows.map((row) {
        final id = row['id']?.toString() ?? '';
        final suits = suitabilityByIngredient[id] ?? const [];
        final pairs = pairingsByIngredient[id] ?? const [];

        return Ingredient.fromDatabase(
          row: row,
          suitabilities: suits,
          pairings: pairs,
          idToIngredientLookup: idToIngredient,
        );
      }).toList(growable: false);
    } catch (e, st) {
      developer.log(
        'Error fetching ingredients from Supabase: $e',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}

final ingredientRepositoryProvider = Provider<IngredientRepository>((ref) {
  try {
    return IngredientRepository(ref.watch(supabaseClientProvider));
  } catch (_) {
    return IngredientRepository(null);
  }
});

final ingredientsProvider = FutureProvider<List<Ingredient>>((ref) async {
  final repository = ref.watch(ingredientRepositoryProvider);
  return repository.fetchIngredients();
});
