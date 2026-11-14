import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/features/classification/data/skin_condition_service.dart';
import 'package:berseri/features/classification/domain/skin_condition_result.dart';

class ClassificationRepository {
  ClassificationRepository(this._conditionService);

  final SkinConditionService _conditionService;

  Future<SkinConditionResult> classifyImage(File image) async {
    final detections = await _conditionService.predict(image);

    final scores = <String, double>{};
    for (final detection in detections) {
      final previous = scores[detection.label];
      if (previous == null || detection.confidence > previous) {
        scores[detection.label] = detection.confidence;
      }
    }

    final ordered = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SkinConditionResult({
      for (final entry in ordered) entry.key: entry.value,
    });
  }

  Future<void> dispose() async {
    await _conditionService.dispose();
  }
}

final classificationRepositoryProvider = Provider<ClassificationRepository>((
  ref,
) {
  final repository = ClassificationRepository(SkinConditionService());

  ref.onDispose(repository.dispose);

  return repository;
});
