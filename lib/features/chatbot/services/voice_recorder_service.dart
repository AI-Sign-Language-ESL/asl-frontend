import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum RecorderState { idle, recording, stopped, cancelled }

class VoiceRecorderService {
  FlutterSoundRecorder? _recorder;
  RecorderState _state = RecorderState.idle;
  String? _recordedPath;
  double _duration = 0;
  Timer? _timer;
  bool _isInitialized = false;

  RecorderState get state => _state;
  String? get recordedPath => _recordedPath;
  double get duration => _duration;
  bool get isRecording => _state == RecorderState.recording;
  bool get hasRecording => _state == RecorderState.stopped && _recordedPath != null;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('[VoiceRecorder] Init failed: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    final hasPermission = await requestPermission();
    if (!hasPermission) return false;

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder!.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
      );

      _recordedPath = path;
      _state = RecorderState.recording;
      _duration = 0;

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration += 1;
      });

      return true;
    } catch (e) {
      debugPrint('[VoiceRecorder] Start failed: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    if (_state != RecorderState.recording || _recorder == null) return null;

    try {
      await _recorder!.stopRecorder();
      _timer?.cancel();
      _state = RecorderState.stopped;
      return _recordedPath;
    } catch (e) {
      debugPrint('[VoiceRecorder] Stop failed: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    if (_recorder == null) return;

    if (_state == RecorderState.recording) {
      await _recorder!.stopRecorder();
    }

    _timer?.cancel();
    _state = RecorderState.cancelled;
    _duration = 0;
    _recordedPath = null;
  }

  Future<void> dispose() async {
    _timer?.cancel();
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    _isInitialized = false;
    _state = RecorderState.idle;
  }

  String get formattedDuration {
    final minutes = (_duration / 60).floor();
    final seconds = (_duration % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
