// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isArabic = true;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryBlue,
        title: const Text(
          'TAFAHOM.', // Brand; kept hard-coded
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: const [
          Icon(Icons.menu),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                local.settings,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 40),

              // App Language
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.appLanguage,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    fillColor: AppColors.primaryBlue,
                    color: Colors.grey[600],
                    constraints:
                        const BoxConstraints(minHeight: 40, minWidth: 60),
                    isSelected: [isArabic, !isArabic],
                    onPressed: (int index) {
                      setState(() {
                        isArabic = index == 0;
                      });
                    },
                    children: const [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("AR",
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text("EN",
                              style: TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // App Theme
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.appTheme,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    fillColor: AppColors.primaryBlue,
                    color: Colors.grey[600],
                    constraints:
                        const BoxConstraints(minHeight: 40, minWidth: 60),
                    isSelected: [!isDarkMode, isDarkMode],
                    onPressed: (int index) {
                      setState(() {
                        isDarkMode = index == 1;
                      });
                    },
                    children: const [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.dark_mode, size: 20)),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.light_mode, size: 20)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Subscription Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.subscriptionLower,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  Text(
                    local.oneMonthLeft,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
