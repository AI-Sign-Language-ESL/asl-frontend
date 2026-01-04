import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../main.dart'; // LocaleProvider

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'TAFAHOM.',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
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
              // ===== TITLE =====
              Text(
                local.settings,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),

              const SizedBox(height: 40),

              // ===== APP LANGUAGE =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.appLanguage,
                    style: const TextStyle(fontSize: 18),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    fillColor: AppColors.primaryBlue,
                    color: Colors.grey[600],
                    constraints:
                        const BoxConstraints(minHeight: 40, minWidth: 60),
                    isSelected: [isArabic, !isArabic],
                    onPressed: (index) {
                      localeProvider.setLocale(
                        index == 0 ? const Locale('ar') : const Locale('en'),
                      );
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("AR",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text("EN",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ===== APP THEME =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.appTheme,
                    style: const TextStyle(fontSize: 18),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    selectedColor: Colors.white,
                    fillColor: AppColors.primaryBlue,
                    color: Colors.grey[600],
                    constraints:
                        const BoxConstraints(minHeight: 40, minWidth: 60),
                    isSelected: [!isDarkMode, isDarkMode],
                    onPressed: (index) {
                      setState(() {
                        isDarkMode = index == 1;
                      });

                      // 🔜 Ready to connect to global theme provider
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.light_mode, size: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.dark_mode, size: 20),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ===== SUBSCRIPTION =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    local.subscriptionLower,
                    style: const TextStyle(fontSize: 18),
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
