import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:berseri/features/classification/data/face_detector_service.dart';
import 'package:berseri/features/classification/data/skin_condition_service.dart';
import 'package:berseri/features/classification/data/skin_type_service.dart';
import 'package:berseri/features/classification/domain/classification_result.dart';

class ClassificationRepository {
  ClassificationRepository(
    this._faceDetector,
    this._skinTypeService,
    this._conditionService,
  );

  final FaceDetectorService _faceDetector;
  final SkinTypeService _skinTypeService;
  final SkinConditionService _conditionService;

  Future<ClassificationResult> classifyImage(File image) async {
    File inputFile = image;
    File? croppedFile;

    try {
      final detection = await _faceDetector.detect(image);
      if (detection != null) {
        final tmp = await getTemporaryDirectory();
        croppedFile = File(
          '${tmp.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await croppedFile.writeAsBytes(detection.croppedBytes);
        inputFile = croppedFile;
      }
    } catch (_) {}

    final skinTypeResult = await _skinTypeService.predict(inputFile);
    final conditionDetections = await _conditionService.predict(inputFile);

    final scores = <String, double>{};
    for (final d in conditionDetections) {
      final prev = scores[d.label];
      if (prev == null || d.confidence > prev) scores[d.label] = d.confidence;
    }
    final ordered = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ClassificationResult(
      skinType: skinTypeResult.topLabel,
      skinTypeConfidence: skinTypeResult.topScore,
      conditionScores: {for (final e in ordered) e.key: e.value},
      croppedFile: croppedFile,
    );
  }

  Future<void> dispose() async {
    await _faceDetector.dispose();
    await _skinTypeService.dispose();
    await _conditionService.dispose();
  }
}

final classificationRepositoryProvider = Provider<ClassificationRepository>((
  ref,
) {
  final repository = ClassificationRepository(
    FaceDetectorService(),
    SkinTypeService(),
    SkinConditionService(),
  );
  ref.onDispose(repository.dispose);
  return repository;
});
