import 'package:flutter/foundation.dart';

enum MessageType { text, voice }
enum MessageStatus { sending, sent, error }
enum MessageRole { user, assistant }

class ChatMessage {
  final String id;
  final MessageRole role;
  final MessageType type;
  final String content;
  final String? audioUrl;
  final double? audioDuration;
  final DateTime timestamp;
  final MessageStatus status;
  final double uploadProgress;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.type,
    required this.content,
    this.audioUrl,
    this.audioDuration,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.uploadProgress = 0.0,
  });

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    MessageType? type,
    String? content,
    String? audioUrl,
    double? audioDuration,
    DateTime? timestamp,
    MessageStatus? status,
    double? uploadProgress,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      type: type ?? this.type,
      content: content ?? this.content,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: json['role'] == 'assistant' ? MessageRole.assistant : MessageRole.user,
      type: json['type'] == 'voice' ? MessageType.voice : MessageType.text,
      content: json['content'] as String? ?? '',
      audioUrl: json['audio_url'] as String?,
      audioDuration: (json['audio_duration'] as num?)?.toDouble(),
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role == MessageRole.assistant ? 'assistant' : 'user',
        'type': type == MessageType.voice ? 'voice' : 'text',
        'content': content,
        if (audioUrl != null) 'audio_url': audioUrl,
        if (audioDuration != null) 'audio_duration': audioDuration,
      };

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isVoice => type == MessageType.voice;
  bool get isText => type == MessageType.text;
  bool get isSending => status == MessageStatus.sending;
  bool get hasError => status == MessageStatus.error;
}
