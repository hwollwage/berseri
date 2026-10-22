import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:berseri/features/classification/skin_classification.dart';
import 'package:berseri/features/classification/skin_onnx_service.dart';

class ClassificationRepository {
  final SkinOnnxService _onnxService;

  ClassificationRepository(this._onnxService);

  Future<SkinClassification> classifyImage(File image) async {
    final detections = await _onnxService.predict(image);

    if (detections.isEmpty) {
      return const SkinClassification(
        label: 'No condition detected',
        confidence: 0,
        conditions: [],
      );
    }

    final best = detections.first;

    final conditions = detections
        .map((detection) => detection.label)
        .toSet()
        .toList(growable: false);

    return SkinClassification(
      label: best.label,
      confidence: best.confidence,
      conditions: conditions,
    );
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
