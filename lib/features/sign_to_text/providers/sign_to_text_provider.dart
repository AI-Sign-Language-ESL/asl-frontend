import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../../services/translation_websocket_service.dart';
import '../../../services/translation_http_service.dart';
import '../models/landmark_data.dart';
import '../services/landmark_detector.dart';
import '../services/frame_buffer.dart';

enum SignToTextStatus {
  idle,
  connecting,
  connected,
  translating,
  cooldown,
  error,
}

enum TranslationMode {
  webSocket,
  http,
}

class SignToTextProvider extends ChangeNotifier {
  final TranslationWebSocketService _wsService;
  final TranslationHttpService _httpService;
  final LandmarkDetector _detector;
  final FrameBuffer _buffer;

  SignToTextStatus _status = SignToTextStatus.idle;
  TranslationMode _mode = TranslationMode.webSocket;
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
  bool _awaitingPrediction = false;
  String _lastPrediction = '';

  SignToTextProvider()
      : _wsService = TranslationWebSocketService(),
        _httpService = TranslationHttpService(),
        _detector = LandmarkDetector(),
        _buffer = FrameBuffer();

  SignToTextStatus get status => _status;
  TranslationMode get mode => _mode;
  int get frameCount => _buffer.frameCount;
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
      _status == SignToTextStatus.translating ||
      _status == SignToTextStatus.cooldown ||
      (_mode == TranslationMode.http && _isTranslating);

  Future<void> init() async {
    await _detector.initialize();
    _listenToEvents();
  }

  void setMode(TranslationMode newMode) {
    if (_mode == newMode) return;
    if (_isTranslating) {
      stopTranslation();
    }
    _mode = newMode;
    notifyListeners();
  }

  void _listenToEvents() {
    _eventSub?.cancel();
    _eventSub = _wsService.events.listen(_handleEvent);
  }

  void _handleEvent(TranslationEvent event) {
    if (_mode != TranslationMode.webSocket) return;

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
        break;

      case TranslationEventType.connected:
        _status = SignToTextStatus.connected;
        _error = null;
        if (_awaitingPrediction) {
          _awaitingPrediction = false;
        }
        notifyListeners();
        break;

      case TranslationEventType.translationStarted:
        _status = SignToTextStatus.translating;
        _isTranslating = true;
        _currentGloss = null;
        _currentText = null;
        _error = null;
        _buffer.reset();
        notifyListeners();
        break;

      case TranslationEventType.glossReceived:
        _currentGloss = event.gloss;
        _status = SignToTextStatus.translating;
        notifyListeners();
        break;

      case TranslationEventType.translationReceived:
        if (event.gloss == 'NO_SIGN') {
          _currentText = 'No Sign Detected';
          _currentGloss = null;
        } else {
          _currentGloss = event.gloss;
          _currentText = event.text;
        }
        _status = SignToTextStatus.connected;
        _error = null;
        _buffer.reset();
        _awaitingPrediction = false;
        notifyListeners();
        break;

      case TranslationEventType.translationError:
        _error = event.error;
        _status = SignToTextStatus.error;
        _buffer.reset();
        _awaitingPrediction = false;
        notifyListeners();
        break;
    }
  }

  Future<void> startTranslation() async {
    _error = null;
    _currentGloss = null;
    _currentText = null;
    _cameraActive = true;
    _isTranslating = true;
    _awaitingPrediction = false;
    _lastPrediction = '';
    
    _status = _mode == TranslationMode.webSocket
        ? SignToTextStatus.connecting
        : SignToTextStatus.translating;
        
    notifyListeners();

    await _detector.initialize();
    _buffer.reset();

    if (_mode == TranslationMode.webSocket) {
      _wsService.startSession(language: 'ar');
    }
  }

  Future<void> stopTranslation() async {
    _cameraActive = false;
    _isTranslating = false;
    _awaitingPrediction = false;
    
    if (_mode == TranslationMode.webSocket) {
      _wsService.stopSession();
    } else if (_mode == TranslationMode.http && _currentGloss != null) {
      // NLP phase for HTTP when stopping
      await _finalizeHttpTranslation();
    }

    _buffer.reset();
    _status = SignToTextStatus.idle;
    _error = null;
    notifyListeners();
  }

  Future<void> _finalizeHttpTranslation() async {
    if (_currentGloss == null || _currentGloss!.isEmpty) return;
    final words = _currentGloss!.split(' ').where((w) => w.trim().isNotEmpty).toList();

    if (words.length == 1) {
      _currentText = _currentGloss;
      notifyListeners();
    } else if (words.length >= 2) {
      _status = SignToTextStatus.connecting; // showing loading state
      notifyListeners();
      try {
        final res = await _httpService.translateGloss(_currentGloss!);
        _currentText = res['text'] ?? _currentGloss;
      } catch (e) {
        debugPrint("NLP Error: $e");
        _currentText = _currentGloss;
        _error = "Failed to translate to natural sentence.";
      } finally {
        _status = SignToTextStatus.idle;
        notifyListeners();
      }
    }
  }

  void toggleOverlay() {
    _showOverlay = !_showOverlay;
    notifyListeners();
  }

  void onCameraImage(CameraImage image, CameraDescription camera) async {
    if (!_isTranslating || _detector.isDisposed || _awaitingPrediction) return;

    _latestCameraImage = image;
    _latestCamera = camera;

    final landmarks = await _detector.processImage(image, camera);
    if (landmarks == null) return;

    _latestLandmarks = landmarks;
    _buffer.add(landmarks);

    // Notify listeners so UI updates the frame count
    notifyListeners();

    final sequence = _buffer.getSequenceToSend();
    if (sequence != null) {
      _awaitingPrediction = true;
      if (_mode == TranslationMode.webSocket) {
        _wsService.sendLandmarks(sequence);
      } else {
        _sendSequenceToHttp(sequence);
      }
    }
  }

  Future<void> _sendSequenceToHttp(List<List<List<double>>> sequence) async {
    _status = SignToTextStatus.connecting; // Translates to "predicting" in UI logic
    notifyListeners();

    try {
      final response = await _httpService.predictModal(sequence);
      final prediction = response['prediction'] as String?;
      final confidence = (response['confidence'] as num?)?.toDouble() ?? 0.0;

      final isDuplicate = _lastPrediction == prediction;
      if (isDuplicate && confidence < 0.6) {
        debugPrint('Ignored duplicate low-confidence prediction: $prediction');
      } else {
        if (prediction != null && prediction != 'NO_SIGN') {
          _currentGloss = _currentGloss != null && _currentGloss!.isNotEmpty
              ? '$_currentGloss $prediction'
              : prediction;
          _lastPrediction = prediction;
        }
      }
    } catch (e) {
      debugPrint("HTTP translation error: $e");
      _error = e.toString();
    } finally {
      _buffer.reset();
      
      if (_isTranslating) {
        _status = SignToTextStatus.cooldown;
        notifyListeners();
        
        // Cooldown mimicking React's 1.5s
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (_isTranslating) {
          _awaitingPrediction = false;
          _status = SignToTextStatus.translating; // Back to collecting
          notifyListeners();
        }
      } else {
        _awaitingPrediction = false;
      }
    }
  }

  void clearTranslation() {
    _currentText = null;
    _currentGloss = null;
    _lastPrediction = '';
    _buffer.reset();
    notifyListeners();
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
