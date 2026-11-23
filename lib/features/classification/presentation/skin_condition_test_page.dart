import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:berseri/features/classification/data/face_detector_service.dart';
import 'package:berseri/features/classification/data/skin_condition_service.dart';

class SkinConditionTestPage extends StatefulWidget {
  const SkinConditionTestPage({super.key});

  @override
  State<SkinConditionTestPage> createState() => _SkinConditionTestPageState();
}

class _SkinConditionTestPageState extends State<SkinConditionTestPage> {
  final FaceDetectorService _faceDetector = FaceDetectorService();
  final SkinConditionService _service = SkinConditionService();
  final ImagePicker _picker = ImagePicker();

  File? _originalFile;
  File? _croppedFile;
  Map<String, double>? _scores;
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
      _scores = null;
      _error = null;
      _statusMessage = 'Mendeteksi wajah...';
      _isLoading = true;
    });

    try {
      // 1. Deteksi & crop wajah
      final detection = await _faceDetector.detect(_originalFile!);

      if (!mounted) return;

      if (detection == null) {
        setState(() {
          _error = 'Tidak ada wajah terdeteksi.\nCoba foto yang lebih jelas.';
          _isLoading = false;
          _statusMessage = null;
        });
        return;
      }

      final tmp = await getTemporaryDirectory();
      final cropFile = File(
        '${tmp.path}/face_crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await cropFile.writeAsBytes(detection.croppedBytes);

      if (!mounted) return;
      setState(() {
        _croppedFile = cropFile;
        _statusMessage = 'Menganalisis kondisi kulit...';
      });

      // 2. Jalankan model dengan hasil crop
      final detections = await _service.predict(cropFile);

      if (!mounted) return;

      // Deduplikasi: 1 entry per label, confidence tertinggi.
      final map = <String, double>{};
      for (final d in detections) {
        final prev = map[d.label];
        if (prev == null || d.confidence > prev) map[d.label] = d.confidence;
      }
      final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      setState(() {
        _scores = sorted;
        _statusMessage = null;
      });
    } catch (e, st) {
      debugPrint('[skin_condition_test] error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _faceDetector.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scores = _scores;

    return Scaffold(
      appBar: AppBar(title: const Text('Skin Condition Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (scores != null)
              scores.isEmpty
                  ? const Text(
                      'Tidak ada kondisi terdeteksi.',
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      children: [
                        for (final label in SkinConditionService.labels)
                          _ConditionBar(
                            label: label,
                            score: scores[label] ?? 0.0,
                            detected: scores.containsKey(label),
                          ),
                      ],
                    )
            else
              const Text(
                'Pilih gambar untuk menguji model skin condition',
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

class _ConditionBar extends StatelessWidget {
  const _ConditionBar({
    required this.label,
    required this.score,
    required this.detected,
  });

  final String label;
  final double score;
  final bool detected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = detected ? colorScheme.primary : colorScheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: detected ? null : colorScheme.outline,
                  fontWeight:
                      detected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Text(
                detected
                    ? '${(score * 100).toStringAsFixed(1)}%'
                    : 'tidak terdeteksi',
                style: TextStyle(
                  color: detected ? null : colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score.clamp(0.0, 1.0),
            color: color,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
