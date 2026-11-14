import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/features/classification/classification_repository.dart';
import 'package:berseri/features/classification/domain/skin_condition_result.dart';

class ClassificationNotifier extends AsyncNotifier<SkinConditionResult?> {
  @override
  Future<SkinConditionResult?> build() async => null;

  Future<void> classify(File image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        return await ref
            .read(classificationRepositoryProvider)
            .classifyImage(image);
      } catch (e, stackTrace) {
        debugPrint('Classification error: $e');
        debugPrintStack(stackTrace: stackTrace);
        rethrow;
      }
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final classificationProvider =
    AsyncNotifierProvider<ClassificationNotifier, SkinConditionResult?>(
      ClassificationNotifier.new,
    );
