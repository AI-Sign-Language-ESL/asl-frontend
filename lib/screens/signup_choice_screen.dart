import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5EBF5),
        body: Stack(
          children: [
            if (isArabic)
              Positioned.fill(
                child: Image.asset(
                  'assets/ar_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // Logo area
                    Image.asset(
                      'assets/logo.png',
                      width: 215,
                      height: 215,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 14),

                    Image.asset(
                      'assets/TAFAHOM TYPO.png',
                      width: 240,
                      height: 40,
                      fit: BoxFit.contain,
                    ),

// ... inside your Column
                    const SizedBox(height: 25),

                    Align(
                      alignment: AlignmentDirectional
                          .centerStart, // Switches based on language
                      child: Text(
                        isArabic
                            ? 'إنشاء حساب جديد'
                            : local.signUpAs ?? 'Sign up as',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    _buildChoiceButton(
                      text: isArabic ? 'مستخدم' : local.user ?? 'User',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/user_signup'),
                    ),

                    const SizedBox(height: 27),

                    _buildChoiceButton(
                      text: isArabic
                          ? 'منظمة'
                          : local.organization ?? 'Organization',
                      onPressed: () =>
                          Navigator.pushNamed(context, '/org_signup'),
                    ),

                    const Spacer(flex: 3),

                    Text(
                      isArabic
                          ? 'صُنع بحب ♥ لمجتمع الصم'
                          : local.madeWithLove ??
                              'Made with ♥ for the Deaf community',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF275878),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
