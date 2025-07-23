import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/quiz_level_detail/controllers/quiz_level_detail_controller.dart';

class QuizLevelDetailView extends GetView<QuizLevelDetailController> {
  const QuizLevelDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Level Saat Ini')),

      body: Stack(
        children: [
          // ✅ Kamera Preview
          Obx(() {
            if (!controller.isCameraReady.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final previewSize = controller.previewSize.value;
            final cameraController = controller.cameraController.value;

            if (cameraController == null ||
                !cameraController.value.isInitialized) {
              return const Center(child: Text("Kamera belum siap"));
            }

            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: previewSize?.height ?? 720,
                  height: previewSize?.width ?? 1280,
                  child: CameraPreview(cameraController),
                ),
              ),
            );
          }),

          // ✅ Target Level (Gestur yang Harus Dicocokkan)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Obx(() {
              final level = controller.levelLabel.value;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level Target: $level',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),

          // ✅ Prediksi Gesture
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Obx(() {
              final predicted = controller.predictedLabel.value;
              final target = controller.levelLabel.value;
              final isCorrect =
                  predicted.toLowerCase().trim() == target.toLowerCase().trim();

              final bgColor = predicted.isEmpty
                  ? Colors.transparent
                  : (isCorrect ? Colors.green : Colors.red);

              return AnimatedOpacity(
                opacity: predicted.isEmpty ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: bgColor, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'Gestur Terdeteksi: $predicted',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),

      // ✅ Tombol ganti kamera
      floatingActionButton: FloatingActionButton(
        onPressed: controller.switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),
    );
  }
}
