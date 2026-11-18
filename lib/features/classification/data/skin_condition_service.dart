import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

const int _kImageSize = 640;

Float32List _preprocess(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('Gambar tidak dapat dibaca.');

  final oriented = img.bakeOrientation(decoded);

  final scale = math.min(_kImageSize / oriented.width, _kImageSize / oriented.height);
  final newW = (oriented.width * scale).round().clamp(1, _kImageSize);
  final newH = (oriented.height * scale).round().clamp(1, _kImageSize);

  final resized = img.copyResize(
    oriented,
    width: newW,
    height: newH,
    interpolation: img.Interpolation.linear,
  );

  final padX = (_kImageSize - newW) ~/ 2;
  final padY = (_kImageSize - newH) ~/ 2;

  final planeSize = _kImageSize * _kImageSize;
  final data = Float32List(3 * planeSize)..fillRange(0, 3 * planeSize, 114 / 255.0);

  for (var y = 0; y < newH; y++) {
    for (var x = 0; x < newW; x++) {
      final pixel = resized.getPixel(x, y);
      final idx = (y + padY) * _kImageSize + (x + padX);
      data[idx] = pixel.r.toDouble() / 255.0;
      data[planeSize + idx] = pixel.g.toDouble() / 255.0;
      data[2 * planeSize + idx] = pixel.b.toDouble() / 255.0;
    }
  }
  return data;
}

class _Candidate {
  const _Candidate({
    required this.classId,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int classId;
  final double confidence;
  final double left, top, right, bottom;
}

class SkinDetection {
  const SkinDetection({required this.label, required this.confidence});

  final String label;
  final double confidence;

  @override
  String toString() => '$label: ${(confidence * 100).toStringAsFixed(1)}%';
}

class SkinConditionService {
  SkinConditionService({
    this.confidenceThreshold = 0.05,
    this.iouThreshold = 0.45,
  });

  final OnnxRuntime _runtime = OnnxRuntime();

  OrtSession? _session;
  Future<void>? _loading;

  final double confidenceThreshold;
  final double iouThreshold;

  static const int imageSize = _kImageSize;
  static const int classCount = 4;
  static const int maskChannels = 32;

  static const List<String> labels = ['acne', 'pigmentation', 'redness', 'wrinkles'];

  Future<void> loadModel() {
    if (_session != null) return Future.value();
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    _session = await _runtime.createSessionFromAsset('assets/models/skin_condition.onnx');
  }

  Future<List<SkinDetection>> predict(File imageFile) async {
    await loadModel();

    if (!await imageFile.exists()) {
      throw Exception('File tidak ditemukan: ${imageFile.path}');
    }

    final bytes = await imageFile.readAsBytes();
    final inputData = await compute(_preprocess, bytes);
    final inputTensor = await OrtValue.fromList(inputData, [1, 3, imageSize, imageSize]);

    Map<String, OrtValue>? outputs;
    try {
      outputs = await _session!.run({_session!.inputNames.first: inputTensor});

      final output = outputs['output0'];
      if (output == null) {
        throw Exception('output0 tidak ada. Tersedia: ${outputs.keys.toList()}');
      }

      final shape = output.shape;
      final expectedCh = 4 + classCount + maskChannels;
      if (shape.length != 3 || shape[0] != 1 || shape[1] != expectedCh) {
        throw Exception('Shape tidak sesuai. Expected [1, $expectedCh, N], got $shape');
      }

      final values = await output.asFlattenedList();
      return _parseDetections(values, numCandidates: shape[2]);
    } finally {
      await inputTensor.dispose();
      if (outputs != null) {
        for (final v in outputs.values) {
          await v.dispose();
        }
      }
    }
  }

  List<SkinDetection> _parseDetections(List<dynamic> values, {required int numCandidates}) {
    double at(int channel, int candidate) =>
        (values[channel * numCandidates + candidate] as num).toDouble();

    final candidates = <_Candidate>[];

    for (var i = 0; i < numCandidates; i++) {
      var bestClass = 0;
      var bestScore = double.negativeInfinity;

      for (var c = 0; c < classCount; c++) {
        final score = at(4 + c, i);
        if (!score.isFinite) continue;
        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }

      if (!bestScore.isFinite || bestScore < confidenceThreshold) continue;

      final cx = at(0, i);
      final cy = at(1, i);
      final w = at(2, i);
      final h = at(3, i);

      if (!cx.isFinite || !cy.isFinite || w <= 0 || h <= 0) continue;

      candidates.add(_Candidate(
        classId: bestClass,
        confidence: bestScore,
        left: cx - w / 2,
        top: cy - h / 2,
        right: cx + w / 2,
        bottom: cy + h / 2,
      ));
    }

    return _applyNms(candidates)
        .map((c) => SkinDetection(label: labels[c.classId], confidence: c.confidence))
        .toList(growable: false);
  }

  List<_Candidate> _applyNms(List<_Candidate> candidates) {
    final kept = <_Candidate>[];
    for (var classId = 0; classId < classCount; classId++) {
      final pool = candidates.where((c) => c.classId == classId).toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      while (pool.isNotEmpty) {
        final best = pool.removeAt(0);
        kept.add(best);
        pool.removeWhere((other) => _iou(best, other) > iouThreshold);
      }
    }
    kept.sort((a, b) => b.confidence.compareTo(a.confidence));
    return kept;
  }

  double _iou(_Candidate a, _Candidate b) {
    final l = math.max(a.left, b.left);
    final t = math.max(a.top, b.top);
    final r = math.min(a.right, b.right);
    final bot = math.min(a.bottom, b.bottom);

    final intersection = (r - l).clamp(0.0, double.infinity) * (bot - t).clamp(0.0, double.infinity);
    final union = (a.right - a.left) * (a.bottom - a.top) + (b.right - b.left) * (b.bottom - b.top) - intersection;

    if (union <= 0 || !union.isFinite) return 0.0;
    return intersection / union;
  }

  Future<void> dispose() async {
    final s = _session;
    _session = null;
    await s?.close();
  }
}
