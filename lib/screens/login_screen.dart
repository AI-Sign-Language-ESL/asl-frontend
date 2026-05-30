// lib/screens/login_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../services/auth_service.dart';
import '../services/google_signin_service.dart';
import '../services/google_auth_service.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/theme/app_theme_provider.dart';
import '../widgets/google_signin_button.dart';
import '../core/network/api_exceptions.dart';
import '../utils/snackbar_utils.dart';

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
  // 🌐 GOOGLE LOGIN
  // =====================================================
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final idToken = await GoogleSignInService.getIdToken();
      if (idToken == null) {
        setState(() => _isLoading = false);
        return;
      }

      final userData = await GoogleAuthService.loginWithGoogle(idToken);

      final userProvider = context.read<AuthProvider>();
      userProvider.login(
        name: userData['name'] as String? ??
            userData['username'] as String? ??
            'User',
        email: userData['email'] as String?,
        picture: userData['picture'] as String?,
        userId: userData['id'] as int?,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;
      _showError(e.userFriendlyMessage);
    } on GoogleAuthException catch (e) {
      if (!mounted) return;
      _showError(e.userFriendlyMessage);
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to sign in with Google.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    SnackBarUtils.showError(context, message);
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
      final userProvider = context.read<AuthProvider>();
      userProvider.login(
        name: data["user"]?["username"] ?? "User",
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, e.toString());
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, e.toString());
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
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final bg = isDark ? Colors.black : const Color(0xFFD5EBF5);
    final textPrimary = isDark ? Colors.white : Colors.black;
    final textSecondary = isDark ? Colors.white70 : Colors.black87;
    final inputFill = isDark ? const Color(0xFF1E293B) : Colors.white;
    final primary = isDark ? const Color(0xFF3B82F6) : const Color(0xFF275878);
    final dividerColor = isDark ? Colors.white24 : Colors.black26;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
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
                          Text(
                            'تَفَاهُمٌ',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: primary,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.right,
                          )
                        else
                          Image.asset(
                            isDark ? 'assets/TAFAHOM_TYPO2.png' : 'assets/TAFAHOM_TYPO.png',
                            width: 240,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        Text(
                          isArabic ? 'أهلاً وسهلاً' : 'Welcome!',
                          style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          local.signsAlive,
                          style: TextStyle(
                            fontSize: 22,
                            color: textSecondary,
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
                            fillColor: inputFill,
                            errorText: _emailError,
                            prefixIcon: Icon(Icons.person_outline, color: textSecondary),
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
                            fillColor: inputFill,
                            errorText: _passwordError,
                            prefixIcon: Icon(Icons.lock_outline, color: textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: textSecondary,
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
                                  activeColor: primary,
                                  onChanged: (v) =>
                                      setState(() => _rememberMe = v!),
                                ),
                                Text(local.rememberMe, style: TextStyle(color: textPrimary)),
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
                            Expanded(child: Divider(color: dividerColor)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(local.orLoginWith, style: TextStyle(color: textSecondary)),
                            ),
                            Expanded(child: Divider(color: dividerColor)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ================= GOOGLE =================
                        GoogleSignInButton(
                          isLoading: _isLoading,
                          label: isArabic ? 'Google' : 'Continue with Google',
                          loadingLabel: isArabic
                              ? 'جاري التسجيل...'
                              : 'Signing in...',
                          onPressed: _handleGoogleLogin,
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                              foregroundColor: textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: dividerColor),
                              ),
                            ),
                            icon: const FaIcon(FontAwesomeIcons.apple),
                            label: Text(isArabic ? 'Apple' : 'Apple'),
                            onPressed: () {},
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(local.dontHaveAccount, style: TextStyle(color: textSecondary)),
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
