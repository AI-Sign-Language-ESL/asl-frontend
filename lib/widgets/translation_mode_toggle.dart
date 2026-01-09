import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

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

    final Map<String, Map<String, String>> translations = {
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

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
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
          ),
          _pill(
            _getLocalizedText(context, 'textToSign'),
            !isSignToText,
            onTextToSign,
            isRTL,
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, bool active, VoidCallback onTap, bool isRTL) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        ),
      ),
    );
  }
}
