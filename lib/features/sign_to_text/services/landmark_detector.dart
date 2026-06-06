import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:hand_detection/hand_detection.dart';

import '../models/landmark_data.dart';

class LandmarkDetector {
  PoseDetector? _poseDetector;
  HandDetector? _handDetector;
  bool _initialized = false;
  bool _disposed = false;

  bool get isInitialized => _initialized;
  bool get isDisposed => _disposed;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
          model: PoseDetectionModel.accurate,
        ),
      );
      _handDetector = await HandDetector.create();
      _initialized = true;
    } catch (e) {
      debugPrint('[LandmarkDetector] Init error: $e');
    }
  }

  Future<FrameLandmarks?> processImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_disposed || !_initialized) return null;
    try {
      final pose = await _detectPose(image, camera);

      final hands = await _handDetector!.detectFromCameraImage(
        image,
        maxDim: 640,
      );
      final (leftHand, rightHand) = _extractHandLandmarks(hands ?? []);

      return FrameLandmarks(pose: pose, leftHand: leftHand, rightHand: rightHand);
    } catch (e) {
      debugPrint('[LandmarkDetector] Process error: $e');
      return null;
    }
  }

  Future<List<LandmarkPoint>> _detectPose(
    CameraImage image,
    CameraDescription camera,
  ) async {
    try {
      final inputImage = _buildInputImage(image, camera.sensorOrientation);
      if (inputImage == null) {
        return List.filled(7, const LandmarkPoint(x: 0, y: 0, z: 0));
      }
      final poses = await _poseDetector!.processImage(inputImage);
      if (poses.isEmpty) {
        return List.filled(7, const LandmarkPoint(x: 0, y: 0, z: 0));
      }
      final pose = poses.first;

      final poseTypes = [
        PoseLandmarkType.nose,
        PoseLandmarkType.leftEye,
        PoseLandmarkType.rightEye,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.rightElbow,
      ];

      return poseTypes.map((type) {
        final lm = pose.landmarks[type];
        if (lm == null) return const LandmarkPoint(x: 0, y: 0, z: 0);
        return LandmarkPoint(x: lm.x, y: lm.y, z: lm.z ?? 0.0);
      }).toList();
    } catch (e) {
      debugPrint('[LandmarkDetector] Pose error: $e');
      return List.filled(7, const LandmarkPoint(x: 0, y: 0, z: 0));
    }
  }

  (List<LandmarkPoint>, List<LandmarkPoint>) _extractHandLandmarks(
    List<Hand> hands,
  ) {
    final leftPoints = <LandmarkPoint>[];
    final rightPoints = <LandmarkPoint>[];

    const handIndices = [
      HandLandmarkType.wrist,
      HandLandmarkType.thumbTip,
      HandLandmarkType.indexFingerMcp,
      HandLandmarkType.indexFingerTip,
      HandLandmarkType.middleFingerMcp,
      HandLandmarkType.middleFingerTip,
      HandLandmarkType.ringFingerMcp,
      HandLandmarkType.ringFingerTip,
      HandLandmarkType.pinkyFingerMcp,
      HandLandmarkType.pinkyFingerTip,
    ];

    for (final hand in hands) {
      if (!hand.hasLandmarks) continue;
      final target = hand.handedness == Handedness.left ? leftPoints : rightPoints;

      for (final type in handIndices) {
        final lm = hand.getLandmark(type);
        if (lm == null) {
          target.add(const LandmarkPoint(x: 0, y: 0, z: 0));
        } else {
          target.add(LandmarkPoint(x: lm.x, y: lm.y, z: 0.0));
        }
      }
    }

    final empty = List.filled(10, const LandmarkPoint(x: 0, y: 0, z: 0));
    return (
      leftPoints.length == 10 ? leftPoints : empty,
      rightPoints.length == 10 ? rightPoints : empty,
    );
  }

  InputImage? _buildInputImage(CameraImage image, int sensorOrientation) {
    try {
      final rotation = InputImageRotation.values[
        (sensorOrientation / 90).round() % 4
      ];
      final format = InputImageFormat.nv21;
      final size = Size(image.width.toDouble(), image.height.toDouble());

      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: format,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('[LandmarkDetector] BuildInputImage error: $e');
      return null;
    }
  }

  void dispose() {
    _disposed = true;
    _poseDetector?.close();
    _handDetector?.dispose();
    _poseDetector = null;
    _handDetector = null;
  }
}
