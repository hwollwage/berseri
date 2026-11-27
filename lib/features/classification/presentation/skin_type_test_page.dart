import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:berseri/features/classification/data/face_detector_service.dart';
import 'package:berseri/features/classification/data/skin_type_service.dart';
import 'package:berseri/features/classification/domain/skin_type_result.dart';

class SkinTypeTestPage extends StatefulWidget {
  const SkinTypeTestPage({super.key});

  @override
  State<SkinTypeTestPage> createState() => _SkinTypeTestPageState();
}

class _SkinTypeTestPageState extends State<SkinTypeTestPage> {
  final FaceDetectorService _faceDetector = FaceDetectorService();
  final SkinTypeService _skinType = SkinTypeService();
  final ImagePicker _picker = ImagePicker();

  File? _originalFile;
  File? _croppedFile; // wajah yang di-crop, diumpan ke model
  SkinTypeResult? _result;
  String? _error;
  String? _statusMessage;
  bool _isLoading = false;

  Future<void> _pickAndPredict(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _originalFile = File(picked.path);
      _croppedFile = null;
      _result = null;
      _error = null;
      _statusMessage = 'Mendeteksi wajah...';
      _isLoading = true;
    });

    try {
      File inputFile = _originalFile!;

      final detection = await _faceDetector.detect(_originalFile!);
      if (!mounted) return;

      if (detection != null) {
        final tmp = await getTemporaryDirectory();
        final cropFile = File(
          '${tmp.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await cropFile.writeAsBytes(detection.croppedBytes);
        inputFile = cropFile;
        setState(() {
          _croppedFile = cropFile;
          _statusMessage = 'Menganalisis tipe kulit...';
        });
      } else {
        setState(() => _statusMessage = 'Menganalisis tipe kulit...');
      }

      final result = await _skinType.predict(inputFile);

      if (!mounted) return;
      setState(() {
        _result = result;
        _statusMessage = null;
      });
    } catch (e, st) {
      debugPrint('[skin_type_test] error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _faceDetector.dispose();
    _skinType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Type Test'),
        actions: [
          TextButton(
            onPressed: () => context.push('/dev/skin-condition-test'),
            child: const Text('Condition →'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tampilkan crop wajah kalau ada, fallback ke foto asli
            if (_croppedFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _croppedFile!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Wajah ter-crop',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 20),
            ] else if (_originalFile != null) ...[
              Image.file(_originalFile!, height: 220, fit: BoxFit.contain),
              const SizedBox(height: 20),
            ],

            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(_statusMessage!, textAlign: TextAlign.center),
              ],
            ] else if (_error != null)
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            else if (result != null)
              Column(
                children: [
                  for (final entry in result.scores.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                '${(entry.value * 100).toStringAsFixed(1)}%',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value.clamp(0.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            else
              const Text(
                'Pilih gambar untuk menguji model skin type',
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed:
                  _isLoading ? null : () => _pickAndPredict(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed:
                  _isLoading ? null : () => _pickAndPredict(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
            ),
          ],
        ),
      ),
    );
  }
}
