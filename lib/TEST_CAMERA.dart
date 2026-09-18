import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TestCameraApp());
}

class TestCameraApp extends StatelessWidget {
  const TestCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraPage());
  }
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    setupCamera();
  }

  Future<void> setupCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    final image = await controller?.takePicture();
    setState(() {
      imageFile = image;
    });
  }

  Future<void> retakePicture() async {
    setState(() {
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const ScaffoldMessenger(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('camera')),
      body: imageFile == null ? CameraPreview(controller!) : Image.file(File(imageFile!.path)),
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