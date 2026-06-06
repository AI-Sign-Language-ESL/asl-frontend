import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/theme/app_theme_provider.dart';

class TranslationWidget extends StatelessWidget {
  const TranslationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<TranslationProvider>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final Color boxBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color boxBorder =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color textColor =
        isDark ? const Color(0xFF4A90C4) : const Color(0xFF275878);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            physics: const ClampingScrollPhysics(),
            child: _buildContent(provider, textColor, isArabic, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    TranslationProvider provider,
    Color textColor,
    bool isArabic,
    bool isDark,
  ) {
    final bool showGloss =
        provider.currentGloss != null && provider.currentGloss!.isNotEmpty;

    if (provider.status == TranslationStatus.translating && !showGloss) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isDark ? const Color(0xFF4A90C4) : const Color(0xFF275878),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Translating...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (provider.currentText == null && !showGloss) {
      return Text(
        'Translation will appear here',
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white54 : Colors.black54,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showGloss)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF4A90C4) : const Color(0xFF275878))
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              provider.currentGloss!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (provider.currentText != null)
          Text(
            provider.currentText!,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection:
                isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
      ],
    );
  }
}
