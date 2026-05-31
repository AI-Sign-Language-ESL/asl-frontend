import 'package:flutter/foundation.dart';
import 'package:tafahom_english_light/core/network/api_exceptions.dart';

import '../models/chat_message.dart';
import '../models/welcome_data.dart';
import '../services/chat_service.dart';
import '../services/voice_recorder_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final VoiceRecorderService _recorderService = VoiceRecorderService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  WelcomeData _welcomeData = WelcomeData.empty;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  WelcomeData get welcomeData => _welcomeData;
  VoiceRecorderService get recorder => _recorderService;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _chatService.fetchHistory();
    } catch (e) {
      _error = _formatError(e);
      debugPrint('[ChatProvider] Load history failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWelcomeData() async {
    try {
      _welcomeData = await _chatService.fetchWelcomeData();
      notifyListeners();
    } catch (e) {
      debugPrint('[ChatProvider] Fetch welcome data failed: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      type: MessageType.text,
      content: text.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    _messages = [..._messages, userMessage];
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final history = _messages.where((m) => m.status != MessageStatus.sending).toList();
      final response = await _chatService.sendMessage(
        message: text.trim(),
        history: history,
      );

      _messages = [
        ..._messages.where((m) => m.id != userMessage.id),
        userMessage.copyWith(status: MessageStatus.sent),
        response,
      ];
    } catch (e) {
      _messages = [
        ..._messages.where((m) => m.id != userMessage.id),
        userMessage.copyWith(status: MessageStatus.error),
      ];
      _error = _formatError(e);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> sendVoiceMessage({
    required String audioPath,
    required double duration,
    String? transcription,
  }) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      type: MessageType.voice,
      content: transcription ?? 'Voice message',
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
      audioDuration: duration,
    );

    _messages = [..._messages, userMessage];
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final history = _messages.where((m) => m.status != MessageStatus.sending).toList();
      final response = await _chatService.sendVoiceMessage(
        audioPath: audioPath,
        duration: duration,
        transcription: transcription,
        history: history,
      );

      _messages = [
        ..._messages.where((m) => m.id != userMessage.id),
        userMessage.copyWith(status: MessageStatus.sent),
        response,
      ];
    } catch (e) {
      _messages = [
        ..._messages.where((m) => m.id != userMessage.id),
        userMessage.copyWith(status: MessageStatus.error),
      ];
      _error = _formatError(e);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _chatService.clearHistory();
      _messages = [];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = _formatError(e);
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> startRecording() async {
    final ok = await _recorderService.startRecording();
    notifyListeners();
    return ok;
  }

  Future<String?> stopRecording() async {
    final path = await _recorderService.stopRecording();
    notifyListeners();
    return path;
  }

  Future<void> cancelRecording() async {
    await _recorderService.cancelRecording();
    notifyListeners();
  }

  void retryLast() {
    final lastUser = _messages.where((m) => m.isUser && m.hasError).toList().lastOrNull;
    if (lastUser == null) return;

    _messages = _messages.where((m) => m.id != lastUser.id).toList();
    notifyListeners();

    if (lastUser.isText) {
      sendMessage(lastUser.content);
    }
  }

  String _formatError(dynamic e) {
    if (e is NetworkException) return 'No internet connection. Please check your network.';
    if (e is UnauthorizedException) return 'Session expired. Please log in again.';
    if (e is ServerException) return 'Server error. Please try again later.';
    if (e is RateLimitException) return 'Too many requests. Please wait a moment.';
    if (e is ApiException) return e.message;
    return 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _recorderService.dispose();
    super.dispose();
  }
}
