import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  XFile? imageFile;

  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0;

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

    controller = CameraController(cameraDescription, ResolutionPreset.veryHigh);

    try {
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
    if (cameras.length < 2) {
      return;
    }

    selectedCameraIndex = selectedCameraIndex == 0 ? 1 : 0;
    await initController(cameras[selectedCameraIndex]);
  }

  Future<void> takePicture() async {
    final img = await controller?.takePicture();
    setState(() {
      imageFile = img;
    });
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

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller!)),

          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.switch_camera, color: Colors.white, size: 30),
              onPressed: switchCamera,
            ),
          ),
        ],
      ),

      floatingActionButton: imageFile == null
          ? FloatingActionButton(
              onPressed: takePicture,
              child: const Icon(Icons.camera),
            )
          : FloatingActionButton(
              onPressed: retakePicture,
              child: const Icon(Icons.refresh),
            ),
    );
  }
}
