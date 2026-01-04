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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill("Sign to Text", isSignToText, onSignToText),
          _pill("Text to Sign", !isSignToText, onTextToSign),
        ],
      ),
    );
  }

  Widget _pill(String text, bool active, VoidCallback onTap) {
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
        ),
      ),
    );
  }
}
