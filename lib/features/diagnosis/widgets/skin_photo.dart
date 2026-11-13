import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class SkinPhoto extends StatelessWidget {
  final String? path;

  final String? url;

  final BoxFit fit;

  const SkinPhoto({super.key, this.path, this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final remote = url;
    if (remote != null && remote.isNotEmpty) {
      return Image.network(
        remote,
        fit: fit,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _placeholder(context),
        errorBuilder: (context, _, _) => _placeholder(context),
      );
    }

    final local = path;
    if (local == null || local.isEmpty) return _placeholder(context);

    // Di web, path dari kamera berupa blob URL
    return kIsWeb
        ? Image.network(local, fit: fit)
        : Image.file(File(local), fit: fit);
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHigh,
      child: Icon(Icons.face, size: 48, color: scheme.onSurfaceVariant),
    );
  }
}
