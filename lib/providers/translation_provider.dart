import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import '../services/translation_websocket_service.dart';

class TranslationHistoryEntry {
  final String gloss;
  final String text;
  final DateTime timestamp;

  TranslationHistoryEntry({
    required this.gloss,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum TranslationStatus { idle, connecting, ready, translating, error }

class TranslationProvider extends ChangeNotifier {
  final TranslationWebSocketService _wsService = TranslationWebSocketService();
  final FlutterTts _tts = FlutterTts();

  TranslationStatus _status = TranslationStatus.idle;
  bool _isSpeaking = false;
  bool _isTesting = false;
  bool _cameraActive = false;
  String? _currentGloss;
  String? _currentText;
  String? _error;
  List<TranslationHistoryEntry> _history = [];
  StreamSubscription? _eventSub;

  TranslationStatus get status => _status;
  bool get isSpeaking => _isSpeaking;
  bool get isTesting => _isTesting;
  bool get cameraActive => _cameraActive;
  String? get currentGloss => _currentGloss;
  String? get currentText => _currentText;
  String? get error => _error;
  List<TranslationHistoryEntry> get history => List.unmodifiable(_history);

  bool get isConnected =>
      _status == TranslationStatus.ready ||
      _status == TranslationStatus.translating;

  TranslationProvider() {
    _initTts();
    _listenToEvents();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  void _listenToEvents() {
    _eventSub = _wsService.events.listen(_handleEvent);
  }

  void _handleEvent(TranslationEvent event) {
    switch (event.type) {
      case TranslationEventType.connectionStateChanged:
        if (event.error == 'connecting') {
          _status = TranslationStatus.connecting;
          _error = null;
        } else if (event.error == 'disconnected') {
          _status = TranslationStatus.idle;
        } else if (event.error == null) {
          _status = TranslationStatus.ready;
          _error = null;
        }
        notifyListeners();

      case TranslationEventType.translationStarted:
        _status = TranslationStatus.translating;
        _currentGloss = null;
        _currentText = null;
        _error = null;
        notifyListeners();

      case TranslationEventType.glossReceived:
        _currentGloss = event.gloss;
        _status = TranslationStatus.translating;
        notifyListeners();

      case TranslationEventType.translationReceived:
        _currentGloss = event.gloss;
        _currentText = event.text;
        _status = TranslationStatus.ready;
        _error = null;
        if (event.text != null && event.text!.isNotEmpty) {
          _history.insert(
            0,
            TranslationHistoryEntry(
              gloss: event.gloss ?? '',
              text: event.text!,
            ),
          );
          _speak(event.text!);
        }
        notifyListeners();

      case TranslationEventType.connected:
        _status = TranslationStatus.ready;
        _error = null;
        notifyListeners();

      case TranslationEventType.translationError:
        _error = event.error;
        _status = TranslationStatus.error;
        notifyListeners();
    }
  }

  Future<void> startSession() async {
    _error = null;
    _currentGloss = null;
    _currentText = null;
    notifyListeners();
    _wsService.connect();
  }

  void stopSession() {
    _wsService.disconnect();
    _currentGloss = null;
    _currentText = null;
    _status = TranslationStatus.idle;
    _error = null;
    notifyListeners();
  }

  void setCameraActive(bool active) {
    _cameraActive = active;
    if (active) {
      startSession();
    } else {
      stopSession();
    }
    notifyListeners();
  }

  Future<void> _speak(String text) async {
    try {
      _isSpeaking = true;
      notifyListeners();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[TranslationProvider] TTS error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    await _speak(text);
  }

  Future<void> testGloss(String gloss) async {
    _isTesting = true;
    _error = null;
    _currentGloss = gloss;
    _currentText = null;
    notifyListeners();

    try {
      final response = await ApiService.dio.post(
        '/sign-language/test-gloss/',
        data: {'gloss': gloss},
      );
      final data = response.data as Map<String, dynamic>;
      final translation = data['translation'] as String? ?? '';
      _currentText = translation;
      _isTesting = false;

      if (translation.isNotEmpty) {
        _history.insert(
          0,
          TranslationHistoryEntry(gloss: gloss, text: translation),
        );
        _speak(translation);
      }
      notifyListeners();
    } catch (e) {
      _isTesting = false;
      _error = 'Test translation failed: $e';
      notifyListeners();
    }
  }

  void clearHistory() {
    _history = [];
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
    _tts.stop();
    super.dispose();
  }
}
