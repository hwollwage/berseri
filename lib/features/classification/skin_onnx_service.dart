import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

class SkinDetection {
  final String label;
  final double confidence;

  const SkinDetection({required this.label, required this.confidence});

  @override
  String toString() {
    return '$label: ${(confidence * 100).toStringAsFixed(2)}%';
  }
}

class SkinOnnxService {
  SkinOnnxService({this.confidenceThreshold = 0.25, this.iouThreshold = 0.45});

  final OnnxRuntime _runtime = OnnxRuntime();

  OrtSession? _session;

  final double confidenceThreshold;
  final double iouThreshold;

  static const int imageSize = 640;
  static const int classCount = 4;
  static const int maskChannels = 32;

  static const List<String> labels = [
    'acne',
    'pigmentation',
    'redness',
    'wrinkles',
  ];

  Future<void> loadModel() async {
    if (_session != null) return;

    final session = await _runtime.createSessionFromAsset(
      'assets/models/skin_condition.onnx',
    );

    _session = session;

    debugPrint('ONNX model loaded');
    debugPrint('Inputs: ${session.inputNames}');
    debugPrint('Outputs: ${session.outputNames}');
  }

  Future<List<SkinDetection>> predict(File imageFile) async {
    await loadModel();

    final session = _session;
    if (session == null) {
      throw StateError('ONNX session belum tersedia.');
    }

    if (!await imageFile.exists()) {
      throw Exception('File gambar tidak ditemukan: ${imageFile.path}');
    }

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Gambar tidak dapat dibaca.');
    }

    // TODO: pastikan resize ini sesuai preprocessing model saat training.
    // Ini adalah direct resize, bukan letterbox.
    final resized = img.copyResize(
      decoded,
      width: imageSize,
      height: imageSize,
    );

    // Input NCHW: [1, 3, 640, 640], RGB, nilai 0 sampai 1.
    final planeSize = imageSize * imageSize;
    final inputData = List<double>.filled(3 * planeSize, 0.0);

    for (var y = 0; y < imageSize; y++) {
      for (var x = 0; x < imageSize; x++) {
        final pixel = resized.getPixel(x, y);
        final pixelIndex = y * imageSize + x;

        inputData[pixelIndex] = pixel.r.toDouble() / 255.0;
        inputData[planeSize + pixelIndex] = pixel.g.toDouble() / 255.0;
        inputData[2 * planeSize + pixelIndex] = pixel.b.toDouble() / 255.0;
      }
    }

    final inputTensor = await OrtValue.fromList(inputData, [
      1,
      3,
      imageSize,
      imageSize,
    ]);

    Map<String, OrtValue>? outputs;

    try {
      outputs = await session.run({session.inputNames.first: inputTensor});

      final output = outputs['output0'];

      if (output == null) {
        throw Exception(
          'Output output0 tidak ditemukan. '
          'Output tersedia: ${outputs.keys.toList()}',
        );
      }

      final shape = output.shape;

      debugPrint('output0 shape: $shape');

      if (shape.length != 3 ||
          shape[0] != 1 ||
          shape[1] != classCount + 4 + maskChannels) {
        throw Exception('Shape output tidak sesuai asumsi YOLOv8-seg: $shape');
      }

      final values = await output.asFlattenedList();

      final expectedLength = shape[0] * shape[1] * shape[2];

      if (values.length != expectedLength) {
        throw Exception(
          'Jumlah data output tidak sesuai. '
          'Expected: $expectedLength, actual: ${values.length}',
        );
      }

      return _parseDetections(
        values,
        numChannels: shape[1],
        numCandidates: shape[2],
      );
    } finally {
      await inputTensor.dispose();

      if (outputs != null) {
        for (final output in outputs.values) {
          await output.dispose();
        }
      }
    }
  }

  List<SkinDetection> _parseDetections(
    List<dynamic> values, {
    required int numChannels,
    required int numCandidates,
  }) {
    final expectedChannels = 4 + classCount + maskChannels;

    if (numChannels != expectedChannels) {
      throw Exception('Expected $expectedChannels channels, got $numChannels.');
    }

    double valueAt(int channel, int candidate) {
      return (values[channel * numCandidates + candidate] as num).toDouble();
    }

    final maxScores = List<double>.filled(classCount, 0.0);
    final candidates = <_Candidate>[];

    for (var i = 0; i < numCandidates; i++) {
      var bestClass = 0;
      var bestScore = double.negativeInfinity;

      // Asumsi: channel 4 sampai 7 berisi skor kelas.
      for (var c = 0; c < classCount; c++) {
        final score = valueAt(4 + c, i);

        if (!score.isFinite) continue;

        if (score > maxScores[c]) {
          maxScores[c] = score;
        }

        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }

      if (!bestScore.isFinite || bestScore < confidenceThreshold) {
        continue;
      }

      final cx = valueAt(0, i);
      final cy = valueAt(1, i);
      final width = valueAt(2, i);
      final height = valueAt(3, i);

      if (!cx.isFinite ||
          !cy.isFinite ||
          !width.isFinite ||
          !height.isFinite ||
          width <= 0 ||
          height <= 0) {
        continue;
      }

      candidates.add(
        _Candidate(
          classId: bestClass,
          confidence: bestScore,
          left: cx - width / 2,
          top: cy - height / 2,
          right: cx + width / 2,
          bottom: cy + height / 2,
        ),
      );
    }

    debugPrint('--- ONNX DEBUG ---');
    debugPrint('Candidates above threshold: ${candidates.length}');

    for (var c = 0; c < classCount; c++) {
      debugPrint('${labels[c]} max score: ${maxScores[c]}');
    }

    final detections = _applyNms(candidates);

    debugPrint('Detections after NMS: ${detections.length}');
    debugPrint('Results: $detections');
    debugPrint('------------------');

    return detections
        .map(
          (candidate) => SkinDetection(
            label: labels[candidate.classId],
            confidence: candidate.confidence,
          ),
        )
        .toList(growable: false);
  }

  List<_Candidate> _applyNms(List<_Candidate> candidates) {
    final kept = <_Candidate>[];

    // NMS dijalankan terpisah untuk setiap kelas.
    for (var classId = 0; classId < classCount; classId++) {
      final remaining =
          candidates.where((candidate) => candidate.classId == classId).toList()
            ..sort((a, b) => b.confidence.compareTo(a.confidence));

      while (remaining.isNotEmpty) {
        final best = remaining.removeAt(0);
        kept.add(best);

        remaining.removeWhere((other) => _iou(best, other) > iouThreshold);
      }
    }

    kept.sort((a, b) => b.confidence.compareTo(a.confidence));

    return kept;
  }

  double _iou(_Candidate a, _Candidate b) {
    final left = a.left > b.left ? a.left : b.left;
    final top = a.top > b.top ? a.top : b.top;
    final right = a.right < b.right ? a.right : b.right;
    final bottom = a.bottom < b.bottom ? a.bottom : b.bottom;

    final intersectionWidth = (right - left).clamp(0.0, double.infinity);
    final intersectionHeight = (bottom - top).clamp(0.0, double.infinity);

    final intersection = intersectionWidth * intersectionHeight;

    final areaA = (a.right - a.left) * (a.bottom - a.top);
    final areaB = (b.right - b.left) * (b.bottom - b.top);
    final union = areaA + areaB - intersection;

    if (union <= 0 || !union.isFinite) return 0.0;

    return intersection / union;
  }

  Future<void> dispose() async {
    final session = _session;
    _session = null;

    await session?.close();
  }
}

class _Candidate {
  final int classId;
  final double confidence;
  final double left;
  final double top;
  final double right;
  final double bottom;

  const _Candidate({
    required this.classId,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}
