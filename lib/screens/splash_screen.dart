// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../main.dart'; // For LocaleProvider

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      body: Stack(
        children: [
          // Background image for Arabic mode
          if (isArabic)
            Positioned.fill(
              child: Image.asset(
                'assets/ar_background.png', // Add your background image here
                fit: BoxFit.cover,
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Language switch button - centered pill shape
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF275878),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Provider.of<LocaleProvider>(context, listen: false)
                              .setLocale(
                            isArabic ? const Locale('en') : const Locale('ar'),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Text(
                            isArabic ? 'English' : 'العربية',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF275878),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 180),

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
                        heightFactor: 1,
                        child: Image.asset(
                          'assets/TAFAHOM TYPO.png',
                          width: 240,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 230,
                      height: 1,
                      color: Colors.black,
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Tagline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
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

                const Spacer(flex: 1),

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            local.getStarted,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isArabic ? Icons.arrow_back : Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
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
        ],
      ),
    );
  }
}
