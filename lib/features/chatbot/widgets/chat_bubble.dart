import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onRetry;
  final VoidCallback? onPlayAudio;
  final bool isPlaying;

  const ChatBubble({
    super.key,
    required this.message,
    this.onRetry,
    this.onPlayAudio,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isUser = message.isUser;
    final local = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? (isRtl ? 8 : 60) : (isRtl ? 60 : 8),
        right: isUser ? (isRtl ? 60 : 8) : (isRtl ? 8 : 60),
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          message.isAssistant
              ? _buildAssistantLabel(context, local)
              : const SizedBox.shrink(),
          const SizedBox(height: 2),
          _buildBubble(context, isUser, isRtl, local),
          if (message.hasError) _buildErrorRow(context, local),
          if (message.isSending && message.isUser) _buildSendingIndicator(context),
        ],
      ),
    );
  }

  Widget _buildAssistantLabel(BuildContext context, AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 2),
      child: Text(
        local.chatbotName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, bool isUser, bool isRtl, AppLocalizations local) {
    final bubbleColor = isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF1F5F9);

    final textColor = isUser
        ? Colors.white
        : Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF0F172A);

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: message.isVoice ? _buildVoiceContent(context, local) : _buildTextContent(textColor),
    );
  }

  Widget _buildTextContent(Color textColor) {
    return Text(
      message.content,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildVoiceContent(BuildContext context, AppLocalizations local) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: onPlayAudio,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        const SizedBox(width: 8),
        Container(
          width: 80,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: CustomPaint(
            painter: _WaveformPainter(isPlaying: isPlaying),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatDuration(message.audioDuration ?? 0),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildErrorRow(BuildContext context, AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 14, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 4),
          Text(
            local.chatbotError,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Sending...',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(double seconds) {
    final m = (seconds / 60).floor();
    final s = (seconds % 60).floor();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _WaveformPainter extends CustomPainter {
  final bool isPlaying;

  _WaveformPainter({this.isPlaying = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: isPlaying ? 0.9 : 0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const barCount = 20;
    final spacing = size.width / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final height = (size.height * 0.15 + (i % 5) * size.height * 0.12).clamp(4.0, size.height * 0.7);
      canvas.drawLine(
        Offset(i * spacing + spacing * 0.3, centerY - height / 2),
        Offset(i * spacing + spacing * 0.3, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => oldDelegate.isPlaying != isPlaying;
}
