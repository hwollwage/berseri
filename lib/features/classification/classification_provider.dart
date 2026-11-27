import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/features/classification/classification_repository.dart';
import 'package:berseri/features/classification/domain/classification_result.dart';

class ClassificationNotifier extends AsyncNotifier<ClassificationResult?> {
  @override
  Future<ClassificationResult?> build() async => null;

  Future<void> classify(File image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(classificationRepositoryProvider).classifyImage(image),
    );
  }

  void reset() => state = const AsyncData(null);
}

final classificationProvider =
    AsyncNotifierProvider<ClassificationNotifier, ClassificationResult?>(
      ClassificationNotifier.new,
    );
