import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../../services/translation_websocket_service.dart';
import '../models/landmark_data.dart';
import '../services/landmark_detector.dart';
import '../services/frame_buffer.dart';

enum SignToTextStatus {
  idle,
  connecting,
  connected,
  translating,
  error,
}

class SignToTextProvider extends ChangeNotifier {
  final TranslationWebSocketService _wsService;
  final LandmarkDetector _detector;
  final FrameBuffer _buffer;

  SignToTextStatus _status = SignToTextStatus.idle;
  String? _currentGloss;
  String? _currentText;
  String? _error;
  bool _isTranslating = false;
  bool _cameraActive = false;
  bool _showOverlay = true;
  FrameLandmarks? _latestLandmarks;
  CameraImage? _latestCameraImage;
  CameraDescription? _latestCamera;
  StreamSubscription? _eventSub;
  bool _awaitingConnected = false;

  SignToTextProvider()
      : _wsService = TranslationWebSocketService(),
        _detector = LandmarkDetector(),
        _buffer = FrameBuffer();

  SignToTextStatus get status => _status;
  String? get currentGloss => _currentGloss;
  String? get currentText => _currentText;
  String? get error => _error;
  bool get isTranslating => _isTranslating;
  bool get cameraActive => _cameraActive;
  bool get showOverlay => _showOverlay;
  FrameLandmarks? get latestLandmarks => _latestLandmarks;
  CameraImage? get latestCameraImage => _latestCameraImage;
  CameraDescription? get latestCamera => _latestCamera;
  bool get isConnected =>
      _status == SignToTextStatus.connected ||
      _status == SignToTextStatus.translating;

  Future<void> init() async {
    await _detector.initialize();
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSub?.cancel();
    _eventSub = _wsService.events.listen(_handleEvent);
  }

  void _handleEvent(TranslationEvent event) {
    switch (event.type) {
      case TranslationEventType.connectionStateChanged:
        if (event.error == 'connecting') {
          _status = SignToTextStatus.connecting;
          _error = null;
        } else if (event.error == 'disconnected') {
          _status = SignToTextStatus.idle;
          _isTranslating = false;
          _buffer.reset();
        } else if (event.error == 'connected') {
          _status = SignToTextStatus.connected;
          _error = null;
        }
        notifyListeners();

      case TranslationEventType.connected:
        _status = SignToTextStatus.connected;
        _error = null;
        if (_awaitingConnected) {
          _awaitingConnected = false;
        }
        notifyListeners();

      case TranslationEventType.translationStarted:
        _status = SignToTextStatus.translating;
        _isTranslating = true;
        _currentGloss = null;
        _currentText = null;
        _error = null;
        _buffer.reset();
        notifyListeners();

      case TranslationEventType.glossReceived:
        _currentGloss = event.gloss;
        _status = SignToTextStatus.translating;
        notifyListeners();

      case TranslationEventType.translationReceived:
        _currentGloss = event.gloss;
        _currentText = event.text;
        _status = SignToTextStatus.connected;
        _error = null;
        notifyListeners();

      case TranslationEventType.translationError:
        _error = event.error;
        _status = SignToTextStatus.error;
        notifyListeners();
    }
  }

  Future<void> startTranslation() async {
    _error = null;
    _currentGloss = null;
    _currentText = null;
    _cameraActive = true;
    _isTranslating = true;
    _awaitingConnected = true;
    _status = SignToTextStatus.connecting;
    notifyListeners();

    await _detector.initialize();
    _buffer.reset();
    _wsService.startSession(language: 'ar');
  }

  void stopTranslation() {
    _cameraActive = false;
    _isTranslating = false;
    _awaitingConnected = false;
    _wsService.stopSession();
    _buffer.reset();
    _status = SignToTextStatus.idle;
    _error = null;
    notifyListeners();
  }

  void toggleOverlay() {
    _showOverlay = !_showOverlay;
    notifyListeners();
  }

  void onCameraImage(CameraImage image, CameraDescription camera) async {
    if (!_isTranslating || _detector.isDisposed) return;

    _latestCameraImage = image;
    _latestCamera = camera;

    final landmarks = await _detector.processImage(image, camera);
    if (landmarks == null) return;

    _latestLandmarks = landmarks;
    _buffer.add(landmarks);

    final sequence = _buffer.getSequenceToSend();
    if (sequence != null) {
      _wsService.sendLandmarks(sequence);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _wsService.dispose();
    _detector.dispose();
    super.dispose();
  }
}
