import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:tafahom_english_light/services/auth_service.dart';
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
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  // ---------------- LOGIN ----------------
  Future<void> _attemptLogin() async {
    final local = AppLocalizations.of(context)!;

    setState(() {
      _emailError = _emailController.text.trim().isEmpty
          ? local.pleaseEnterEmailUsername
          : null;
      _passwordError =
          _passwordController.text.isEmpty ? local.pleaseEnterPassword : null;
    });

    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // 🔐 2FA REQUIRED
      if (result.requires2FA) {
        Navigator.pushNamed(
          context,
          '/login_2fa',
          arguments: result.tempToken,
        );
        return;
      }

      // ✅ Normal login
      context.read<UserProvider>().login();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.invalidEmailOrPassword),
          backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              Image.asset(
                'assets/TAFAHOM TYPO.png',
                width: 240,
                height: 40,
              ),

              const SizedBox(height: 8),

              Text(
                local.welcome,
                style:
                    const TextStyle(fontSize: 63, fontWeight: FontWeight.w900),
              ),
              Text(
                local.signsAlive,
                style: const TextStyle(fontSize: 22),
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
                onChanged: (_) => setState(() => _passwordError = null),
                decoration: InputDecoration(
                  hintText: local.password,
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v!),
                      ),
                      Text(local.rememberMe),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reset_password'),
                    child: Text(local.forgotPassword),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          local.login,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(child: Text(local.orLoginWith)),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.google),
                  label: const Text(''),
                  onPressed: () {},
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

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(local.dontHaveAccount),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/signup_choice'),
                      child: Text(
                        local.signUp,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
