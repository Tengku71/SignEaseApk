import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:mobile/app/data/services/hand_landmark_painter.dart';
import 'package:mobile/app/modules/transcribe/controllers/transcribe_controller.dart';

class TranscribeView extends GetView<TranscribeController> {
  const TranscribeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Transcribe')),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() {
            return FloatingActionButton(
              heroTag: 'switch_camera',
              onPressed:
                  controller.isSwitching.value ? null : controller.switchCamera,
              child: controller.isSwitching.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.cameraswitch),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return FloatingActionButton(
              heroTag: 'toggle_landmarks',
              onPressed: controller.showLandmarks.toggle,
              backgroundColor:
                  controller.showLandmarks.value ? Colors.blue : Colors.grey,
              child: Icon(
                controller.showLandmarks.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            return FloatingActionButton(
              heroTag: 'toggle_tts',
              onPressed: controller.ttsEnabled.toggle,
              backgroundColor:
                  controller.ttsEnabled.value ? Colors.green : Colors.grey,
              child: Icon(
                controller.ttsEnabled.value
                    ? Icons.volume_up
                    : Icons.volume_off,
              ),
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final cameraController = controller.cameraController.value;
          final previewSize = controller.previewSize.value;

          if (cameraController == null ||
              previewSize == null ||
              !cameraController.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final rotatedSize = Size(previewSize.height, previewSize.width);
          final screenWidth = MediaQuery.of(context).size.width;
          final aspectRatio = rotatedSize.height / rotatedSize.width;
          final previewHeight = screenWidth * aspectRatio;

          return Column(
            children: [
              SizedBox(
                width: screenWidth,
                height: previewHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: cameraController.description.lensDirection ==
                              CameraLensDirection.front
                          ? Matrix4.rotationY(pi)
                          : Matrix4.identity(),
                      child: CameraPreview(cameraController),
                    ),
                    Obx(() {
                      return controller.showLandmarks.value
                          ? CustomPaint(
                              painter: HandLandmarkPainter(
                                controller.handLandmarks,
                                showLabels: false,
                              ),
                              child: Container(),
                            )
                          : const SizedBox.shrink();
                    }),
                    // Positioned(
                    //   top: 20,
                    //   left: 20,
                    //   child: Obx(() {
                    //     final label = controller.predictedLabel.value;
                    //     return Container(
                    //       padding: const EdgeInsets.symmetric(
                    //           horizontal: 12, vertical: 8),
                    //       decoration: BoxDecoration(
                    //         color: Colors.black.withOpacity(0.5),
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //       child: Text(
                    //         label.isEmpty
                    //             ? '🖐️ No gesture detected'
                    //             : '🧠 Prediction: $label',
                    //         style: const TextStyle(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w600,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     );
                    //   }),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: Colors.black,
                  child: Obx(() {
                    final label = controller.predictedLabel.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prediksi Gesture:",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label.isEmpty ? 'No gesture' : label,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
