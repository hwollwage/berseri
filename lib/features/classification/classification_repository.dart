import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/features/classification/skin_classification.dart';

// masih placeholder

class ClassificationRepository {
  final Dio _dio;

  ClassificationRepository(
    this._dio
  );

  Future<SkinClassification> classifyImage(File image) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: 'photo_berseri.jpg'),
    });

    final response = await _dio.post(
      '/predict', // path endpoint flask di HF sp
      data: formData,
    );

    return SkinClassification.fromJson(response.data as Map<String, dynamic>);
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'http://localhost:3000 (pokoknya flask servernya)',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));
});

final classificationRepositoryProvider = Provider<ClassificationRepository>((ref) {
  return ClassificationRepository(ref.watch(dioProvider));
});