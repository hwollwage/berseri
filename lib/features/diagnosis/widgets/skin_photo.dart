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
      return Container(
        color: Colors.black12,
        child: const Icon(Icons.face, size: 48, color: Colors.black38),
      );
    }
    // Di web, path dari kamera berupa blob URL
    return kIsWeb
        ? Image.network(path!, fit: fit)
        : Image.file(File(path!), fit: fit);
  }
}