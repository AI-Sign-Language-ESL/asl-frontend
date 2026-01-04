// lib/screens/organization_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/services/auth_service.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';

class OrganizationProfileScreen extends StatefulWidget {
  const OrganizationProfileScreen({Key? key}) : super(key: key);

  @override
  State<OrganizationProfileScreen> createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  bool _isLoading = true;
  String? _error;

  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';
  String orgName = '';
  String orgActivity = '';
  String jobTitle = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService().getProfile();

      setState(() {
        firstName = data['first_name'] ?? '';
        lastName = data['last_name'] ?? '';
        username = data['username'] ?? '';
        email = data['email'] ?? '';
        orgName = data['organization_name'] ?? '';
        orgActivity = data['organization_activity'] ?? '';
        jobTitle = data['job_title'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

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
                  Row(
                    children: [
                      Expanded(
                        child: _ProfileField(
                          label: local.firstnameLower,
                          value: firstName,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileField(
                          label: local.lastnameLower,
                          value: lastName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ProfileField(label: local.usernameLower, value: username),
                  const SizedBox(height: 20),
                  _ProfileField(label: local.emailLower, value: email),
                  const SizedBox(height: 20),
                  _ProfileField(label: local.orgNameLower, value: orgName),
                  const SizedBox(height: 20),
                  _ProfileField(
                      label: local.orgActivityLower, value: orgActivity),
                  const SizedBox(height: 20),
                  _ProfileField(label: local.jobTitleLower, value: jobTitle),
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

// ---------------- FIELD WIDGET ----------------

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
