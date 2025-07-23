import 'package:flutter/material.dart';

class HandLandmarkPainter extends CustomPainter {
  final List<List<Offset>> hands;
  final bool showLabels;

  HandLandmarkPainter(this.hands, {this.showLabels = true});

  @override
  void paint(Canvas canvas, Size size) {
    final landmarkPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    final connectionPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final baseConnectionPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final hand in hands) {
      if (hand.length < 21) {
        // Draw only points if not enough landmarks
        for (final point in hand) {
          canvas.drawCircle(point, 5, landmarkPaint);
        }
        continue;
      }

      // Draw connections for each finger
      const fingerIndices = [
        [0, 1, 2, 3, 4], // Thumb
        [0, 5, 6, 7, 8], // Index
        [0, 9, 10, 11, 12], // Middle
        [0, 13, 14, 15, 16], // Ring
        [0, 17, 18, 19, 20], // Pinky
      ];

      for (final finger in fingerIndices) {
        for (int i = 0; i < finger.length - 1; i++) {
          canvas.drawLine(
              hand[finger[i]], hand[finger[i + 1]], connectionPaint);
        }
      }

      // Draw base connection using Path for smoother look
      final basePoints = [0, 5, 9, 13, 17];
      final path = Path()
        ..moveTo(hand[basePoints[0]].dx, hand[basePoints[0]].dy);
      for (int i = 1; i < basePoints.length; i++) {
        path.lineTo(hand[basePoints[i]].dx, hand[basePoints[i]].dy);
      }
      canvas.drawPath(path, baseConnectionPaint);

      // Draw landmark points and optionally indices
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      final textStyle = const TextStyle(color: Colors.yellow, fontSize: 12);

      for (int i = 0; i < hand.length; i++) {
        final point = hand[i];
        canvas.drawCircle(point, 5, landmarkPaint);

        if (showLabels) {
          textPainter.text = TextSpan(text: '$i', style: textStyle);
          textPainter.layout();
          textPainter.paint(canvas, point + const Offset(5, -12));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
