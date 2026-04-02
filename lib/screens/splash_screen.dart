// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
                'assets/ar_background.png',
                fit: BoxFit.cover,
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Language switch button
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
                              fontSize: 18,
                              color: Color(0xFF275878),
                              fontWeight: FontWeight.w600,
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
                const SizedBox(height: 0.5),

                // TAFAHOM Text with underline
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isArabic)
                      const Text(
                        'تَفَاهُمٌ',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF275878),
                          height: 0.6,
                        ),
                        textDirection: TextDirection.rtl,
                      )
                    else
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

                // ✨ Sparkling Tagline ✨
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    local.worldUnheard,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
                  )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .shimmer(
                        duration: const Duration(milliseconds: 3600),
                        color: const Color(0xFFFFD700), // Golden sparkle
                        angle: 0,
                      )
                      .then(delay: const Duration(milliseconds: 100))
                      .shimmer(
                        duration: const Duration(milliseconds: 4000),
                        color: Colors.white.withOpacity(0.85),
                        angle: 45,
                      )
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.04, 1.04),
                        duration: const Duration(milliseconds: 5000),
                        curve: Curves.easeInOut,
                      ),
                ),

                const Spacer(flex: 1),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF275878),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                            isArabic ? 'ابدأ' : local.getStarted,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Continue as guest
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Text(
                    local.continueAsGuest,
                    style: const TextStyle(
                      fontSize: 19,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textDirection:
                        isArabic ? TextDirection.rtl : TextDirection.ltr,
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
