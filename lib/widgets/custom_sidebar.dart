// lib/widgets/custom_sidebar.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/services/auth_service.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../core/constants/colors.dart';
import '../screens/home_screen.dart';
import '../screens/sign_to_text_screen.dart';
import '../screens/dataset_contribution_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  /// ✅ SAFE navigation for dialogs
  void _navigate(BuildContext context, Widget screen, int index) {
    onItemTapped(index);

    // 1️⃣ Close sidebar dialog
    Navigator.of(context).pop();

    // 2️⃣ Navigate using ROOT navigator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => screen));
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Drawer(
      child: Container(
        color: AppColors.primaryBlue,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: SizedBox()),

            _item(context, Icons.home, local.home, 0),
            _item(context, Icons.gesture, local.textToSign, 1),
            _item(context, Icons.sign_language, local.signToText, 2),
            _item(context, Icons.cloud_upload, local.contributeDataset, 3),

            const Divider(color: Colors.white24),

            _item(context, Icons.credit_card, local.subscription, 4),
            _item(context, Icons.person, local.profile, 5),
            _item(context, Icons.settings, local.settings, 6),

            const SizedBox(height: 20),

            // ---------------- LOGOUT ----------------
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text(
                local.logOut,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await AuthService().logout();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- MENU ITEM ----------------
  Widget _item(BuildContext context, IconData icon, String title, int index) {
    final selected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: selected ? Colors.yellow : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.yellow : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: Colors.white.withOpacity(0.2),
      onTap: () {
        switch (index) {
          case 0:
            _navigate(context, const HomeScreen(), index);
            break;
          case 1:
          case 2:
            _navigate(context, const SignToTextScreen(), index);
            break;
          case 3:
            _navigate(context, const DatasetContributionScreen(), index);
            break;
          case 4:
            _navigate(context, const SubscriptionScreen(), index);
            break;
          case 5:
            _navigate(context, const ProfileScreen(), index);
            break;
          case 6:
            _navigate(context, const SettingsScreen(), index);
            break;
        }
      },
    );
  }
}
