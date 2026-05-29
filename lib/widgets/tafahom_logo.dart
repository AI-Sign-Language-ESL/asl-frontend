import 'package:flutter/material.dart';

class TafahomLogo extends StatelessWidget {
  final double height;

  const TafahomLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? 'assets/TAFAHOM.png' : 'assets/TAFAHOM TYPO.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[TafahomLogo] Failed to load: $error');
        return Text(
          'TAFAHOM',
          style: TextStyle(
            fontSize: height * 0.7,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF275878),
            letterSpacing: 2,
          ),
        );
      },
    );
  }
}
