import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:berseri/features/classification/data/skin_condition_service.dart';

class SkinConditionTestPage extends StatefulWidget {
  const SkinConditionTestPage({super.key});

  @override
  State<SkinConditionTestPage> createState() => _SkinConditionTestPageState();
}

class _SkinConditionTestPageState extends State<SkinConditionTestPage> {
  final SkinConditionService _service = SkinConditionService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;

  Map<String, double>? _scores;
  String? _error;
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
      _imageFile = File(picked.path);
      _scores = null;
      _error = null;
      _isLoading = true;
    });

    try {
      final detections = await _service.predict(_imageFile!);
      if (!mounted) return;

      // Deduplikasi: ambil confidence tertinggi per label.
      final map = <String, double>{};
      for (final d in detections) {
        final prev = map[d.label];
        if (prev == null || d.confidence > prev) map[d.label] = d.confidence;
      }
      final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      setState(() => _scores = sorted);
    } catch (e, st) {
      debugPrint('[skin_condition] error: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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
            if (_imageFile != null) ...[
              Image.file(_imageFile!, height: 280, fit: BoxFit.contain),
              const SizedBox(height: 20),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Text(
                'Gagal:\n$_error',
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
                        // Tampilkan semua 4 label — yang tidak terdeteksi
                        // akan muncul dengan skor 0 supaya mudah dibandingkan.
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
              onPressed: _isLoading
                  ? null
                  : () => _pickAndPredict(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Pilih dari Galeri'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () => _pickAndPredict(ImageSource.camera),
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
                  fontWeight: detected ? FontWeight.w600 : FontWeight.normal,
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
