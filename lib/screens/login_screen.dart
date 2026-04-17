// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/google_signin_service.dart';
import '../services/google_auth_service.dart';
import '../main.dart'; // ✅ UserProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  // =====================================================
  // 🌐 GOOGLE LOGIN (FIXED)
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

      // ✅ FIX: MARK USER AS LOGGED IN
      final userProvider = context.read<UserProvider>();
      userProvider.login("Google User");

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In failed: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // =====================================================
  // 🔐 EMAIL LOGIN (FIXED)
  // =====================================================
  Future<void> _attemptLogin() async {
    final local = AppLocalizations.of(context)!;

    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? local.pleaseEnterEmailUsername
          : null;
      _passwordError = _passwordController.text.isEmpty ? local.password : null;
    });

    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // ✅ FIX: MARK USER AS LOGGED IN
      final userProvider = context.read<UserProvider>();
      userProvider.login(
        data["user"]?["username"] ?? "User",
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =====================================================
  // 🧱 UI (UNCHANGED)
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        if (isArabic)
                          const Text(
                            'تَفَاهُمٌ',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF275878),
                              height: 1.1,
                            ),
                            textAlign: TextAlign.right,
                          )
                        else
                          Image.asset(
                            'assets/TAFAHOM TYPO.png',
                            width: 240,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        Text(
                          isArabic ? 'أهلاً وسهلاً' : 'Welcome!',
                          style: const TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          local.signsAlive,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // ================= EMAIL =================
                        TextField(
                          controller: _emailController,
                          onChanged: (_) => setState(() => _emailError = null),
                          decoration: InputDecoration(
                            hintText: local.enterEmailUsername,
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _emailError,
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ================= PASSWORD =================
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                          decoration: InputDecoration(
                            hintText: local.password,
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _passwordError,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ================= REMEMBER ME =================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: const Color(0xFF275878),
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v!),
                                ),
                                Text(local.rememberMe),
                              ],
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/reset_password',
                              ),
                              child: Text(local.forgotPassword),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ================= LOGIN BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _attemptLogin,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(local.login),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(local.orLoginWith),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ================= GOOGLE =================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.google),
                            label: const Text(''),
                            onPressed: _isLoading ? null : _handleGoogleLogin,
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.apple),
                            label: const Text(''),
                            onPressed: () {},
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(local.dontHaveAccount),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/signup_choice'),
                              child: Text(local.signUp),
                            ),
                          ],
                        ),
                      ],
                    ),
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
