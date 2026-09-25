import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:berseri/core/components/custom_sidebutton.dart';
import 'package:berseri/features/camera/camera_providers.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return cameraState.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "detecting camera, wait",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      error: (e, _) => Center(child: Text('failed to open camera: $e')),
      data: (data) {
        final c = data.controller;
        final hasPhoto = data.imageFile != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (!hasPhoto)
                    ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: c.value.previewSize!.height,
                          height: c.value.previewSize!.width,
                          child: CameraPreview(c),
                        ),
                      ),
                    )
                  else
                    Image.file(File(data.imageFile!.path), fit: BoxFit.cover),

                  if (!hasPhoto)
                    Positioned(
                      top: 10,
                      left: 24,
                      right: 24,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF4B700), Color(0xFFFFB300)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 30,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Keep Face Steady",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // flash + galeri, ditumpuk di kiri bawah
                  Positioned(
                    left: 24,
                    bottom: 32,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasPhoto && data.canUseFlash)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CustomSidebutton(
                              icon: data.isFlashOn
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              visible: true,
                              active: data.isFlashOn,
                              onTap: notifier.toggleFlash,
                            ),
                          ),
                        CustomSidebutton(
                          icon: Icons.photo_library_outlined,
                          visible: !hasPhoto,
                          onTap: notifier.pickFromGallery,
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 32,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: hasPhoto
                              ? notifier.retakePicture
                              : notifier.takePicture,
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: BoxBorder.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF4B700),
                              ),
                              child: hasPhoto
                                  ? Icon(
                                      Icons.refresh,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      size: 32,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!hasPhoto && data.cameras.length > 1)
                    Positioned(
                      right: 24,
                      bottom: 32,
                      child: CustomSidebutton(
                        icon: Icons.cameraswitch,
                        visible: true,
                        onTap: notifier.switchCamera,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
