// lib/screens/login_2fa_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tafahom_english_light/services/auth_service.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:tafahom_english_light/core/constants/colors.dart';
import '../main.dart';

class Login2FAScreen extends StatefulWidget {
  const Login2FAScreen({super.key});

  @override
  State<Login2FAScreen> createState() => _Login2FAScreenState();
}

class _Login2FAScreenState extends State<Login2FAScreen> {
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  Future<void> _verifyOtp(String tempToken) async {
    final local = AppLocalizations.of(context)!;

    if (_otpController.text.trim().length != 6) {
      setState(() => _errorText = local.invalidOtp);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await AuthService().loginWith2FA(
        tempToken: tempToken,
        otp: _otpController.text.trim(),
      );

      if (!mounted) return;

      // ✅ UPDATED: matches your UserProvider
      context.read<UserProvider>().login();

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorText = local.invalidOtp;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    final String tempToken =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                local.twoFactorAuth,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                local.enterOtpCode,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: "••••••",
                  filled: true,
                  fillColor: AppColors.primaryWhite,
                  errorText: _errorText,
                  counterText: "",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _verifyOtp(tempToken),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryWhite,
                        )
                      : Text(
                          local.verify,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryWhite,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
