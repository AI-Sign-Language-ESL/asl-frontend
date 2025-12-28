// lib/screens/organization_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({Key? key}) : super(key: key);

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
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // First Name & Last Name Row
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                            label: local.firstnameLower, value: "Value"),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileField(
                            label: local.lastnameLower, value: "Value"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Username
                  _ProfileField(label: local.usernameLower, value: "Value"),

                  const SizedBox(height: 20),

                  // Email
                  _ProfileField(label: local.emailLower, value: "Value"),

                  const SizedBox(height: 20),

                  // Organization Name
                  _ProfileField(label: local.orgNameLower, value: "Value"),

                  const SizedBox(height: 20),

                  // Organization Activity
                  _ProfileField(label: local.orgActivityLower, value: "Value"),

                  const SizedBox(height: 20),

                  // Job Title
                  _ProfileField(label: local.jobTitleLower, value: "Value"),

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

// Reusable field widget
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

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
          readOnly: true, // or false if editable
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
