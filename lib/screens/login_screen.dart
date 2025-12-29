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

  // Check if both fields are filled
  bool get _isFormValid =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

// Inside _attemptLogin() method – replace the whole method with this:
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
      // Save login state
      context.read<UserProvider>().login(
            _emailController.text.trim(),
            org: false,
          );

      // THIS IS THE KEY LINE – go to the new main app
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main', // ← matches route in main.dart
        (route) => false, // removes splash, login, everything
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
    return Scaffold(
      backgroundColor: const Color(0xFFD5EBF5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),

              const SizedBox(height: 20), // smaller top space

// Header
              Image.asset(
                'assets/TAFAHOM TYPO.png',
                width: 240, // bigger now actually fills space
                height: 40, // adjust proportionally
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 8), // tiny space below PNG

              Text(
                local.welcome,
                style:
                    const TextStyle(fontSize: 63, fontWeight: FontWeight.w900),
              ),
              Text(
                local.signsAlive,
                style: const TextStyle(fontSize: 22, color: Colors.black87),
              ),
              const SizedBox(height: 25), // reduce space before email field

              // Email/Username Field
              TextField(
                controller: _emailController,
                onChanged: (_) => setState(() => _emailError = null),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: local.enterEmailUsername,
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _emailError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
                  prefixIcon:
                      const Icon(Icons.person_outline, color: Colors.black87),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() => _passwordError = null),
                // ... (truncated 1046 characters)...
                decoration: InputDecoration(
                  hintText: local.password,
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _passwordError,
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.black87),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remember me + Forgot password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: const Color(0xFF275878),
                        onChanged: (value) =>
                            setState(() => _rememberMe = value!),
                      ),
                      Text(local.rememberMe,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/reset_password'),
                    child: Text(
                      local.forgotPassword,
                      style: const TextStyle(
                          color: Color(0xFF275878), fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Login Button - Smart disable
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _attemptLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF275878),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    local.login,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Or login with
              Center(
                  child: Text(local.orLoginWith,
                      style: const TextStyle(color: Colors.black))),
              const SizedBox(height: 10),

              // Google & Apple Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const FaIcon(FontAwesomeIcons.google, size: 25),
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

              // Sign up link
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
                        style: const TextStyle(
                            color: Color(0xFF275878),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
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
