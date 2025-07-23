import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:mobile/app/data/services/hand_landmark_painter.dart';
import 'package:mobile/app/modules/video_detail/controllers/video_detail_controller.dart';

class VideoDetailView extends GetView<VideoDetailController> {
  const VideoDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.videoTitle.value)),
      ),
      body: Column(
        children: [
          Obx(() {
            if (!controller.isVideoInitialized.value) {
              return _buildLoadingPlaceholder(height: 200);
            }
            return _VideoPlayerWithControls(controller: controller);
          }),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              if (controller.cameraError.value != null) {
                return _buildErrorMessage(controller.cameraError.value!);
              }

              if (!controller.isCameraOn.value) {
                return _buildSimpleMessage("Camera Off");
              }

              if (!controller.isCameraInitialized.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller.cameraController),
                  // Obx(() => controller.showLandmarks.value
                  //     ? CustomPaint(
                  //         painter: HandLandmarkPainter(controller.handLandmarks,
                  //             showLabels: false),
                  //         child: Container(),
                  //       )
                  //     : const SizedBox.shrink()),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Obx(() {
                        final gesture = controller.predictedGesture.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            gesture.isNotEmpty ? gesture : "No Gesture",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'toggleCamera',
              onPressed: controller.toggleCamera,
              child: Icon(controller.isCameraOn.value
                  ? Icons.videocam_off
                  : Icons.videocam),
            ),
            const SizedBox(height: 10),
            if (controller.isCameraOn.value)
              FloatingActionButton(
                heroTag: 'switchCamera',
                onPressed: controller.switchCamera,
                child: const Icon(Icons.cameraswitch),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingPlaceholder({required double height}) {
    return Container(
      height: height,
      color: Colors.black12,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        "Camera Error:\n$message",
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }

  Widget _buildSimpleMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}

class _VideoPlayerWithControls extends StatelessWidget {
  final VideoDetailController controller;

  const _VideoPlayerWithControls({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videoController = controller.videoController;

    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(videoController),
          VideoProgressIndicator(videoController, allowScrubbing: true),
          Positioned(
            bottom: 10,
            right: 10,
            child: IconButton(
              icon: Icon(
                videoController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () {
                videoController.value.isPlaying
                    ? videoController.pause()
                    : videoController.play();
              },
            ),
          ),
        ],
      ),
    );
  }
}
