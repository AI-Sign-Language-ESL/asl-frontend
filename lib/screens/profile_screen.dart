// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // === Profile Header ===
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: const NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg', // Replace with real image
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "user", // Placeholder; localize if needed, but kept as is
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryBlue),
                          ),
                          child: Text(
                            local.user,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // === Account Section ===
              _buildSectionTitle(local.account),
              const SizedBox(height: 12),
              _buildListTile(
                icon: Icons.person_outline,
                title: local.changePersonalProfile,
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.email_outlined,
                title: local.changeEmailAddress,
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.lock_outline,
                title: local.changePassword,
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.credit_card,
                title: local.manageSubscription,
                onTap: () => Navigator.pushNamed(context, '/subscription'),
              ),

              const SizedBox(height: 32),

              // === More Settings Section ===
              _buildSectionTitle(local.moreSettings),
              const SizedBox(height: 12),
              _buildListTile(
                icon: Icons.security,
                title: local.accountSecurity,
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.help_outline,
                title: local.helpPrivacy,
                onTap: () {},
              ),

              const SizedBox(height: 50),

              // === Log out Button ===
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // TODO: Handle logout
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                  child: Text(
                    local.logOut,
                    style: const TextStyle(
                      color: AppColors.accentRed,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
