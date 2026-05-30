import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final String loadingLabel;
  final VoidCallback? onPressed;

  const GoogleSignInButton({
    super.key,
    this.isLoading = false,
    this.label = 'Continue with Google',
    this.loadingLabel = 'Signing in...',
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? Colors.white24 : Colors.black26;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: dividerColor),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
            : const FaIcon(FontAwesomeIcons.google, size: 20),
        label: Text(isLoading ? loadingLabel : label),
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}
