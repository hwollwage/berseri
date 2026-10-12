import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CapturedPhoto extends StatefulWidget {
  const CapturedPhoto({super.key, required this.file});

  final XFile file;

  @override
  State<CapturedPhoto> createState() => _CapturedPhotoState();
}

class _CapturedPhotoState extends State<CapturedPhoto> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant CapturedPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _bytes = widget.file.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return Center(
            child: snapshot.hasError
                ? const Text(
                    "couldn't read the photo",
                    style: TextStyle(color: Colors.white),
                  )
                : const CircularProgressIndicator(),
          );
        }

        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          cacheWidth: 1080,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Text(
              "couldn't display the photo",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}