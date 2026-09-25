import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/features/classification/skin_classification.dart';
import 'package:berseri/features/classification/classification_repository.dart';

// masih placeholder

class ClassificationNotifier extends AsyncNotifier<SkinClassification?> {
  @override
  Future<SkinClassification?> build() async => null;

  Future<void> classify(File image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(classificationRepositoryProvider).classifyImage(image);
    });
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final classificationProvider = AsyncNotifierProvider<ClassificationNotifier, SkinClassification?>(ClassificationNotifier.new);