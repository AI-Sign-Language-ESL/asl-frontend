// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5), // Same as your app
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              local.resetPassword,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              local.willEmailLink,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
            ),
            const SizedBox(height: 50),

            // Email Field
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: local.emailAddress,
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.mail_outline, color: Colors.black87),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
            const SizedBox(height: 30),

            // Send Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reset_sent');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF275878),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  local.sendResetLink,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const Spacer(), // Pushes the bottom text to the very bottom

            // Try logging in? Login now (bold)
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  children: [
                    TextSpan(text: local.tryLoggingIn),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/login'),
                        child: Text(
                          local.loginNow,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF275878),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), // Small padding from bottom
          ],
        ),
      ),
    );
  }
}
