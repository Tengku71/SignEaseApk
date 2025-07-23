import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/app/data/services/gesture_model.dart';

class TranscribeController extends GetxController {
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final RxList<List<Offset>> handLandmarks = <List<Offset>>[].obs;
  final Rx<Size?> previewSize = Rx<Size?>(null);
  final RxBool isSwitching = false.obs;
  final RxBool isCameraReady = false.obs;
  final RxBool showLandmarks = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxString predictedLabel = ''.obs;
  final RxBool ttsEnabled = true.obs;

  bool _isSwitchingInternally = false;
  bool _isStreaming = false;

  static const MethodChannel _channel = MethodChannel('hand_landmarker');

  late final GestureModel _gestureModel;
  late final FlutterTts _flutterTts;

  String _lastSpokenLabel = '';
  DateTime _lastSpokenTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    _gestureModel = GestureModel()..loadModel();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('id-ID');
    _flutterTts.setSpeechRate(0.5);
    _initializeCamera();
    _setupMethodChannelListener();
  }

  @override
  void onClose() {
    _disposeCamera();
    super.onClose();
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
    final allPoints = <Offset>[];
    final Size targetSize = previewSize.value!;

    for (final hand in hands) {
      final List<Offset> points = [];
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

        if (isFrontCamera.value) normY = targetSize.height - normY;

        points.add(Offset(normX, normY));
        input
          ..add(normX.clamp(0, targetSize.width) / targetSize.width)
          ..add(normY.clamp(0, targetSize.height) / targetSize.height);
      }
      allPoints.addAll(points);
    }

    // Dummy pose data (12 values = 6 keypoints x 2)
    input.addAll(List<double>.filled(12, 0.0));

    // Pad input to 54 features if needed
    while (input.length < 54) input.add(0.0);

    handLandmarks.value = [allPoints];

    if (_gestureModel.isLoaded) {
      final label = _gestureModel.predictLabel(input);
      predictedLabel.value = label;
      _speakIfStable(label);
    } else {
      predictedLabel.value = '';
    }
  }

  void _speakIfStable(String label) async {
    if (!ttsEnabled.value) return;

    final now = DateTime.now();
    if (_lastSpokenLabel == label) {
      if (now.difference(_lastSpokenTime).inSeconds >= 1) {
        await _flutterTts.speak(label);
        _lastSpokenTime = now.add(const Duration(seconds: 1000));
      }
    } else {
      _lastSpokenLabel = label;
      _lastSpokenTime = now;
    }
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
        'poseLandmarks': [], // Empty pose since it's not used anymore
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

  Future<void> _disposeCamera() async {
    try {
      if (cameraController.value != null) {
        await cameraController.value!.stopImageStream();
        await cameraController.value!.dispose();
        cameraController.value = null;
      }
    } catch (e) {
      print('Dispose camera error: $e');
    } finally {
      _isStreaming = false;
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
