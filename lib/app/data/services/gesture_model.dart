import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class GestureModel {
  late Interpreter _interpreter;
  late List<String> _labels;
  late List<int> _inputShape;
  late List<int> _outputShape;
  bool isLoaded = false;

  List<String> get labels => _labels;

  Future<void> loadModel() async {
    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');

      // Load labels from asset
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      // Get tensor shapes
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;

      print('✅ Model loaded with ${_labels.length} labels');
      print('📐 Expected input shape: $_inputShape');
      print('📐 Expected output shape: $_outputShape');

      isLoaded = true;
    } catch (e) {
      print('❌ Failed to load model: $e');
      isLoaded = false;
    }
  }

  String predictLabel(List<double> input) {
    if (!isLoaded) {
      print('❌ Model not loaded');
      return '';
    }

    if (_labels.isEmpty || _outputShape[1] != _labels.length) {
      print('❌ Labels not matching model output');
      return '';
    }

    if (_inputShape.length < 2 || input.length != _inputShape[1]) {
      print(
          '❌ Invalid input shape: received ${input.length}, expected ${_inputShape[1]}');
      return '';
    }

    try {
      // Prepare input and output
      final inputBuffer =
          Float32List.fromList(input).reshape([_inputShape[0], _inputShape[1]]);
      final outputBuffer = List.filled(
              _outputShape[0] * _outputShape[1], 0.0)
          .reshape([_outputShape[0], _outputShape[1]]);

      _interpreter.run(inputBuffer, outputBuffer);

      final scores = outputBuffer[0];
      double maxScore = -1;
      int maxIndex = 0;

      for (int i = 0; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      final label = _labels[maxIndex];
      print('🎯 Predicted: $label | Score: ${maxScore.toStringAsFixed(4)}');

      return maxScore > 0.5 ? label : '';
    } catch (e) {
      print('❌ Prediction error: $e');
      return '';
    }
  }

  void close() {
    if (isLoaded) {
      _interpreter.close();
      isLoaded = false;
      print('🧹 Interpreter closed');
    }
  }
}
