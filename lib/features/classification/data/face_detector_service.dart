import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceDetectionResult {
  const FaceDetectionResult({
    required this.croppedBytes,
    required this.faceCount,
  });

  final Uint8List croppedBytes;
  final int faceCount;
}

class FaceDetectorService {
  FaceDetectorService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
        enableClassification: false,
        enableTracking: false,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  late final FaceDetector _detector;

  static const double _paddingFactor = 0.2;

  Future<FaceDetectionResult?> detect(File imageFile) async {
    final faces = await _detector.processImage(InputImage.fromFile(imageFile));

    if (faces.isEmpty) return null;

    final face = faces.reduce(
      (a, b) => _area(a.boundingBox) >= _area(b.boundingBox) ? a : b,
    );

    final bytes = await imageFile.readAsBytes();
    final cropped = await compute(_cropFace, _CropArgs(bytes, face.boundingBox));

    return FaceDetectionResult(croppedBytes: cropped, faceCount: faces.length);
  }

  static double _area(Rect r) => r.width * r.height;

  Future<void> dispose() async => _detector.close();
}

class _CropArgs {
  const _CropArgs(this.bytes, this.boundingBox);
  final Uint8List bytes;
  final Rect boundingBox;
}

Uint8List _cropFace(_CropArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) throw Exception('Gambar tidak dapat dibaca.');

  final oriented = img.bakeOrientation(decoded);
  final box = args.boundingBox;

  final padW = (box.width * FaceDetectorService._paddingFactor).round();
  final padH = (box.height * FaceDetectorService._paddingFactor).round();

  final x = (box.left.round() - padW).clamp(0, oriented.width - 1);
  final y = (box.top.round() - padH).clamp(0, oriented.height - 1);
  final w = (box.width.round() + padW * 2).clamp(1, oriented.width - x);
  final h = (box.height.round() + padH * 2).clamp(1, oriented.height - y);

  final cropped = img.copyCrop(oriented, x: x, y: y, width: w, height: h);
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
}
