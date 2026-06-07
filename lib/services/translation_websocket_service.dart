import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import '../services/api_service.dart';

enum TranslationEventType {
  translationStarted,
  glossReceived,
  translationReceived,
  translationError,
  connectionStateChanged,
  connected,
}

class TranslationEvent {
  final TranslationEventType type;
  final String? gloss;
  final String? text;
  final String? error;
  final Map<String, dynamic>? raw;

  TranslationEvent({
    required this.type,
    this.gloss,
    this.text,
    this.error,
    this.raw,
  });

  factory TranslationEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? '';
    switch (typeStr) {
      case 'connected':
        return TranslationEvent(type: TranslationEventType.connected);
      case 'translation_started':
        return TranslationEvent(type: TranslationEventType.translationStarted);
      case 'gloss':
        return TranslationEvent(
          type: TranslationEventType.glossReceived,
          gloss: json['gloss'] as String?,
          raw: json,
        );
      case 'translation':
        return TranslationEvent(
          type: TranslationEventType.translationReceived,
          gloss: json['gloss'] as String?,
          text: json['text'] as String?,
          raw: json,
        );
      case 'translation_error':
        return TranslationEvent(
          type: TranslationEventType.translationError,
          error: json['message'] as String? ?? json['error'] as String? ?? 'Translation error',
          raw: json,
        );
      default:
        return TranslationEvent(
          type: TranslationEventType.connectionStateChanged,
          error: 'connected',
          raw: json,
        );
    }
  }
}

class TranslationWebSocketService {
  WebSocketChannel? _channel;
  StreamController<TranslationEvent>? _eventController;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _disposed = false;
  bool _intentionalClose = false;
  String? _wsUrl;
  int _reconnectAttempts = 0;
  static const int _maxReconnectDelay = 30;
  StreamSubscription? _streamSub;
  bool _sessionActive = false;
  String _language = 'ar';

  Stream<TranslationEvent> get events {
    _eventController ??= StreamController<TranslationEvent>.broadcast();
    return _eventController!.stream;
  }

  bool get isConnected => _channel != null;

  void connect({String? url, String? token}) {
    _intentionalClose = false;
    _reconnectAttempts = 0;
    final t = token ?? ApiService.accessToken ?? '';
    
    String finalBaseUrl = url ?? '';
    if (finalBaseUrl.isEmpty) {
      String apiBase = ApiService.dio.options.baseUrl;
      if (apiBase.startsWith('https://')) {
        apiBase = apiBase.replaceFirst('https://', 'wss://');
      } else if (apiBase.startsWith('http://')) {
        apiBase = apiBase.replaceFirst('http://', 'ws://');
      }
      
      if (!kIsWeb && Platform.isAndroid) {
        apiBase = apiBase.replaceAll('localhost', '10.0.2.2')
                         .replaceAll('127.0.0.1', '10.0.2.2');
      }
      
      finalBaseUrl = '$apiBase/ws/translation/stream';
    }
    
    _wsUrl = '$finalBaseUrl?token=$t';
    debugPrint('[WebSocket] Preparing to connect to exactly: $_wsUrl');
    debugPrint('[WebSocket] Token length being sent: ${t.length}');
    _doConnect();
  }

  void _doConnect() {
    if (_disposed) return;
    _cleanup();
    try {
      debugPrint('[WebSocket] Attempting connection to: $_wsUrl');
      final uri = Uri.parse(_wsUrl!);
      final headers = <String, String>{};
      if (ApiService.accessToken != null && ApiService.accessToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${ApiService.accessToken}';
      }
      _channel = IOWebSocketChannel.connect(uri, headers: headers);
      
      _channel!.ready.then((_) {
        debugPrint('[WebSocket] Connection SUCCESS. Successfully connected to: $_wsUrl');
      }).catchError((error) {
        debugPrint('[WebSocket] Connection FAILED during ready phase. Error: $error');
      });

      _emitEvent(TranslationEvent(
        type: TranslationEventType.connectionStateChanged,
        error: 'connecting',
      ));
      _streamSub = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      _startHeartbeat();
    } catch (e) {
      debugPrint('[WebSocket] Synchronous connection exception: $e');
      _emitEvent(TranslationEvent(
        type: TranslationEventType.connectionStateChanged,
        error: 'disconnected',
      ));
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;

      if (data['action'] == 'pong' || data['type'] == 'pong') return;

      if (data['type'] == 'ping' || data.containsKey('ping')) {
        sendJson({'type': 'pong'});
        return;
      }

      final event = TranslationEvent.fromJson(data);
      _emitEvent(event);

      if (event.type == TranslationEventType.connected && _sessionActive) {
        sendStartTranslation();
      }
    } catch (e) {
      // ignore malformed messages
    }
  }

  void _onError(dynamic error) {
    debugPrint('[WebSocket] Stream error received: $error');
    _emitEvent(TranslationEvent(
      type: TranslationEventType.connectionStateChanged,
      error: 'disconnected',
    ));
    _stopHeartbeat();
    _scheduleReconnect();
  }

  void _onDone() {
    final closeCode = _channel?.closeCode;
    final closeReason = _channel?.closeReason;
    debugPrint('[WebSocket] Server closed connection. Code: $closeCode, Reason: $closeReason');
    _emitEvent(TranslationEvent(
      type: TranslationEventType.connectionStateChanged,
      error: 'disconnected',
    ));
    _stopHeartbeat();
    if (!_intentionalClose) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _intentionalClose) return;
    _reconnectTimer?.cancel();
    final delay = (_reconnectAttempts < 6)
        ? [1, 2, 4, 8, 16, _maxReconnectDelay][_reconnectAttempts]
        : _maxReconnectDelay;
    _reconnectAttempts++;
    _reconnectTimer = Timer(Duration(seconds: delay), _doConnect);
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      sendJson({'type': 'ping'});
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _emitEvent(TranslationEvent event) {
    _eventController?.add(event);
  }

  void _cleanup() {
    _streamSub?.cancel();
    _streamSub = null;
    _channel?.sink.close();
    _channel = null;
  }

  void sendStartTranslation() {
    sendJson({'action': 'start', 'output_type': 'text', 'language': _language});
  }

  void sendStopTranslation() {
    sendJson({'action': 'stop'});
  }

  void sendLandmarks(List<List<List<double>>> sequence) {
    sendJson({'action': 'landmarks', 'sequence': sequence});
  }

  void sendJson(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void startSession({String language = 'ar'}) {
    _sessionActive = true;
    _language = language;
    connect();
  }

  void stopSession() {
    _sessionActive = false;
    if (_channel != null) {
      sendStopTranslation();
    }
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _cleanup();
    _emitEvent(TranslationEvent(
      type: TranslationEventType.connectionStateChanged,
      error: 'disconnected',
    ));
  }

  void disconnect() {
    _sessionActive = false;
    _intentionalClose = true;
    _reconnectTimer?.cancel();
    _stopHeartbeat();
    _cleanup();
    _emitEvent(TranslationEvent(
      type: TranslationEventType.connectionStateChanged,
      error: 'disconnected',
    ));
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _eventController?.close();
    _eventController = null;
  }
}
