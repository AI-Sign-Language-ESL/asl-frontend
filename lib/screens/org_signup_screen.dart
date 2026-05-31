import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:tafahom_english_light/providers/theme/app_theme_provider.dart';
import '../services/auth_service.dart';
import 'verification_screen.dart';

class OrgSignupScreen extends StatefulWidget {
  const OrgSignupScreen({super.key});

  @override
  State<OrgSignupScreen> createState() => _OrgSignupScreenState();
}

class _OrgSignupScreenState extends State<OrgSignupScreen> {
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _organizationActivityController = TextEditingController();
  final _jobTitleController = TextEditingController();
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
    _organizationNameController.dispose();
    _organizationActivityController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    setState(() => _isLoading = true);

    try {
      final data = await AuthService.registerOrganization(
        username: _usernameController.text.trim(),
        organizationName: _organizationNameController.text.trim(),
        activity: _organizationActivityController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
      );

      final email = data["email"] as String? ?? _emailController.text.trim();

      // ✅ navigate ONLY after backend success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(email: email),
        ),
        (_) => false,
      );
    } catch (e) {
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
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDarkMode = context.watch<AppThemeProvider>().isDarkMode;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFD5EBF5),
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
                        width: 180,
                        height: 180,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ليديك صوتك — أنضم إلينا',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ] else ...[
                      Text(
                        local.createNewAccount ?? 'Create New Account',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        local.handsVoice ?? 'Hands Voice',
                        style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? Colors.white60 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                    _buildField(
                      controller: _usernameController,
                      hint: isArabic ? 'اسم المستخدم' : 'Username',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _firstNameController,
                      hint: isArabic ? 'الاسم الأول' : 'First name',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _lastNameController,
                      hint: isArabic ? 'الاسم الأخير' : 'Last name',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _organizationNameController,
                      hint: isArabic ? 'اسم المنظمة' : 'Organization name',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _organizationActivityController,
                      hint: isArabic ? 'نشاط المنظمة' : 'Organization activity',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _jobTitleController,
                      hint: isArabic ? 'المسمى الوظيفي' : 'Job title',
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      controller: _emailController,
                      hint: isArabic ? 'البريد الإلكتروني' : 'Email',
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _passwordController,
                      hint: isArabic ? 'كلمة السر' : 'Password',
                      obscureText: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    const SizedBox(height: 20),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      hint: isArabic ? 'تأكيد كلمة السر' : 'Confirm password',
                      obscureText: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // KEEP ALL YOUR VALIDATION EXACTLY
                                if (_usernameController.text.trim().isEmpty ||
                                    _firstNameController.text.trim().isEmpty ||
                                    _lastNameController.text.trim().isEmpty ||
                                    _organizationNameController.text
                                        .trim()
                                        .isEmpty ||
                                    _organizationActivityController.text
                                        .trim()
                                        .isEmpty ||
                                    _jobTitleController.text.trim().isEmpty ||
                                    _emailController.text.trim().isEmpty ||
                                    _passwordController.text.trim().isEmpty ||
                                    _confirmPasswordController.text
                                        .trim()
                                        .isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isArabic
                                            ? 'يرجى ملء جميع الحقول'
                                            : 'Please fill all fields',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                if (_passwordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isArabic
                                            ? 'كلمات المرور غير متطابقة'
                                            : 'Passwords do not match',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                if (!_emailController.text.contains('@')) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isArabic
                                            ? 'يرجى إدخال بريد إلكتروني صالح'
                                            : 'Please enter a valid email',
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }

                                _submit();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF275878),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isArabic ? 'تسجيل' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic
                              ? 'هل لديك حساب مسبقاً؟'
                              : 'Already have an account?',
                          style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white60 : Colors.black87),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: Text(
                            isArabic ? 'تسجيل الدخول' : 'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF275878),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = context.read<AppThemeProvider>().isDarkMode;

    return TextField(
      controller: controller,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
    final isDark = context.read<AppThemeProvider>().isDarkMode;
    final iconColor = isDark ? Colors.white60 : null;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        prefixIcon: isArabic ? null : Icon(Icons.lock_outline, color: iconColor),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isArabic) Icon(Icons.lock_outline, color: iconColor),
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.white60 : Colors.grey[700],
              ),
              onPressed: onToggle,
            ),
            if (!isArabic) Icon(Icons.lock_outline, color: iconColor),
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
}
