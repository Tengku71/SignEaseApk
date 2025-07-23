import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/services/gesture_model.dart';
import 'package:video_player/video_player.dart';

class VideoDetailController extends GetxController {
  late CameraController cameraController;
  late VideoPlayerController videoController;

  final RxBool isCameraInitialized = false.obs;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isCameraOn = true.obs;
  final RxnString cameraError = RxnString();
  final RxList<List<Offset>> handLandmarks = <List<Offset>>[].obs;
  final RxString predictedGesture = ''.obs;
  final RxBool showLandmarks = true.obs;
  final RxString videoTitle = ''.obs;

  static const platform = MethodChannel('hand_landmarker');
  final gestureModel = GestureModel();

  bool _isProcessing = false;
  int _selectedCameraIndex = 0;
  List<CameraDescription> _availableCameras = [];
  Size? _previewSize;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      videoTitle.value = args['videoTitle'] ?? 'Video';
    }
    gestureModel.loadModel();
    _setMethodChannelHandler();
    initCamera();
    initVideo();
  }

  void _setMethodChannelHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "updateResult") {
        final data = Map<String, dynamic>.from(call.arguments);
        final hands = data['landmarks'] as List<dynamic>;
        final width = data['width'] as int;
        final height = data['height'] as int;

        if (hands.isEmpty || _previewSize == null) {
          handLandmarks.clear();
          predictedGesture.value = '';
          return;
        }

        final input = <double>[];
        final allLandmarks = <Offset>[];
        final Size targetSize = _previewSize!;

        for (final hand in hands) {
          for (final point in hand) {
            final x = (point['x'] ?? 0.0) * width;
            final y = (point['y'] ?? 0.0) * height;

            final rotated = rotateAroundCenter(
              Offset(x, y),
              Size(width.toDouble(), height.toDouble()),
              90,
            );

            final normX = rotated.dx * targetSize.width / width;
            double normY = rotated.dy * targetSize.height / height;

            // If using front camera, flip vertically
            if (cameraController.description.lensDirection ==
                CameraLensDirection.front) {
              normY = targetSize.height - normY;
            }

            allLandmarks.add(Offset(normX, normY));
            input
              ..add(normX.clamp(0, targetSize.width) / targetSize.width)
              ..add(normY.clamp(0, targetSize.height) / targetSize.height);
          }
        }

        // Add dummy pose (6 keypoints × 2)
        input.addAll(List<double>.filled(12, 0.0));

        // Pad to 54 features
        while (input.length < 54) input.add(0.0);

        handLandmarks.value = [allLandmarks];

        if (gestureModel.isLoaded) {
          final label = gestureModel.predictLabel(input);
          predictedGesture.value = label.trim().toLowerCase() ==
                  videoTitle.value.trim().toLowerCase()
              ? label
              : '';
        } else {
          predictedGesture.value = '';
        }
      }
    });
  }

  Offset rotateAroundCenter(Offset point, Size size, double angleDegrees) {
    final angle = angleDegrees * pi / 180;
    final center = Offset(size.width / 2, size.height / 2);
    final translated = point - center;
    final rotated = Offset(
      translated.dx * cos(angle) - translated.dy * sin(angle),
      translated.dx * sin(angle) + translated.dy * cos(angle),
    );
    return rotated + center;
  }

  Future<void> initCamera() async {
    try {
      _availableCameras = await availableCameras();
      _selectedCameraIndex = _availableCameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      await _startCamera(_availableCameras[_selectedCameraIndex]);
      isCameraOn.value = true;
    } catch (e) {
      cameraError.value = e.toString();
      isCameraOn.value = false;
    }
  }

  Future<void> _startCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await cameraController.initialize();
    _previewSize = cameraController.value.previewSize;
    isCameraInitialized.value = true;
    await cameraController.startImageStream(_processCameraImage);
  }

  Future<void> switchCamera() async {
    if (_availableCameras.length < 2) return;

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;

    await cameraController.stopImageStream();
    await cameraController.dispose();
    isCameraInitialized.value = false;

    await _startCamera(_availableCameras[_selectedCameraIndex]);
  }

  void toggleCamera() async {
    if (isCameraOn.value) {
      await cameraController.stopImageStream();
      await cameraController.dispose();
      isCameraInitialized.value = false;
      isCameraOn.value = false;
    } else {
      await initCamera();
    }
  }

  Future<void> initVideo() async {
    final args = Get.arguments;
    final path = args?['videoPath'] ?? 'assets/sample_video.mp4';
    videoController = VideoPlayerController.asset(path);

    await videoController.initialize();
    isVideoInitialized.value = true;
    videoController.setLooping(true);
    videoController.play();
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final nv21 = convertCameraImageToNV21(image);
      if (nv21 == null) return;

      await platform.invokeMethod('handMarkerStream', {
        'bytes': nv21,
        'width': image.width,
        'height': image.height,
        'poseLandmarks': [], // Optional, not used
      });
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Uint8List? convertCameraImageToNV21(CameraImage image) {
    if (image.format.group != ImageFormatGroup.yuv420) return null;

    final width = image.width;
    final height = image.height;
    final ySize = width * height;
    final uvSize = width * height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    final Plane yPlane = image.planes[0];
    int offset = 0;
    for (int row = 0; row < height; row++) {
      nv21.setRange(
        offset,
        offset + width,
        yPlane.bytes,
        row * yPlane.bytesPerRow,
      );
      offset += width;
    }

    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];
    final int uvRowStride = uPlane.bytesPerRow;
    final int uvPixelStride = uPlane.bytesPerPixel!;

    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final uIndex = row * uvRowStride + col * uvPixelStride;
        final vIndex = row * vPlane.bytesPerRow + col * vPlane.bytesPerPixel!;
        nv21[offset++] = vPlane.bytes[vIndex];
        nv21[offset++] = uPlane.bytes[uIndex];
      }
    }

    return nv21;
  }

  @override
  void onClose() {
    if (isCameraInitialized.value) {
      cameraController.dispose();
    }
    if (isVideoInitialized.value) {
      videoController.dispose();
    }
    gestureModel.close();
    super.onClose();
  }
}
