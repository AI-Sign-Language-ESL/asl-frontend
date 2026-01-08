import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

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
                    const SizedBox(height: 70), // Space for back button

                    if (isArabic) ...[
                      Image.asset(
                        'assets/logo.png',
                        width: 180,
                        height: 180,
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
                        local.handsVoice ?? 'Hands Voice',
                        style: const TextStyle(fontSize: 20),
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
                        onPressed: () {
                          // Validate that all fields are filled
                          if (_usernameController.text.trim().isEmpty ||
                              _firstNameController.text.trim().isEmpty ||
                              _lastNameController.text.trim().isEmpty ||
                              _organizationNameController.text.trim().isEmpty ||
                              _organizationActivityController.text
                                  .trim()
                                  .isEmpty ||
                              _jobTitleController.text.trim().isEmpty ||
                              _emailController.text.trim().isEmpty ||
                              _passwordController.text.trim().isEmpty ||
                              _confirmPasswordController.text.trim().isEmpty) {
                            // Show error message if any field is empty
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic
                                      ? 'يرجى ملء جميع الحقول'
                                      : 'Please fill all fields',
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          // Check if passwords match
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
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          // Optional: Basic email validation
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
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          // All validations passed - navigate to home screen
                          // TODO: Organization signup logic
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main',
                            (_) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF275878),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
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
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: Text(
                            isArabic ? 'تسجيل الدخول' : 'Login',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFF275878),
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

    return TextField(
      controller: controller,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
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
                color: Colors.grey[700],
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
}
