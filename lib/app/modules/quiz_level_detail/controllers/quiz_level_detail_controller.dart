import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/data/services/gesture_model.dart';
import 'package:mobile/app/routes/app_pages.dart';

class QuizLevelDetailController extends GetxController {
  final RxString levelLabel = ''.obs;
  final RxInt levelIndex = 0.obs;
  final RxString predictedLabel = ''.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isCameraReady = false.obs;
  final RxBool isSwitching = false.obs;

  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final Rx<Size?> previewSize = Rx<Size?>(null);

  static const MethodChannel _channel = MethodChannel('hand_landmarker');

  bool _isStreaming = false;
  bool _isSwitchingInternally = false;
  bool _scoreSent = false;

  late final GestureModel _gestureModel;
  final AuthService _authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _gestureModel = GestureModel()..loadModel();
    _initLevel();
    _initializeCamera();
    _setupMethodChannelListener();
  }

  @override
  void onClose() {
    _disposeCamera();
    AudioPlayer().dispose();
    super.onClose();
  }

  void _initLevel() {
    final arg = Get.arguments;
    if (arg is Map<String, dynamic>) {
      levelLabel.value = arg['label'] ?? 'No label';
      levelIndex.value = arg['index'] ?? 0;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras.value = await availableCameras();
      final selectedCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      isFrontCamera.value =
          selectedCamera.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      cameraController.value = controller;
      previewSize.value = controller.value.previewSize;

      await startImageStream();
      isCameraReady.value = true;
    } catch (e) {
      print('Camera init error: $e');
    }
  }

  Future<void> _disposeCamera() async {
    try {
      if (cameraController.value != null) {
        await cameraController.value!.stopImageStream();
        await cameraController.value!.dispose();
        cameraController.value = null;
      }
    } catch (e) {
      print('Dispose error: $e');
    } finally {
      _isStreaming = false;
    }
  }

  void _setupMethodChannelListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'updateResult') {
        _processLandmarkResult(call.arguments);
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

  void _processLandmarkResult(dynamic result) {
    final data = result as Map;
    final hands = data['landmarks'] as List<dynamic>;
    final width = data['width'] as int;
    final height = data['height'] as int;

    if (hands.isEmpty || previewSize.value == null) {
      predictedLabel.value = '';
      return;
    }

    final input = <double>[];
    final Size targetSize = previewSize.value!;

    for (final hand in hands) {
      for (final point in hand) {
        final x = (point['x'] as double) * width;
        final y = (point['y'] as double) * height;

        final rotated = rotateAroundCenter(
          Offset(x, y),
          Size(width.toDouble(), height.toDouble()),
          90,
        );

        final normX = rotated.dx * targetSize.width / width;
        double normY = rotated.dy * targetSize.height / height;

        if (isFrontCamera.value) {
          normY = targetSize.height - normY;
        }

        input
          ..add(normX.clamp(0, targetSize.width) / targetSize.width)
          ..add(normY.clamp(0, targetSize.height) / targetSize.height);
      }
    }

    // Fill with 0.0 if less than 42 features (e.g., hand not detected fully)
    while (input.length < 42) input.add(0.0);

    // Append 12 dummy pose values to match total 54 inputs
    input.addAll(List.filled(12, 0.0));

    if (input.length == 54 && _gestureModel.isLoaded) {
      try {
        final label = _gestureModel.predictLabel(input);
        predictedLabel.value = label;
        _checkScoreCondition(label);
      } catch (_) {
        predictedLabel.value = '';
      }
    } else {
      predictedLabel.value = '';
    }
  }

  void _checkScoreCondition(String label) async {
    if (_scoreSent) return;

    if (label.toLowerCase().trim() == levelLabel.value.toLowerCase().trim()) {
      _scoreSent = true;

      try {
        await AudioPlayer().play(AssetSource('sounds/level_up.mp3'));
        await _authService.sendProgress(levelIndex.value.toString());
        showSuccessDialog("Berhasil", "Jawaban benar!");
      } catch (e) {
        _scoreSent = false;
        Get.dialog(
          AlertDialog(
            title: const Text("Gagal"),
            content: const Text("Gagal menyimpan progress"),
            actions: [
              TextButton(onPressed: Get.back, child: const Text("Tutup")),
            ],
          ),
        );
      }
    }
  }

  void showSuccessDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(Routes.QUIZZ_LEVEL);
    });
  }

  Future<void> startImageStream() async {
    if (_isStreaming) return;
    _isStreaming = true;
    isCameraReady.value = false;

    await cameraController.value?.startImageStream((CameraImage image) async {
      final nv21 = convertCameraImageToNV21(image);
      if (nv21 == null) return;

      await _channel.invokeMethod('handMarkerStream', {
        'bytes': nv21,
        'width': image.width,
        'height': image.height,
      });
    });

    isCameraReady.value = true;
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

  Future<void> switchCamera() async {
    if (cameras.isEmpty || isSwitching.value || _isSwitchingInternally) return;

    isSwitching.value = true;
    _isSwitchingInternally = true;
    isCameraReady.value = false;
    predictedLabel.value = '';

    try {
      final currentCamera = cameraController.value?.description;
      final currentIndex = cameras.indexWhere((cam) => cam == currentCamera);
      final nextIndex = (currentIndex + 1) % cameras.length;
      final newCamera = cameras[nextIndex];
      isFrontCamera.value =
          newCamera.lensDirection == CameraLensDirection.front;

      await _disposeCamera();
      await Future.delayed(const Duration(milliseconds: 600));

      final controller = CameraController(
        newCamera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      cameraController.value = controller;
      previewSize.value = controller.value.previewSize;

      _isStreaming = false;
      await startImageStream();
      isCameraReady.value = true;
    } catch (e) {
      print('Switch camera error: $e');
    } finally {
      isSwitching.value = false;
      _isSwitchingInternally = false;
    }
  }
}
