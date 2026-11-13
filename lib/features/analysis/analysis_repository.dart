import 'package:image_picker/image_picker.dart';
import 'package:berseri/core/supabase/supabase_service.dart';
import 'package:berseri/features/analysis/analysis_draft.dart';
import 'package:berseri/features/analysis/analysis_entry.dart';
import 'package:berseri/features/analysis/condition_scores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalysisRepository {
  AnalysisRepository(this._client);

  final SupabaseClient _client;
  static const String photoBucket = 'analysis-photos';
  static const int photoUrlTtlSeconds = 3600;

  static const String _columns = 'id, skin_type, skin_type_confidence, '
      'conditions, questionnaire_answers, recommended_ingredient_ids, '
      'photo_path, created_at';

  Future<List<AnalysisEntry>> fetchHistory() async {
    final rows = await _selectRows();
    if (rows.isEmpty) return const <AnalysisEntry>[];
    return _toEntries(rows);
  }

  Future<AnalysisEntry?> fetchLatest() async {
    final rows = await _selectRows(limit: 1);
    if (rows.isEmpty) return null;
    return (await _toEntries(rows)).first;
  }

  Future<AnalysisEntry> save(
    AnalysisDraft draft, {
    String? photoPath,
  }) async {
    final skinType = draft.skinType;
    if (skinType == null) {
      throw StateError('Finish the questionnaire before saving.');
    }

    final storedPhoto = photoPath ?? await uploadPhoto(draft.photo);

    final conditions = <String, double>{
      for (final condition in visibleConditionsOf(draft.conditionScores))
        condition: draft.conditionScores[condition]!,
    };
    final ingredientIds = await recommendedIngredientIds(
      skinType: skinType.value,
      conditions: conditions.keys,
    );

    final row = await _client
        .from('analyses')
        .insert({
          'user_id': _requireUserId(),
          'skin_type': skinType.value,
          'skin_type_confidence': draft.skinTypeConfidence,
          'conditions': conditions,
          'questionnaire_answers': draft.answers,
          'recommended_ingredient_ids': ingredientIds,
          'photo_path': storedPhoto,
        })
        .select(_columns)
        .single();

    return (await _toEntries([row])).first;
  }

  Future<List<String>> recommendedIngredientIds({
    required String skinType,
    Iterable<String> conditions = const <String>[],
  }) async {
    final conditionValues = conditions
        .map((condition) => condition.toLowerCase())
        .toSet()
        .toList(growable: false);

    final responses = await Future.wait([
      _client
          .from('ingredient_suitability')
          .select('ingredient_id')
          .eq('kind', 'skin_type')
          .eq('value', skinType.toLowerCase()),
      if (conditionValues.isNotEmpty)
        _client
            .from('ingredient_suitability')
            .select('ingredient_id')
            .eq('kind', 'condition')
            .inFilter('value', conditionValues),
    ]);

    final matches = <String, int>{};
    for (final response in responses) {
      for (final row in (response as List).cast<Map<String, dynamic>>()) {
        final id = row['ingredient_id']?.toString();
        if (id == null || id.isEmpty) continue;
        matches[id] = (matches[id] ?? 0) + 1;
      }
    }
    if (matches.isEmpty) return const <String>[];

    final ingredients = await _ingredients(matches.keys);
    return matches.keys.toList()
      ..sort((a, b) {
        final byMatches = matches[b]!.compareTo(matches[a]!);
        if (byMatches != 0) return byMatches;
        return (ingredients[a]?.name ?? '').compareTo(
          ingredients[b]?.name ?? '',
        );
      });
  }

  Future<List<Map<String, dynamic>>> _selectRows({int? limit}) async {
    final query = _client
        .from('analyses')
        .select(_columns)
        .order('created_at', ascending: false);

    final rows = await (limit == null ? query : query.limit(limit));
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<AnalysisEntry>> _toEntries(List<Map<String, dynamic>> rows) async {
    final ingredients = await _ingredients(_referencedIds(rows));
    final photoUrls = await _photoUrls(rows);

    return [
      for (final row in rows)
        AnalysisEntry.fromRow(
          row,
          ingredientsById: ingredients,
          photoUrl: photoUrls[_photoPath(row['photo_path'])],
        ),
    ];
  }

  Future<String?> uploadPhoto(XFile? photo) async {
    if (photo == null) return null;

    final bytes = await photo.readAsBytes();
    if (bytes.isEmpty) return null;

    final objectPath =
        '${_requireUserId()}/${DateTime.now().millisecondsSinceEpoch}'
        '${_extension(photo.path)}';

    await _client.storage
        .from(photoBucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(objectPath),
            cacheControl: '3600',
          ),
        );

    return objectPath;
  }

  Future<Map<String, String>> _photoUrls(
    List<Map<String, dynamic>> rows,
  ) async {
    final paths = <String>{
      for (final row in rows) ?_photoPath(row['photo_path']),
    };
    if (paths.isEmpty) return const <String, String>{};

    try {
      final results = await _client.storage
          .from(photoBucket)
          .createSignedUrlsResult(
            paths.toList(growable: false),
            photoUrlTtlSeconds,
          );

      return {
        for (final result in results)
          if (result case SignedUrlSuccess(:final path, :final signedUrl))
            path: signedUrl,
      };
    } on Exception {
      return const <String, String>{};
    }
  }

  Future<Map<String, IngredientSummary>> _ingredients(
    Iterable<String> ids,
  ) async {
    if (ids.isEmpty) return const <String, IngredientSummary>{};

    final result = await _client
        .from('ingredients')
        .select('id, name, summary')
        .inFilter('id', ids.toList(growable: false));

    return {
      for (final row in (result as List).cast<Map<String, dynamic>>())
        if (row['id'] case final id?)
          id.toString(): IngredientSummary(
            id: id.toString(),
            name: (row['name'] as String?)?.trim() ?? '',
            summary: (row['summary'] as String?)?.trim() ?? '',
          ),
    };
  }

  static Set<String> _referencedIds(List<Map<String, dynamic>> rows) => {
    for (final row in rows)
      if (row['recommended_ingredient_ids'] case final List list)
        ...list.map((id) => id?.toString()).whereType<String>(),
  };

  String _requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('Sign in to save an analysis.');
    }
    return id;
  }

  static String? _photoPath(Object? raw) {
    final path = raw?.toString().trim();
    return path == null || path.isEmpty ? null : path;
  }

  static String _extension(String path) {
    final dot = path.lastIndexOf('.');
    final extension = dot == -1 ? '' : path.substring(dot).toLowerCase();
    return const {'.jpg', '.jpeg', '.png', '.webp'}.contains(extension)
        ? extension
        : '.jpg';
  }

  static String _contentType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

final analysisRepositoryProvider = Provider<AnalysisRepository>(
  (ref) => AnalysisRepository(ref.watch(supabaseClientProvider)),
);

final analysisHistoryEntriesProvider =
    FutureProvider.autoDispose<List<AnalysisEntry>>((ref) async {
      return ref.watch(analysisRepositoryProvider).fetchHistory();
    });

final latestAnalysisEntryProvider =
    FutureProvider.autoDispose<AnalysisEntry?>((ref) async {
      return ref.watch(analysisRepositoryProvider).fetchLatest();
    });

final analysisDraftProvider =
    NotifierProvider<AnalysisDraftNotifier, AnalysisDraft?>(
      AnalysisDraftNotifier.new,
    );

class AnalysisDraftNotifier extends Notifier<AnalysisDraft?> {
  @override
  AnalysisDraft? build() => null;

  void start(AnalysisDraft draft) => state = draft;

  void update(AnalysisDraft draft) => state = draft;

  void clear() => state = null;
}
