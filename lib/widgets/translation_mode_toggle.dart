import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../main.dart'; // ThemeProvider

class TranslationModeToggle extends StatelessWidget {
  final bool isSignToText;
  final VoidCallback onSignToText;
  final VoidCallback onTextToSign;

  const TranslationModeToggle({
    super.key,
    required this.isSignToText,
    required this.onSignToText,
    required this.onTextToSign,
  });

  String _getLocalizedText(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;

    const Map<String, Map<String, String>> translations = {
      'en': {
        'signToText': 'Sign to Text',
        'textToSign': 'Text to Sign',
      },
      'ar': {
        'signToText': 'إشارة إلى نص',
        'textToSign': 'نص إلى إشارة',
      },
    };

    return translations[locale]?[key] ?? translations['en']![key]!;
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // Adaptive colours
    final Color containerBg =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final Color activeBg =
        isDarkMode ? const Color(0xFF4A90C4) : AppColors.primaryBlue;
    final Color inactiveText =
        isDarkMode ? Colors.white38 : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(
            _getLocalizedText(context, 'signToText'),
            isSignToText,
            onSignToText,
            isRTL,
            activeBg,
            inactiveText,
          ),
          _pill(
            _getLocalizedText(context, 'textToSign'),
            !isSignToText,
            onTextToSign,
            isRTL,
            activeBg,
            inactiveText,
          ),
        ],
      ),
    );
  }

  Widget _pill(
    String text,
    bool active,
    VoidCallback onTap,
    bool isRTL,
    Color activeBg,
    Color inactiveText,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : inactiveText,
            fontWeight: FontWeight.w600,
          ),
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }
}
