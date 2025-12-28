// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.primaryBlue),
        title: Text(
          local.profile,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                    child: Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // First Name
                  const _UserProfileField(
                      label: "firstname",
                      value:
                          "Value"), // Note: original is hard-coded lower; localize if needed, but kept for design
                  const SizedBox(height: 20),

                  // Last Name
                  const _UserProfileField(label: "lastname", value: "Value"),
                  const SizedBox(height: 20),

                  // Username
                  const _UserProfileField(label: "username", value: "Value"),
                  const SizedBox(height: 20),

                  // Email
                  const _UserProfileField(label: "Email", value: "Value"),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable field widget (same as organization but simpler)
class _UserProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _UserProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            hintText: value,
            hintStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
