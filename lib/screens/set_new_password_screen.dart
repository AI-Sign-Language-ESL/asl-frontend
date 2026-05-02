// lib/screens/set_new_password_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../services/auth_service.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _passwordError;
  String? _confirmError;

  bool get _isFormValid =>
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _confirmNewPassword() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Validate locally first
    setState(() {
      _passwordError = _passwordController.text.length < 8
          ? (isArabic
              ? 'كلمة السر يجب أن تكون 8 أحرف على الأقل'
              : 'Password must be at least 8 characters')
          : null;

      _confirmError = _passwordController.text != _confirmController.text
          ? (isArabic ? 'كلمتا السر غير متطابقتين' : 'Passwords do not match')
          : null;
    });

    if (_passwordError != null || _confirmError != null) return;

    setState(() => _isLoading = true);

    // Pull the token / email / code passed forward from ResetSentScreen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String email = args?['email'] ?? '';
    final String token = args?['token'] ?? '';
    final String code = args?['code'] ?? '';

    try {
      // Call the backend to persist the new password.
      // AuthService.setNewPassword should POST email + code/token + newPassword.
      await AuthService.setNewPassword(
        email: email,
        token: token,
        code: code,
        newPassword: _passwordController.text,
        confirmPassword: _confirmController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog, then navigate to login
      _showSuccessDialog(isArabic);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog(bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated check circle
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isArabic
                  ? 'تم تغيير كلمة السر بنجاح!'
                  : 'Password Changed Successfully!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isArabic
                  ? 'يمكنك الآن تسجيل الدخول بكلمة السر الجديدة'
                  : 'You can now log in with your new password',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                // Remove the entire reset flow and go to login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF275878),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                isArabic ? 'تسجيل الدخول' : 'Go to Login',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // Lock icon
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF275878).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 50,
                          color: Color(0xFF275878),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        isArabic
                            ? 'إنشاء كلمة سر جديدة'
                            : local.setNewPassword ?? 'Set New Password',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isArabic
                            ? 'يجب أن تكون كلمة السر 8 أحرف على الأقل'
                            : 'Must be at least 8 characters',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // New password field
                      _buildPasswordField(
                        controller: _passwordController,
                        hint: isArabic ? 'كلمة السر الجديدة' : 'New password',
                        obscureText: _obscurePassword,
                        errorText: _passwordError,
                        onToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        onChanged: (_) => setState(() {
                          _passwordError = null;
                          _confirmError = null;
                        }),
                      ),

                      const SizedBox(height: 20),

                      // Confirm password field
                      _buildPasswordField(
                        controller: _confirmController,
                        hint: isArabic
                            ? 'تأكيد كلمة السر'
                            : 'Confirm new password',
                        obscureText: _obscureConfirm,
                        errorText: _confirmError,
                        onToggle: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        onChanged: (_) => setState(() => _confirmError = null),
                      ),

                      const SizedBox(height: 40),

                      // Confirm button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: (_isFormValid && !_isLoading)
                              ? _confirmNewPassword
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? const Color(0xFF275878)
                                : const Color(0xFFCBD5DD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: _isFormValid ? 2 : 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  isArabic ? 'تأكيد' : 'Confirm',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _isFormValid
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color(0xFFE94560),
          fontSize: 13,
        ),
        prefixIcon: isArabic ? null : const Icon(Icons.lock_outline),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isArabic) const Icon(Icons.lock_outline),
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[700],
              ),
              onPressed: onToggle,
            ),
          ],
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE94560),
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }
}
