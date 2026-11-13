import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:berseri/features/classification/skin_classification.dart';
import 'package:berseri/features/classification/skin_onnx_service.dart';

class ClassificationRepository {
  final SkinOnnxService _onnxService;

  ClassificationRepository(this._onnxService);

  Future<SkinClassification> classifyImage(File image) async {
    final detections = await _onnxService.predict(image);

    final scores = <String, double>{};
    for (final detection in detections) {
      final previous = scores[detection.label];
      if (previous == null || detection.confidence > previous) {
        scores[detection.label] = detection.confidence;
      }
    }

    final ordered = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SkinClassification({
      for (final entry in ordered) entry.key: entry.value,
    });
  }

  Future<void> dispose() async {
    await _onnxService.dispose();
  }
}

final classificationRepositoryProvider = Provider<ClassificationRepository>((
  ref,
) {
  final repository = ClassificationRepository(SkinOnnxService());

  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});
