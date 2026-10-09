import 'dart:typed_data';

import 'package:berseri/core/components/custom_sidebutton.dart';
import 'package:berseri/features/camera/camera_providers.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    void showConfirmDialog(BuildContext context, CameraNotifier notifier) {
      AwesomeDialog(
        context: context,
        dialogType: .question,
        animType: .scale,
        title: "Use This Picture?",
        desc: "This Photo Will Be Used For Analysis",
        btnCancelText: "Cancel",
        btnCancelColor: const Color(0xFFF4B700),
        btnCancelOnPress: () {},
        btnOkText: "Ok",
        btnOkOnPress: () async {
          await notifier.confirmPicture();
          if(!context.mounted) return;
        },
      ).show();
    }

    return cameraState.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            CircularProgressIndicator(),

            SizedBox(height: 20),

            Text(
              "detecting camera, wait",
              style: TextStyle(fontSize: 16),
              textAlign: .center,
            ),
          ],
        ),
      ),

      error: (error, stackTrace) =>
          Center(child: Center(child: Text("failed to open camera: $error"))),

      data: (data) {
        final c = data.controller;
        final hasPhoto = data.imageFile != null;

        return Padding(
          padding: const .fromLTRB(16, 2, 16, 8),
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: .circular(28)),
            
            /// ROOT BLOCK CAMERA PREVIEW
            child: ClipRRect(
              borderRadius: .circular(12),
              child: Stack(
                fit: .expand,
                children: [
                  /// PREVIEW CAMERA (klo belum foto)
                  if (!hasPhoto)
                    ClipRect(
                      child: FittedBox(
                        fit: .cover,
                        child: SizedBox(
                          width: c.value.previewSize!.height,
                          height: c.value.previewSize!.width,
                          child: CameraPreview(c),
                        ),
                      ),
                    )
                  else
                  /// tunjukin foto
                    _CapturedPhoto(file: data.imageFile!),

                  /// KEEP FACE STEADY BOX (kalo belum take pic text g keluar)
                  if (!hasPhoto)
                    Positioned(
                      top: 7,
                      left: 24,
                      right: 24,
                      child: Center(
                        child: Container(
                          padding: const .symmetric(
                            horizontal: 17,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF4B700), Color(0xFFFFB300)],
                              begin: .topLeft,
                              end: .bottomRight,
                            ),
                            borderRadius: .circular(30),
                            boxShadow: const [BoxShadow(color: Colors.black)],
                          ),
                          child: const Row(
                            mainAxisSize: .min,
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
                                  fontWeight: .bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  /// FLASH & GALLERY ICON
                  Positioned(
                    left: 24,
                    bottom: 32,
                    child: Column(
                      mainAxisSize: .min,
                      children: [
                        if (!hasPhoto && data.canUseFlash)
                          Padding(
                            padding: const .only(bottom: 15),
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

                  /// TAKE PICTURE BUTTON
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 23,
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        GestureDetector(
                          onTap: hasPhoto
                              ? notifier.retakePicture
                              : () => context.go('/questionnaire'),
                          child: Container(
                            width: 76,
                            height: 76,
                            padding: const .all(2.5),
                            decoration: BoxDecoration(
                              shape: .circle,
                              border: .all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: .circle,
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
                  
                  /// SWITCH CAMERA & ACCEPT PICTURE POSITION
                  Positioned(
                    right: 24,
                    bottom: 32,
                    child: CustomSidebutton(
                      icon: hasPhoto ? Icons.check : Icons.cameraswitch,
                      visible: hasPhoto || data.cameras.length > 1,
                      onTap: hasPhoto
                          ? () => showConfirmDialog(context, notifier)
                          : notifier.switchCamera,
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

/// The captured or gallery-picked photo, filling the preview area.
///
/// `Image.file` is not supported on Flutter Web — it asserts on `kIsWeb` — so
/// the bytes are read from the [XFile] and drawn with [Image.memory], which
/// works on web, Android and iOS alike.
class _CapturedPhoto extends StatefulWidget {
  const _CapturedPhoto({required this.file});

  final XFile file;

  @override
  State<_CapturedPhoto> createState() => _CapturedPhotoState();
}

class _CapturedPhotoState extends State<_CapturedPhoto> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.file.readAsBytes();
  }

  @override
  void didUpdateWidget(covariant _CapturedPhoto oldWidget) {
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

        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
