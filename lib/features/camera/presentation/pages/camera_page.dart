import 'package:berseri/core/components/app_colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import 'package:berseri/features/camera/presentation/providers/camera_providers.dart';
import 'package:berseri/features/camera/presentation/widgets/analysis_loading_overlay.dart';
import 'package:berseri/features/camera/presentation/widgets/captured_photo.dart';
import 'package:berseri/features/camera/presentation/widgets/face_guide_overlay.dart';
import 'package:berseri/features/camera/presentation/widgets/glass_widgets.dart';
import 'package:berseri/features/camera/presentation/widgets/shutter_button.dart';
import 'package:berseri/features/classification/classification_provider.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  bool _saving = false;

  @override
  void dispose() {
    _flash.dispose();
    super.dispose();
  }

  Future<void> _onShutter() async {
    _flash.reverse(from: 1);
    try {
      await ref.read(cameraProvider.notifier).takePicture();
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: ${e.description}')),
      );
    }
  }

  Future<void> _onUsePhoto() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      try {
        await ref.read(classificationProvider.future);
      } catch (_) {
        // TODO: belum ada tujuan ke server flasknya
        if (!kDebugMode) rethrow;
      }
      await ref.read(cameraProvider.notifier).confirmPicture();

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      context.go('/questionnaire');

      if (mounted) setState(() => _saving = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    return SafeArea(
      bottom: false,
      child: cameraState.when(
        loading: () => const _CameraLoading(),
        error: (e, _) => _CameraError(
          message: '$e',
          onRetry: () => ref.invalidate(cameraProvider),
        ),
        data: _buildCamera,
      ),
    );
  }

  Widget _buildCamera(CameraState data) {
    final notifier = ref.read(cameraProvider.notifier);
    final hasPhoto = data.imageFile != null;
    final analyzing = ref.watch(classificationProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Preview atau foto hasil
            if (hasPhoto)
              CapturedPhoto(file: data.imageFile!)
            else
              _PreviewFill(controller: data.controller),

            // 2. Panduan wajah (area luar digelapkan) + petunjuk di bawah frame
            if (!hasPhoto)
              const FaceGuideOverlay(hint: 'Align your face inside the frame'),

            // 3. Bar atas: chip status (setelah foto) + tombol flash
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  const SizedBox(width: 52),
                  Expanded(
                    child: Center(
                      child: hasPhoto && analyzing && !_saving
                          ? const GlassChip(
                              label: 'Analyzing…',
                              icon: Icons.auto_awesome,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  if (!hasPhoto && data.canUseFlash)
                    GlassIconButton(
                      icon: data.isFlashOn ? Icons.flash_on : Icons.flash_off,
                      active: data.isFlashOn,
                      onTap: notifier.toggleFlash,
                    )
                  else
                    const SizedBox(width: 52),
                ],
              ),
            ),

            // 4. Kontrol bawah di atas gradient scrim
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: hasPhoto
                        ? _ReviewControls(
                            key: const ValueKey('review'),
                            busy: _saving,
                            onRetake: notifier.retakePicture,
                            onUse: _onUsePhoto,
                          )
                        : Row(
                            key: const ValueKey('capture'),
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlassIconButton(
                                icon: Icons.photo_library_outlined,
                                onTap: notifier.pickFromGallery,
                              ),
                              ShutterButton(onTap: _onShutter),
                              data.cameras.length > 1
                                  ? GlassIconButton(
                                      icon: Icons.cameraswitch,
                                      onTap: notifier.switchCamera,
                                    )
                                  : const SizedBox(width: 52),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            // 5. Flash putih saat takepic
            IgnorePointer(
              child: FadeTransition(
                opacity: _flash,
                child: const ColoredBox(color: Colors.white),
              ),
            ),

            // 6. Loading setelah "Use photo"
            if (_saving) const AnalysisLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ReviewControls extends StatelessWidget {
  const _ReviewControls({
    super.key,
    required this.busy,
    required this.onRetake,
    required this.onUse,
  });

  final bool busy;
  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: busy ? null : onRetake,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white38,
              side: const BorderSide(color: Colors.white70),
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: busy ? null : onUse,
            icon: const Icon(Icons.check),
            label: const Text('Use photo'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cameraAccent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.cameraAccent.withValues(
                alpha: 0.5,
              ),
              disabledForegroundColor: Colors.black54,
              minimumSize: const Size.fromHeight(52),
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewFill extends StatelessWidget {
  const _PreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return const ColoredBox(color: Colors.black);

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}

class _CameraLoading extends StatelessWidget {
  const _CameraLoading();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Starting camera…'),
      ],
    ),
  );
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.no_photography_outlined, size: 48),
          const SizedBox(height: 12),
          Text('Failed to open camera\n$message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
