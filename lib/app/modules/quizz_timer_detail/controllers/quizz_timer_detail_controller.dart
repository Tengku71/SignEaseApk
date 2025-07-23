import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/app/data/services/auth_services.dart';
import 'package:mobile/app/data/services/gesture_model.dart';
import 'package:mobile/app/routes/app_pages.dart';

class QuizzTimerDetailController extends GetxController {
  final RxInt level = 0.obs;
  final RxInt duration = 30.obs;
  final RxInt remainingSeconds = 0.obs;

  final RxList<String> questions = <String>[].obs;
  final RxBool isRunning = false.obs;
  final RxBool isCompleted = false.obs;
  final RxBool isLoading = false.obs;

  final RxString predictedLabel = ''.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isCameraReady = false.obs;
  final RxBool isSwitching = false.obs;

  final RxInt currentQuestionIndex = 0.obs;
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final Rx<Size?> previewSize = Rx<Size?>(null);
  final RxList<List<Offset>> handLandmarks = <List<Offset>>[].obs;

  final AuthService _authService = AuthService();
  late final GestureModel _gestureModel;

  static const MethodChannel _channel = MethodChannel('hand_landmarker');
  Timer? _timer;
  bool _isStreaming = false;
  bool _isSwitchingInternally = false;
  bool _scoreSent = false;

  @override
  void onInit() {
    super.onInit();
    _gestureModel = GestureModel()..loadModel();
    _setupMethodChannelListener();
    _initLevelAndLoadQuestions();
    _initializeCamera();
  }

  void _initLevelAndLoadQuestions() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      level.value = args['level'] ?? 3;
    } else if (args is int) {
      level.value = args;
    } else {
      level.value = 3;
    }

    duration.value = {
          3: 30,
          5: 45,
          8: 60,
        }[level.value] ??
        30;

    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    isLoading.value = true;
    try {
      final result = await _authService.getQuestionsByLevel(level.value);
      if (result.isEmpty) throw Exception("Tidak ada soal");

      final maxCount = level.value;
      questions.assignAll(result.take(maxCount).toList());
      currentQuestionIndex.value = 0;

      startTimer();
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains("403") ||
          errorMessage.contains("sudah mencoba") ||
          errorMessage.contains("limit") ||
          errorMessage.contains("sebanyak 3 kali")) {
        // tampilkan dialog limit
        showLimitDialog(
            "Kamu sudah mengambil level ini 3 kali dalam minggu ini");
      } else {
        Get.snackbar("Gagal", "Fetch error: $errorMessage");
      }
      isCompleted.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void showLimitDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, color: Colors.orange, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Limit Tercapai",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
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
      if (Get.isDialogOpen ?? false) Get.back(); // tutup dialog
      Get.offAllNamed(Routes.QUIZZ_TIMER); // kembali ke halaman quiz
    });
  }

  void startTimer() {
    _timer?.cancel();
    remainingSeconds.value = duration.value;
    isRunning.value = true;
    isCompleted.value = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isCompleted.value = true;
        stopTimer();
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed(Routes.QUIZZ_TIMER);
        });
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    isRunning.value = false;
  }

  Future<void> _initializeCamera() async {
    try {
      cameras.value = await availableCameras();
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      isFrontCamera.value = selected.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      cameraController.value = controller;
      previewSize.value = controller.value.previewSize;
      await startImageStream();
      isCameraReady.value = true;
    } catch (e) {
      print("Camera init error: $e");
    }
  }

  Future<void> switchCamera() async {
    if (cameras.isEmpty || isSwitching.value || _isSwitchingInternally) return;

    isSwitching.value = true;
    _isSwitchingInternally = true;
    isCameraReady.value = false;
    handLandmarks.clear();
    predictedLabel.value = '';

    try {
      final current = cameraController.value?.description;
      final currentIndex = cameras.indexWhere((c) => c == current);
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

  Future<void> startImageStream() async {
    if (_isStreaming) return;
    _isStreaming = true;

    await cameraController.value?.startImageStream((CameraImage image) async {
      final nv21 = convertCameraImageToNV21(image);
      if (nv21 == null) return;

      await _channel.invokeMethod('handMarkerStream', {
        'bytes': nv21,
        'width': image.width,
        'height': image.height,
      });
    });
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
      handLandmarks.clear();
      return;
    }

    final input = <double>[];
    final targetSize = previewSize.value!;

    final hand =
        hands.first; // Gunakan hanya satu tangan (misal tangan pertama)
    int count = 0;

    for (final point in hand) {
      if (count >= 27) break; // gunakan hanya 27 titik
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

      count++;
    }

    while (input.length < 54) input.add(0.0); // padding jika kurang dari 54

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
    if (_scoreSent || isCompleted.value) return;

    final expected = questions[currentQuestionIndex.value];
    if (label.toLowerCase().trim() == expected.toLowerCase().trim()) {
      _scoreSent = true;

      try {
        int baseScore = {
              3: 5,
              5: 7,
              8: 10,
            }[level.value] ??
            5;
        int bonusTime = (remainingSeconds.value / 2).floor();
        int totalScore = baseScore + bonusTime;

        // ✅ Putar suara
        try {
          await AudioPlayer().play(AssetSource('sounds/level_up.mp3'));
        } catch (e) {
          print("⚠️ Gagal memainkan suara: $e");
        }

        await _authService.submitScore(totalScore);

        showSuccessDialog(
          "Benar",
          "Soal ${currentQuestionIndex.value + 1}/${questions.length} benar! +$baseScore poin +$bonusTime detik",
        );

        currentQuestionIndex.value++;
        _scoreSent = false;

        if (currentQuestionIndex.value >= questions.length) {
          isCompleted.value = true;
          stopTimer();
        }
      } catch (e) {
        _scoreSent = false;
        Get.snackbar("Error", "Gagal kirim skor: $e");
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

      // ⏭ lanjut soal jika masih ada
      if (currentQuestionIndex.value < questions.length) {
        _scoreSent = false; // reset untuk soal berikutnya
      }

      // ✅ selesai jika semua soal terjawab
      if (currentQuestionIndex.value >= questions.length) {
        isCompleted.value = true;
        stopTimer();
        Get.offAllNamed(Routes.QUIZZ_TIMER);
      }
    });
  }

  @override
  void onClose() {
    stopTimer();
    _disposeCamera();
    super.onClose();
  }
}
