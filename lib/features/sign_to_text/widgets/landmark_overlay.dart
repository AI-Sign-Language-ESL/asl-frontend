import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/landmark_data.dart';

class LandmarkOverlay extends StatelessWidget {
  final FrameLandmarks landmarks;
  final CameraImage cameraImage;
  final Size previewSize;
  final CameraDescription camera;

  const LandmarkOverlay({
    super.key,
    required this.landmarks,
    required this.cameraImage,
    required this.previewSize,
    required this.camera,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CustomPaint(
          painter: _LandmarkPainter(
            landmarks: landmarks,
            cameraImage: cameraImage,
            previewSize: previewSize,
            camera: camera,
          ),
        ),
      ),
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final FrameLandmarks landmarks;
  final CameraImage cameraImage;
  final Size previewSize;
  final CameraDescription camera;

  _LandmarkPainter({
    required this.landmarks,
    required this.cameraImage,
    required this.previewSize,
    required this.camera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final textPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    void drawLandmarks(List<LandmarkPoint> points, Color color) {
      paint.color = color;
      for (final point in points) {
        final offset = _mapToView(point.x, point.y, size);
        canvas.drawCircle(offset, 5, paint);
      }
    }

    void drawConnections(List<LandmarkPoint> points, Color color) {
      paint.color = color;
      paint.style = PaintingStyle.stroke;
      for (int i = 0; i < points.length - 1; i++) {
        final a = _mapToView(points[i].x, points[i].y, size);
        final b = _mapToView(points[i + 1].x, points[i + 1].y, size);
        canvas.drawLine(a, b, paint);
      }
      paint.style = PaintingStyle.fill;
    }

    drawLandmarks(landmarks.pose, Colors.cyanAccent);
    drawLandmarks(landmarks.leftHand, Colors.greenAccent);
    drawLandmarks(landmarks.rightHand, Colors.orangeAccent);

    drawConnections(landmarks.pose, Colors.cyanAccent.withValues(alpha: 0.5));
  }

  Offset _mapToView(double x, double y, Size viewSize) {
    final scaleX = previewSize.width / cameraImage.width;
    final scaleY = previewSize.height / cameraImage.height;
    final rotated = camera.sensorOrientation == 90 || camera.sensorOrientation == 270;
    final double rx = rotated ? y : x;
    final double ry = rotated ? (cameraImage.width - x) : y;
    final bool mirror = camera.lensDirection == CameraLensDirection.front;
    final double mx = mirror ? previewSize.width - rx * scaleX : rx * scaleX;
    return Offset(mx, ry * scaleY);
  }

  @override
  bool shouldRepaint(covariant _LandmarkPainter oldDelegate) => true;
}
