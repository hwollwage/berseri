import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import 'package:berseri/features/classification/domain/skin_type_result.dart';

class _PrepArgs {
  const _PrepArgs(this.bytes, this.size);
  final Uint8List bytes;
  final int size;
}

Float32List _preprocessType(_PrepArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) throw Exception('Gambar tidak dapat dibaca.');

  final oriented = img.bakeOrientation(decoded);
  final size = args.size;

  final resized = oriented.width < oriented.height
      ? img.copyResize(oriented, width: size, interpolation: img.Interpolation.linear)
      : img.copyResize(oriented, height: size, interpolation: img.Interpolation.linear);

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
  static const List<String> labels = ['combination', 'dry', 'normal', 'oily'];

  Future<void> loadModel() {
    if (_session != null) return Future.value();
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    _session = await _runtime.createSessionFromAsset('assets/models/skin_type.onnx');
  }

  Future<SkinTypeResult> predict(File imageFile) async {
    await loadModel();

    if (!await imageFile.exists()) {
      throw Exception('File tidak ditemukan: ${imageFile.path}');
    }

    final bytes = await imageFile.readAsBytes();
    final inputData = await compute(_preprocessType, _PrepArgs(bytes, inputSize));

    final inputTensor = await OrtValue.fromList(inputData, [1, 3, inputSize, inputSize]);

    Map<String, OrtValue>? outputs;
    try {
      outputs = await _session!.run({_session!.inputNames.first: inputTensor});

      final output = outputs[_session!.outputNames.first];
      if (output == null) {
        throw Exception('Output tidak ada. Tersedia: ${outputs.keys}');
      }

      final raw = (await output.asFlattenedList())
          .map((v) => (v as num).toDouble())
          .toList();

      if (raw.length != labels.length) {
        throw Exception('Output length ${raw.length} != ${labels.length}. Shape: ${output.shape}');
      }

      final entries = [
        for (var i = 0; i < labels.length; i++) MapEntry(labels[i], raw[i]),
      ]..sort((a, b) => b.value.compareTo(a.value));

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

  Future<void> dispose() async {
    final s = _session;
    _session = null;
    await s?.close();
  }
}
