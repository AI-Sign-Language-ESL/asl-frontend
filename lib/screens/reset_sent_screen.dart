// lib/screens/reset_sent_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../services/auth_service.dart';

class ResetSentScreen extends StatefulWidget {
  const ResetSentScreen({super.key});

  @override
  State<ResetSentScreen> createState() => _ResetSentScreenState();
}

class _ResetSentScreenState extends State<ResetSentScreen> {
  // One box per digit — 6-digit OTP
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  String? _codeError;

  String get _enteredCode => _controllers.map((c) => c.text).join();

  bool get _isCodeComplete => _enteredCode.length == 6;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Verify the code ────────────────────────────────────────────────────
  Future<void> _verifyCode() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (!_isCodeComplete) return;

    setState(() {
      _isVerifying = true;
      _codeError = null;
    });

    // Retrieve the email passed as a route argument from ResetPasswordScreen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String email = args?['email'] ?? '';

    try {
      // Call the backend to verify the code.
      // AuthService.verifyPasswordResetCode should POST the email + code
      // and return a reset token or simply succeed.
      final String? resetToken = await AuthService.verifyPasswordResetCode(
        email: email,
        code: _enteredCode,
      );

      if (!mounted) return;

      // Navigate to set new password, passing the token/email forward
      Navigator.pushReplacementNamed(
        context,
        '/set_new_password',
        arguments: {
          'email': email,
          'token': resetToken ?? '',
          'code': _enteredCode,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _codeError = isArabic
            ? 'الرمز غير صحيح. يرجى المحاولة مرة أخرى.'
            : 'Incorrect code. Please try again.';
      });
      // Clear the boxes on wrong code
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  // ── Resend the code ────────────────────────────────────────────────────
  Future<void> _resendCode() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String email = args?['email'] ?? '';

    setState(() {
      _isResending = true;
      _codeError = null;
    });

    try {
      await AuthService.sendPasswordResetCode(email: email);

      if (!mounted) return;
      setState(() => _isResending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تم إرسال رمز جديد إلى بريدك الإلكتروني'
                : 'A new code has been sent to your email',
          ),
          backgroundColor: const Color(0xFF275878),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear boxes for the new code
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Single OTP digit box ───────────────────────────────────────────────
  Widget _buildDigitBox(int index, bool isArabic) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF275878),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF275878),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE94560), width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() => _codeError = null);
          if (value.isNotEmpty && index < 5) {
            // Auto-advance to next box
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Auto-retreat to previous box on delete
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); // Rebuild to enable/disable verify button
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String email = args?['email'] ?? '';

    // Show masked email: ex***@gmail.com
    String maskedEmail = email;
    if (email.contains('@')) {
      final parts = email.split('@');
      final name = parts[0];
      final domain = parts[1];
      final masked = name.length > 2
          ? '${name.substring(0, 2)}${'*' * (name.length - 2)}'
          : name;
      maskedEmail = '$masked@$domain';
    }

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
                body: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Envelope icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD5EBF5),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/icons/envelope_lock.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        isArabic
                            ? 'تحقق من بريدك الإلكتروني واكتب الرمز الذي تلقيته'
                            : 'Check your email and enter the code you received',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Subtitle showing masked email
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: isArabic
                                  ? 'تم إرسال رمز مكوّن من 6 أرقام إلى '
                                  : 'We sent a 6-digit code to ',
                            ),
                            TextSpan(
                              text: maskedEmail,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF275878),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // OTP boxes — reversed order for RTL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        textDirection:
                            isArabic ? TextDirection.rtl : TextDirection.ltr,
                        children: List.generate(6, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _buildDigitBox(i, isArabic),
                          );
                        }),
                      ),

                      // Error message
                      if (_codeError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _codeError!,
                          style: const TextStyle(
                            color: Color(0xFFE94560),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 36),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isCodeComplete && !_isVerifying)
                              ? _verifyCode
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isCodeComplete
                                ? const Color(0xFF275878)
                                : const Color(0xFFCBD5DD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isCodeComplete ? 2 : 0,
                          ),
                          child: _isVerifying
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  isArabic ? 'تحقق من الرمز' : 'Verify Code',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _isCodeComplete
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Resend option
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isArabic
                                ? 'لم تستلم الرمز؟ '
                                : "Didn't receive the code? ",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),
                          _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF275878),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _resendCode,
                                  child: Text(
                                    isArabic ? 'إعادة الإرسال' : 'Resend',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF275878),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                        ],
                      ),

                      const SizedBox(height: 40),
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
