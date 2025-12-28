// lib/screens/reset_sent_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

class ResetSentScreen extends StatelessWidget {
  const ResetSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // EXACT icon from your screenshot
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: const Color(0xFFD5EBF5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                'assets/icons/envelope_lock.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              local.checkEmail,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              local.sentResetLink,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF275878),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  local.backToLogin,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
