// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../main.dart';

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

  String? _emailError;
  String? _passwordError;

  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  void _attemptLogin() {
    final local = AppLocalizations.of(context)!;

    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? local.pleaseEnterEmailUsername
          : null;
      _passwordError =
          _passwordController.text.isEmpty ? local.pleaseEnterPassword : null;
    });

    if (_isFormValid) {
      context.read<UserProvider>().login(
            _emailController.text.trim(),
            org: false,
          );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final socialButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF275878),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
    );

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFD5EBF5),
        body: Stack(
          children: [
            // Arabic background
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

                        // Logo
                        Image.asset(
                          'assets/TAFAHOM TYPO.png',
                          width: 240,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),

                        Text(
                          local.welcome,
                          style: const TextStyle(
                            fontSize: 63,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          local.signsAlive,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Email
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

                        // Password
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

                        // Remember + Forgot
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

                        const SizedBox(height: 24),

                        // Login
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isFormValid ? _attemptLogin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF275878),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              local.login,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Or login with divider
                        Row(
                          children: [
                            const Expanded(
                              child:
                                  Divider(thickness: 1, color: Colors.black26),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                local.orLoginWith,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child:
                                  Divider(thickness: 1, color: Colors.black26),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Google & Apple Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon:
                                const FaIcon(FontAwesomeIcons.google, size: 25),
                            label: const Text(''),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const FaIcon(
                              FontAwesomeIcons.apple,
                              size: 26,
                            ),
                            label: const Text(''),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                            ),
                          ),
                        ),
                        // Sign up
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(local.dontHaveAccount),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/signup_choice',
                                ),
                                child: Text(
                                  local.signUp,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
