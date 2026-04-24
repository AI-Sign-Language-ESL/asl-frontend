// lib/screens/custom_sidebar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../core/constants/colors.dart';
import '../main.dart'; // ThemeProvider
import 'home_screen.dart';
import 'sign_to_text_screen.dart';
import 'dataset_contribution_screen.dart';
import 'subscription_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'text_to_sign_screen.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSidebar({
    required this.selectedIndex,
    required this.onItemTapped,
    Key? key,
  }) : super(key: key);

  void _safeNavigate(BuildContext context, Widget screen, int index) {
    onItemTapped(index);
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => screen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    final Color sidebarBg =
        isDarkMode ? const Color(0xFF0D1F2D) : AppColors.primaryBlue;
    final Color selectedHighlight = isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.white.withOpacity(0.2);
    final Color selectedTextColor =
        isDarkMode ? const Color(0xFF7EC8E3) : Colors.yellow;

    return Drawer(
      child: Container(
        color: sidebarBg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: SizedBox(height: 120)),
            _item(context, Icons.home, local.home, 0, selectedTextColor,
                selectedHighlight),
            _item(context, Icons.gesture, local.textToSign, 1,
                selectedTextColor, selectedHighlight),
            _item(context, Icons.sign_language, local.signToText, 2,
                selectedTextColor, selectedHighlight),
            _item(context, Icons.cloud_upload, local.contributeDataset, 3,
                selectedTextColor, selectedHighlight),
            const Divider(color: Colors.white24),
            _item(context, Icons.credit_card, local.subscription, 4,
                selectedTextColor, selectedHighlight),
            _item(context, Icons.person, local.profile, 5, selectedTextColor,
                selectedHighlight),
            _item(context, Icons.settings, local.settings, 6, selectedTextColor,
                selectedHighlight),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: Text(
                local.logOut,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                });
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    Color selectedColor,
    Color selectedBg,
  ) {
    final bool selected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: selected ? selectedColor : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? selectedColor : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selected,
      selectedTileColor: selectedBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        switch (index) {
          case 0:
            _safeNavigate(
              context,
              HomeScreen(username: '', usernameLower: ''),
              index,
            );
            break;
          case 1:
            _safeNavigate(context, const TextToSignScreen(), index);
            break;
          case 2:
            _safeNavigate(context, const SignToTextScreen(), index);
            break;
          case 3:
            _safeNavigate(context, const DatasetContributionScreen(), index);
            break;
          case 4:
            _safeNavigate(context, const SubscriptionScreen(), index);
            break;
          case 5:
            _safeNavigate(context, const ProfileScreen(userName: ''), index);
            break;
          case 6:
            _safeNavigate(context, const SettingsScreen(), index);
            break;
        }
      },
    );
  }
}
