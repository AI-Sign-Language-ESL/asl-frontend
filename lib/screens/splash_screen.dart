// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../main.dart'; // For LocaleProvider

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      body: SafeArea(
        child: Column(
          children: [
            // Language switch button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Provider.of<LocaleProvider>(context, listen: false)
                        .setLocale(const Locale('en'));
                  },
                  child: const Text('EN'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<LocaleProvider>(context, listen: false)
                        .setLocale(const Locale('ar'));
                  },
                  child: const Text('AR'),
                ),
              ],
            ),
            const SizedBox(height: 200), // small clean space

            // LOGO
            Image.asset(
              'assets/logo.png',
              width: 230,
              height: 230,
            ),
            const SizedBox(height: 1),

// TAFAHOM PNG with thin underline
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    heightFactor: 1, // adjust crop
                    child: Image.asset(
                      'assets/TAFAHOM TYPO.png',
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20), // spacing between image and underline

                Container(
                  width: 230, // adjust underline width to your PNG width
                  height: 1,
                  color: Colors.black,
                ),
              ],
            ),

            const Spacer(flex: 1), // flexible space before tagline
            Text(
              local.worldUnheard,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 1), // space after tagline

            // Get Started Button
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    local.getStarted,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Continue as guest
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: Text(
                local.continueAsGuest,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                local.builtBy,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
