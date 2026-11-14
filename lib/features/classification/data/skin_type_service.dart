import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import 'package:berseri/features/classification/domain/skin_type_result.dart';

class _PrepArgs {
  const _PrepArgs(this.bytes, this.size);
  final Uint8List bytes;
  final int size;
}

// resize sisi terpendek → [size], center-crop jadi persegi, RGB 0..1, NCHW.
Float32List _preprocessType(_PrepArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) throw Exception('Gambar tidak dapat dibaca.');

  final oriented = img.bakeOrientation(decoded);
  final size = args.size;

  // Sisi terpendek → size, pertahankan proporsi.
  final resized = oriented.width < oriented.height
      ? img.copyResize(
          oriented,
          width: size,
          interpolation: img.Interpolation.linear,
        )
      : img.copyResize(
          oriented,
          height: size,
          interpolation: img.Interpolation.linear,
        );

  // Center crop.
  final offsetX = (resized.width - size) ~/ 2;
  final offsetY = (resized.height - size) ~/ 2;

  final planeSize = size * size;
  final data = Float32List(3 * planeSize);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final pixel = resized.getPixel(x + offsetX, y + offsetY);
      final idx = y * size + x;
      data[idx] = pixel.r.toDouble() / 255.0;
      data[planeSize + idx] = pixel.g.toDouble() / 255.0;
      data[2 * planeSize + idx] = pixel.b.toDouble() / 255.0;
    }
  }
  return data;
}

class SkinTypeService {
  final OnnxRuntime _runtime = OnnxRuntime();

  OrtSession? _session;
  Future<void>? _loading;

  static const int inputSize = 640;

  // urutan sesuai metadata model: {0: combination, 1: dry, 2: normal, 3: oily}
  static const List<String> labels = ['combination', 'dry', 'normal', 'oily'];

  Future<void> loadModel() {
    if (_session != null) return Future.value();
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    final session = await _runtime.createSessionFromAsset(
      'assets/models/skin_type.onnx',
    );
    _session = session;
    debugPrint(
      '[skin_type] loaded — inputs: ${session.inputNames}'
      '  outputs: ${session.outputNames}',
    );
  }

  Future<SkinTypeResult> predict(File imageFile) async {
    await loadModel();

    final session = _session!;

    if (!await imageFile.exists()) {
      throw Exception('File tidak ditemukan: ${imageFile.path}');
    }

    final bytes = await imageFile.readAsBytes();
    final inputData = await compute(
      _preprocessType,
      _PrepArgs(bytes, inputSize),
    );

    final inputTensor = await OrtValue.fromList(inputData, [
      1,
      3,
      inputSize,
      inputSize,
    ]);

    Map<String, OrtValue>? outputs;
    try {
      outputs = await session.run({session.inputNames.first: inputTensor});

      final output = outputs[session.outputNames.first];
      if (output == null) {
        throw Exception('Output tidak ada. Tersedia: ${outputs.keys}');
      }

      debugPrint('[skin_type] output shape: ${output.shape}');

      // Output shape [1, 4] — flatten jadi 4 nilai probabilitas.
      final raw = (await output.asFlattenedList())
          .map((v) => (v as num).toDouble())
          .toList();

      debugPrint(
        '[skin_type] raw probs: $raw  sum=${raw.fold(0.0, (a, b) => a + b)}',
      );

      if (raw.length != labels.length) {
        throw Exception(
          'Output length ${raw.length} != ${labels.length} labels. '
          'Shape: ${output.shape}',
        );
      }

      // Model sudah Softmax — gunakan langsung.
      // Kalau ternyata logits (sum jauh dari 1), fallback ke softmax.
      final probs = _ensureProbabilities(raw);

      final entries = [
        for (var i = 0; i < labels.length; i++) MapEntry(labels[i], probs[i]),
      ]..sort((a, b) => b.value.compareTo(a.value));

      debugPrint('[skin_type] result: $entries');
      return SkinTypeResult(Map.fromEntries(entries));
    } finally {
      await inputTensor.dispose();
      if (outputs != null) {
        for (final v in outputs.values) {
          await v.dispose();
        }
      }
    }
  }

  // pakai nilai apa adanya jika sudah probabilitas (sum ≈ 1).
  List<double> _ensureProbabilities(List<double> values) {
    final sum = values.fold<double>(0, (a, b) => a + b);
    if ((sum - 1.0).abs() < 0.05) return values; // sudah probabilitas

    debugPrint('[skin_type] bukan probabilitas (sum=$sum), terapkan softmax');
    final maxV = values.reduce(math.max);
    final exps = values.map((v) => math.exp(v - maxV)).toList();
    final expSum = exps.fold<double>(0, (a, b) => a + b);
    return exps.map((v) => v / expSum).toList();
  }

  Future<void> dispose() async {
    final s = _session;
    _session = null;
    await s?.close();
  }
}
