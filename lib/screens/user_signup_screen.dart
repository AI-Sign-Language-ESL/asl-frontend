import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

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
            // Background pattern for Arabic
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
                    const SizedBox(height: 70), // Space for the back button

                    // Arabic header
                    if (isArabic) ...[
                      Image.asset(
                        'assets/logo.png',
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
                    ]

                    // English header
                    else ...[
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

                    // Form fields
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

                    // Sign Up button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate that all fields are filled
                          if (_usernameController.text.trim().isEmpty ||
                              _firstNameController.text.trim().isEmpty ||
                              _lastNameController.text.trim().isEmpty ||
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
                                  style: const TextStyle(fontSize: 15),
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
                          // TODO: Add signup logic here
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
                          elevation: 2,
                        ),
                        child: Text(
                          isArabic ? 'تسجيل' : local.signUp ?? 'Sign Up',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Or divider
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

                    // Google button
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      onPressed: () {
                        // TODO: Google sign in
                      },
                    ),

                    const SizedBox(height: 12),

                    // Apple button
                    _buildSocialButton(
                      icon: FontAwesomeIcons.apple,
                      onPressed: () {
                        // TODO: Apple sign in
                      },
                      isApple: true,
                    ),

                    const SizedBox(height: 40),

                    // Already have account row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic
                              ? 'هل لديك حساب مسبقاً؟'
                              : local.alreadyHaveAccount ??
                                  'Already have an account?',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                          child: Text(
                            isArabic ? 'تسجيل الدخول' : local.login ?? 'Login',
                            style: const TextStyle(
                              color: Color(0xFF275878),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF275878),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: FaIcon(
          icon,
          size: isApple ? 26 : 24,
          color: isApple ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}
