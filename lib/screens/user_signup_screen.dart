// lib/screens/user_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/google_signin_service.dart';
import '../services/google_auth_service.dart';
import '../main.dart'; // UserProvider

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  State<UserSignupScreen> createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🌐 GOOGLE SIGNUP (UNCHANGED)
  // =====================================================
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final idToken = await GoogleSignInService.getIdToken();
      if (idToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      await GoogleAuthService.loginWithGoogle(idToken);

      final userProvider = context.read<UserProvider>();
      userProvider.login("Google User");

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-Up failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // 👤 NORMAL SIGNUP (FIXED LOGIC ONLY)
  // =====================================================
  Future<void> _submit() async {
    // 🔴 FRONTEND PASSWORD VALIDATION (ADDED)
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.registerBasicUser(
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text, // ✅ FIX
      );

      final userProvider = context.read<UserProvider>();
      userProvider.login(
        data["user"]?["username"] ?? _usernameController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // 🧱 UI (100% UNCHANGED)
  // =====================================================
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
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    if (isArabic) ...[
                      Image.asset(
                        'assets/logo1.png',
                        width: 110,
                        height: 110,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'ليديك صوتك — أنضم إلينا',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      Text(
                        local.createNewAccount ?? 'Create New Account',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        local.handsVoice ?? 'Where your hands become a voice',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                    _buildTextField(
                      controller: _usernameController,
                      hint: isArabic
                          ? 'اسم المستخدم'
                          : local.username ?? 'Username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _firstNameController,
                      hint: isArabic
                          ? 'الاسم الأول'
                          : local.firstName ?? 'First Name',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _lastNameController,
                      hint: isArabic
                          ? 'الاسم الأخير'
                          : local.lastName ?? 'Last Name',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      hint: isArabic
                          ? 'البريد الإلكتروني'
                          : local.email ?? 'Email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint:
                          isArabic ? 'كلمة السر' : local.password ?? 'Password',
                      obscureText: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: isArabic
                          ? 'تأكيد كلمة السر'
                          : local.confirmPassword ?? 'Confirm Password',
                      obscureText: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                isArabic ? 'تسجيل' : local.signUp ?? 'Sign Up'),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.black38)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isArabic ? 'أو أنشئ حسابًا عبر' : 'or Sign up with',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.black54),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.black38)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      onPressed: _isLoading ? () {} : _handleGoogleLogin,
                    ),
                    const SizedBox(height: 12),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.apple,
                      onPressed: () {},
                      isApple: true,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic
                              ? 'هل لديك حساب مسبقاً؟'
                              : local.alreadyHaveAccount ??
                                  'Already have an account?',
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: Text(
                            isArabic ? 'تسجيل الدخول' : local.login ?? 'Login',
                            style: const TextStyle(
                              color: Color(0xFF275878),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= UI HELPERS (UNCHANGED) =========================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: isArabic ? null : Icon(icon),
        suffixIcon: isArabic ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: isArabic ? null : const Icon(Icons.lock_outline),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isArabic) const Icon(Icons.lock_outline),
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onToggle,
            ),
            if (!isArabic) const Icon(Icons.lock_outline),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isApple = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        child: FaIcon(
          icon,
          size: isApple ? 26 : 24,
          color: isApple ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
