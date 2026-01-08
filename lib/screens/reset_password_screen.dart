// lib/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  bool get _isEmailValid =>
      _emailController.text.trim().isNotEmpty &&
      _emailController.text.trim().contains('@');

  void _attemptReset() {
    final local = AppLocalizations.of(context)!;

    setState(() {
      if (_emailController.text.trim().isEmpty) {
        _emailError = local.emailAddress ?? 'البريد الإلكتروني مطلوب';
      } else if (!_emailController.text.trim().contains('@')) {
        _emailError = 'البريد الإلكتروني غير صحيح';
      } else {
        _emailError = null;
      }
    });

    if (_isEmailValid) {
      Navigator.pushNamed(context, '/reset_sent');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
            // Arabic background pattern
            if (isArabic)
              Positioned.fill(
                child: Image.asset(
                  'assets/ar_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Title
                      Center(
                        child: Text(
                          isArabic
                              ? 'إعادة تعيين كلمة السر'
                              : local.resetPassword,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        isArabic
                            ? 'سنرسل لك رابطاً على بريدك الإلكتروني لإعادة تعيين كلمة السر'
                            : local.willEmailLink,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),

                      const SizedBox(height: 48),

                      // Email field with validation
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        onChanged: (_) => setState(() => _emailError = null),
                        decoration: InputDecoration(
                          hintText: isArabic
                              ? 'البريد الإلكتروني'
                              : local.emailAddress,
                          filled: true,
                          fillColor: Colors.white,
                          errorText: _emailError,
                          errorStyle: const TextStyle(
                            color: Color(0xFFE94560),
                            fontSize: 14,
                          ),
                          prefixIcon:
                              isArabic ? null : const Icon(Icons.mail_outline),
                          suffixIcon:
                              isArabic ? const Icon(Icons.mail_outline) : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF275878),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 20),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Send button - DISABLED until email is valid
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isEmailValid ? _attemptReset : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEmailValid
                                ? const Color(0xFF275878)
                                : const Color(0xFFCBD5DD), // disabled gray
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isEmailValid ? 2 : 0,
                          ),
                          child: Text(
                            isArabic ? 'إرسال' : local.sendResetLink,
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  _isEmailValid ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Back to login link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            isArabic
                                ? 'العودة إلى تسجيل الدخول'
                                : '${local.tryLoggingIn} ${local.loginNow}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF275878),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
