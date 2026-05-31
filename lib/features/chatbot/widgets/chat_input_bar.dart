import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:tafahom_english_light/providers/locale/app_locale_provider.dart';
import 'package:tafahom_english_light/services/speech_to_text_service.dart';

import '../providers/chat_provider.dart';
import 'voice_recorder_widget.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SpeechToTextService _sttService = SpeechToTextService();
  bool _isSttReady = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final ready = await _sttService.init();
    if (mounted) setState(() => _isSttReady = ready);
  }

  void _startStt() {
    if (!_isSttReady) return;
    final locale = context.read<AppLocaleProvider>().locale;
    final localeId = locale.languageCode == 'ar' ? 'ar_SA' : 'en_US';

    setState(() => _isListening = true);
    _sttService.startListening(
      localeId: localeId,
      onResult: (text) {
        _controller.text = text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );
      },
    );
  }

  void _stopStt() {
    _sttService.stopListening();
    setState(() => _isListening = false);
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    if (_isListening) _sttService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ChatProvider>();
    final isSending = provider.isSending;
    final isRecording = provider.recorder.isRecording;
    final hasText = _controller.text.trim().isNotEmpty;

    if (isRecording) {
      return VoiceRecorderWidget(
        recorder: provider.recorder,
        onStop: () async {
          await provider.stopRecording();
        },
        onCancel: () async {
          await provider.cancelRecording();
        },
        onSend: () async {
          final path = await provider.stopRecording();
          if (path != null && mounted) {
            provider.sendVoiceMessage(
              audioPath: path,
              duration: provider.recorder.duration,
              transcription: _controller.text.isNotEmpty ? _controller.text : null,
            );
            _controller.clear();
          }
        },
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom + 6,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          ),
        ),
      ),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _buildMicButton(context, isDark, isSending),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTextField(context, isDark, isSending),
          ),
          const SizedBox(width: 6),
          _buildSendButton(context, isDark, isSending, hasText),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool isDark, bool isSending) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textDirection: _detectTextDirection(),
        textInputAction: TextInputAction.send,
        onSubmitted: isSending ? null : (_) => _handleSend(),
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.chatbotHint,
          hintTextDirection: _detectTextDirection(),
          hintStyle: TextStyle(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.35),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        maxLines: 4,
        minLines: 1,
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, bool isDark, bool isSending) {
    final color = _isListening
        ? Theme.of(context).colorScheme.error
        : isDark
            ? Colors.white70
            : const Color(0xFF475569);

    return GestureDetector(
      onTap: isSending
          ? null
          : () {
              if (_isListening) {
                _stopStt();
              } else if (_isSttReady) {
                _startStt();
              } else {
                context.read<ChatProvider>().startRecording();
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _isListening
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.12)
              : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
          color: color,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, bool isDark, bool isSending, bool hasText) {
    final enabled = hasText && !isSending;

    return GestureDetector(
      onTap: enabled ? _handleSend : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF275878)
              : isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFF275878).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.send_rounded,
                color: enabled ? Colors.white : (isDark ? Colors.white38 : Colors.black26),
                size: 22,
              ),
      ),
    );
  }

  TextDirection _detectTextDirection() {
    final text = _controller.text;
    if (text.isEmpty) {
      return context.read<AppLocaleProvider>().locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr;
    }
    final hasRtl = text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
    return hasRtl ? TextDirection.rtl : TextDirection.ltr;
  }
}
