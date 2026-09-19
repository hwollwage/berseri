import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

mixin CameraLogic<T extends StatefulWidget> on State<T> {
  // declare object camera dan xfile
  CameraController? controller;
  XFile? imageFile;

  // list camera yg ada & pilihan cam (depan / selfie)
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

  // ini buat set flash camera e
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    setupCamera();
  }

  Future<void> setupCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        selectedCameraIndex = 0;
        initController(cameras[selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint("error setting up camera: $e");
    }
  }

  Future<void> initController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.veryHigh); // buat ML deteksi resolusi e veryhigh / ultrahigh

    try {
      isFlashOn = false; // default flash e mati
      await controller!.initialize();

      if (!mounted) {
        return;
      }

      setState(() {});
    } catch (e) {
      debugPrint("error init camera: $e");
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    final current = cameras[selectedCameraIndex].lensDirection;
    final target = current == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;

    final index = cameras.indexWhere((c) => c.lensDirection == target);

    if (index == -1) return;

    selectedCameraIndex = index;

    await initController(cameras[selectedCameraIndex]);
  }

  Future<void> toggleFlash() async {
    final c = controller;
    if (c == null || !c.value.isInitialized) return;

    final next = !isFlashOn;

    try {
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);

      if (!mounted) return;

      setState(() => isFlashOn = next);
    } catch (e) {
      debugPrint("error set flash: $e");
    }
  }

  Future<void> takePicture() async {
    final c = controller;

    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;

    try {
      final img = await c.takePicture();

      if (isFlashOn) {
        await c.setFlashMode(FlashMode.off);
      }
      if (!mounted) return;

      setState(() {
        imageFile = img;
        isFlashOn = false;
      });
    } catch (e) {
      debugPrint("error take pic: $e");
    }
  }

  Future<void> retakePicture() async {
    setState(() {
      imageFile = null;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}