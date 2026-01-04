import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../main.dart'; // LocaleProvider

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = context.read<LocaleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      body: SafeArea(
        child: Column(
          children: [
            // ===== LANGUAGE SWITCH =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => localeProvider.setLocale(const Locale('en')),
                  child: const Text('EN'),
                ),
                TextButton(
                  onPressed: () => localeProvider.setLocale(const Locale('ar')),
                  child: const Text('AR'),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // ===== LOGO =====
            Image.asset(
              'assets/logo.png',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 8),

            // ===== TAFAHOM LOGO + UNDERLINE =====
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/TAFAHOM TYPO.png',
                  width: 240,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 230,
                  height: 1,
                  color: Colors.black,
                ),
              ],
            ),

            const Spacer(),

            // ===== TAGLINE =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                local.worldUnheard,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // ===== GET STARTED =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF275878),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text(
                    local.getStarted,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ===== CONTINUE AS GUEST =====
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: Text(
                local.continueAsGuest,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // ===== FOOTER =====
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                local.builtBy,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
