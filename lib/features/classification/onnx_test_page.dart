import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:berseri/features/classification/skin_onnx_service.dart';

class OnnxTestPage extends StatefulWidget {
  const OnnxTestPage({super.key});

  @override
  State<OnnxTestPage> createState() => _OnnxTestPageState();
}

class _OnnxTestPageState extends State<OnnxTestPage> {
  final SkinOnnxService _service = SkinOnnxService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  String _message = 'Pilih gambar untuk menguji model ONNX';
  bool _isLoading = false;

  Future<void> _pickAndPredict() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _message = 'Memproses gambar...';
      _isLoading = true;
    });

    try {
      final detections = await _service.predict(_imageFile!);

      if (!mounted) return;

      setState(() {
        _message = detections.isEmpty
            ? 'Tidak ada kondisi terdeteksi.'
            : detections
                  .map(
                    (detection) =>
                        '${detection.label}: '
                        '${(detection.confidence * 100).toStringAsFixed(1)}%',
                  )
                  .join('\n');
      });
    } catch (e, stackTrace) {
      debugPrint('ONNX inference error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _message = 'Inference gagal:\n$e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ONNX Model Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null) ...[
              Image.file(_imageFile!, height: 280, fit: BoxFit.contain),
              const SizedBox(height: 20),
            ],
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndPredict,
              child: Text(
                _isLoading
                    ? 'Memproses gambar...'
                    : 'Pilih Gambar & Jalankan ONNX',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
