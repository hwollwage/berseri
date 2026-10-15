import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class SkinPhoto extends StatelessWidget {
  final String? path;
  final BoxFit fit;

  const SkinPhoto({super.key, this.path, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      final scheme = Theme.of(context).colorScheme;
      return Container(
        color: scheme.surfaceContainerHigh,
        child: Icon(Icons.face, size: 48, color: scheme.onSurfaceVariant),
      );
    }
    // Di web, path dari kamera berupa blob URL
    return kIsWeb
        ? Image.network(path!, fit: fit)
        : Image.file(File(path!), fit: fit);
  }
}