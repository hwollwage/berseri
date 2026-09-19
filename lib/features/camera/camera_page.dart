import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:berseri/core/components/custom_sidebutton.dart';
import 'package:berseri/features/camera/camera_providers.dart';


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with CameraLogic<CameraPage> {
  @override
  Widget build(BuildContext context) {
    final c = controller;

    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final hasPhoto = imageFile != null;
    final canUseFlash =
        cameras[selectedCameraIndex].lensDirection == CameraLensDirection.back;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                Image.file(File(imageFile!.path), fit: BoxFit.cover),

              Positioned(
                left: 0,
                right: 0,
                bottom: 32,
                child: Row(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    // ini flash button kiri
                    CustomSidebutton(
                      icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                      visible: !hasPhoto && canUseFlash,
                      active: isFlashOn,
                      onTap: toggleFlash,
                    ),

                    // take pic button
                    GestureDetector(
                      onTap: hasPhoto ? retakePicture : takePicture,
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: BoxBorder.all(color: Colors.white, width: 3),
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

                    // switch cam button
                    CustomSidebutton(
                      icon: Icons.cameraswitch,
                      visible: !hasPhoto && cameras.length > 1,
                      onTap: switchCamera,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// x
// import 'dart:io';

// import 'package:berseri/core/components/custom_sidebutton.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});

//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   // declare object camera dan xfile
//   CameraController? controller;
//   XFile? imageFile;

//   // list camera yg ada & pilihan cam (depan / selfie)
//   List<CameraDescription> cameras = [];
//   int selectedCameraIndex = 0;

//   // ini buat set flash camera e
//   bool isFlashOn = false;

//   @override
//   void initState() {
//     super.initState();
//     setupCamera();
//   }

//   Future<void> setupCamera() async {
//     try {
//       cameras = await availableCameras();
//       if (cameras.isNotEmpty) {
//         selectedCameraIndex = 0;
//         initController(cameras[selectedCameraIndex]);
//       }
//     } catch (e) {
//       debugPrint("error setting up camera: $e");
//     }
//   }

//   Future<void> initController(CameraDescription cameraDescription) async {
//     if (controller != null) {
//       await controller!.dispose();
//     }

//     controller = CameraController(cameraDescription, ResolutionPreset.veryHigh);

//     try {
//       isFlashOn = false; // default flash e mati
//       await controller!.initialize();

//       if (!mounted) {
//         return;
//       }

//       setState(() {});
//     } catch (e) {
//       debugPrint("error init camera: $e");
//     }
//   }

//   Future<void> switchCamera() async {
//     if (cameras.length < 2) return;

//     final current = cameras[selectedCameraIndex].lensDirection;
//     final target = current == CameraLensDirection.front
//         ? CameraLensDirection.back
//         : CameraLensDirection.front;

//     final index = cameras.indexWhere((c) => c.lensDirection == target);

//     if (index == -1) return;

//     selectedCameraIndex = index;

//     await initController(cameras[selectedCameraIndex]);
//   }

//   Future<void> toggleFlash() async {
//     final c = controller;
//     if (c == null || !c.value.isInitialized) {
//       return;
//     }

//     final next = !isFlashOn;

//     try {
//       await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);

//       if (!mounted) return;

//       setState(() => isFlashOn = next);
//     } catch (e) {
//       debugPrint("error set flash: $e");
//     }
//   }

//   Future<void> takePicture() async {
//     final c = controller;

//     if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;

//     try {
//       final img = await c.takePicture();

//       if (isFlashOn) {
//         await c.setFlashMode(FlashMode.off);
//       }
//       if (!mounted) return;

//       setState(() {
//         imageFile = img;
//         isFlashOn = false;
//       });
//     } catch (e) {
//       debugPrint("error take pic: $e");
//     }
//   }

//   Future<void> retakePicture() async {
//     setState(() {
//       imageFile = null;
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = controller;

//     if (c == null || !c.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final hasPhoto = imageFile != null;
//     final canUseFlash =
//         cameras[selectedCameraIndex].lensDirection == CameraLensDirection.back;

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 16,
//               offset: Offset(0, 6),
//             ),
//           ],
//         ),

//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(28),
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               if (!hasPhoto)
//                 ClipRect(
//                   child: FittedBox(
//                     fit: BoxFit.cover,
//                     child: SizedBox(
//                       width: c.value.previewSize!.height,
//                       height: c.value.previewSize!.width,
//                       child: CameraPreview(c),
//                     ),
//                   ),
//                 )
//               else
//                 Image.file(File(imageFile!.path), fit: BoxFit.cover),

//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 32,
//                 child: Row(
//                   mainAxisAlignment: .spaceEvenly,
//                   children: [
//                     // ini flash button kiri
//                     CustomSidebutton(
//                       icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
//                       visible: !hasPhoto && canUseFlash,
//                       active: isFlashOn,
//                       onTap: toggleFlash,
//                     ),

//                     // take pic button
//                     GestureDetector(
//                       onTap: hasPhoto ? retakePicture : takePicture,
//                       child: Container(
//                         width: 76,
//                         height: 76,
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: BoxBorder.all(color: Colors.white, width: 3),
//                         ),
//                         child: Container(
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Color(0xFFF4B700),
//                           ),
//                           child: hasPhoto
//                               ? Icon(
//                                   Icons.refresh,
//                                   color: Theme.of(
//                                     context,
//                                   ).colorScheme.onPrimary,
//                                   size: 32,
//                                 )
//                               : null,
//                         ),
//                       ),
//                     ),

//                     // switch cam button
//                     CustomSidebutton(
//                       icon: Icons.cameraswitch,
//                       visible: !hasPhoto && cameras.length > 1,
//                       onTap: switchCamera,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }