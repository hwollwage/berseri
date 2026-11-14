import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:berseri/features/classification/data/skin_type_service.dart';
import 'package:berseri/features/classification/domain/skin_type_result.dart';

class SkinTypeTestPage extends StatefulWidget {
  const SkinTypeTestPage({super.key});

  @override
  State<SkinTypeTestPage> createState() => _SkinTypeTestPageState();
}

class _SkinTypeTestPageState extends State<SkinTypeTestPage> {
  final SkinTypeService _service = SkinTypeService();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  SkinTypeResult? _result;
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
      _result = null;
      _error = null;
      _isLoading = true;
    });

    try {
      final result = await _service.predict(_imageFile!);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e, stackTrace) {
      debugPrint('[skin_type] error: $e');
      debugPrintStack(stackTrace: stackTrace);
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
            else if (result != null)
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
                          Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: entry.value.clamp(0.0, 1.0),
                      ),
                    ],
                  ),
                )
            else
              const Text(
                'Pilih gambar untuk menguji model skin type',
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
