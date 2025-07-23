import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/modules/quizz_timer_detail/controllers/quizz_timer_detail_controller.dart';

class QuizzTimerDetailView extends GetView<QuizzTimerDetailController> {
  const QuizzTimerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Timer")),
      body: Stack(
        children: [
          // ✅ Camera Preview
          Obx(() {
            if (!controller.isCameraReady.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final previewSize = controller.previewSize.value;
            final cameraController = controller.cameraController.value;

            if (cameraController == null ||
                !cameraController.value.isInitialized) {
              return const Center(child: Text("Camera not initialized"));
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

          // ✅ Info Panel: Timer & Target
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Obx(() {
              final target = (controller.questions.isNotEmpty &&
                      controller.currentQuestionIndex.value <
                          controller.questions.length)
                  ? controller.questions[controller.currentQuestionIndex.value]
                  : '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Timer Card
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text(
                            'Sisa Waktu: ${controller.remainingSeconds.value}s',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Target Card
                  if (target.isNotEmpty)
                    Card(
                      color: Colors.orange.shade100.withOpacity(0.95),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flag, color: Colors.deepOrange),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Target Gesture: $target',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Predicted Gesture
                  Obx(() {
                    final predicted = controller.predictedLabel.value;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: predicted.isEmpty ? 0 : 1,
                      child: Card(
                        color: Colors.black.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pan_tool,
                                  color: Colors.yellowAccent),
                              const SizedBox(width: 10),
                              Text(
                                'Prediksi: $predicted',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
          ),

          // ✅ Waktu habis
          Obx(() {
            if (controller.isCompleted.value) {
              return const Center(
                child: Card(
                  color: Colors.black87,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "⏰ Waktu Habis!",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),

      // ✅ Tombol switch kamera
      floatingActionButton: FloatingActionButton(
        onPressed: controller.switchCamera,
        child: const Icon(Icons.cameraswitch),
      ),
    );
  }
}
