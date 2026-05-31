import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../services/voice_recorder_service.dart';

class VoiceRecorderWidget extends StatelessWidget {
  final VoiceRecorderService recorder;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  const VoiceRecorderWidget({
    super.key,
    required this.recorder,
    required this.onStop,
    required this.onCancel,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
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
          _buildCancelButton(context, isDark),
          const SizedBox(width: 8),
          _buildRecordingIndicator(context, isDark),
          const Spacer(),
          Text(
            recorder.formattedDuration,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          _buildStopButton(context, isDark),
          const SizedBox(width: 8),
          _buildSendButton(context),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          Icons.close_rounded,
          color: Theme.of(context).colorScheme.error,
          size: 20,
        ),
        onPressed: onCancel,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildRecordingIndicator(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          AppLocalizations.of(context)!.chatbotRecording,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStopButton(BuildContext context, bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.stop_rounded, color: Colors.red, size: 20),
        onPressed: onStop,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF275878),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF275878).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
        onPressed: onSend,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }
}
