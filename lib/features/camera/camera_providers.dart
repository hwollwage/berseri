import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:berseri/features/classification/classification_provider.dart';

class CameraState {
  final CameraController controller;
  final List<CameraDescription> cameras;
  final int selectedIndex;
  final bool isFlashOn;
  final XFile? imageFile;

  const CameraState({
    required this.controller,
    required this.cameras,
    required this.selectedIndex,
    this.isFlashOn = false,
    this.imageFile,
  });

  bool get canUseFlash =>
      cameras[selectedIndex].lensDirection == CameraLensDirection.back;

  CameraState copyWith({
    CameraController? controller,
    int? selectedIndex,
    bool? isFlashOn,
    XFile? imageFile,
    bool clearImage = false,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      cameras: cameras,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
    );
  }
}

class CameraNotifier extends AsyncNotifier<CameraState> {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<CameraState> build() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('Tidak ada kamera yang tersedia');
    }

    var index = cameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
    if (index == -1) {
      index = 0;
    }

    final controller = await _open(cameras[index]);
    return CameraState(
      controller: controller,
      cameras: cameras,
      selectedIndex: index,
    );
  }

  Future<CameraController> _open(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    ref.onDispose(() => controller.dispose());
    return controller;
  }

  Future<void> toggleFlash() async {
    final current = state.asData?.value;
    if (current == null) return;

    final next = !current.isFlashOn;
    await current.controller.setFlashMode(
      next ? FlashMode.torch : FlashMode.off,
    );
    state = AsyncData(current.copyWith(isFlashOn: next));
  }

  Future<void> switchCamera() async {
    final current = state.asData?.value;
    if (current == null || current.cameras.length < 2) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await current.controller.dispose();
      final nextIndex = (current.selectedIndex + 1) % current.cameras.length;
      final controller = await _open(current.cameras[nextIndex]);
      return current.copyWith(
        controller: controller,
        selectedIndex: nextIndex,
        isFlashOn: false,
      );
    });
  }

  Future<void> takePicture() async {
    final current = state.asData?.value;
    if (current == null) return;

    final file = await current.controller.takePicture();
    state = AsyncData(current.copyWith(imageFile: file));
    await ref.read(classificationProvider.notifier).classify(File(file.path));
  }

  Future<void> pickFromGallery() async {
    final current = state.asData?.value;
    if (current == null) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    state = AsyncData(current.copyWith(imageFile: picked));
    await ref.read(classificationProvider.notifier).classify(File(picked.path));
  }

  void retakePicture() {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(clearImage: true));
    ref.read(classificationProvider.notifier).reset();
  }
}

final cameraProvider = AsyncNotifierProvider<CameraNotifier, CameraState>(CameraNotifier.new);
