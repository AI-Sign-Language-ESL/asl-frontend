import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../main.dart';
import 'custom_sidebar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  // Define the requested underline color
  static const Color underlineColor = Color(0xFFD5EBF5);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    bool isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: CustomSidebar(
        selectedIndex: 5,
        onItemTapped: (index) {},
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: isArabic
            ? const Text('تَفَاهُمٌ',
                style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF275878)))
            : Image.asset('assets/TAFAHOM.png', width: 120, height: 30),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.only(
                bottom: 30), // Vertical padding for bottom items
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFD5EBF5), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Title with Underline across the container width
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 15),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: underlineColor, width: 2),
                    ),
                  ),
                  child: Text(
                    local.settings,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF275878),
                    ),
                  ),
                ),

                // Rows with padding to keep them away from the border
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      _buildRow(
                          local.appLanguage,
                          isArabic,
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: const Color(0xFF275878),
                            constraints: const BoxConstraints(
                                minHeight: 32, minWidth: 50),
                            isSelected: [isArabic, !isArabic],
                            onPressed: (index) {
                              localeProvider.setLocale(index == 0
                                  ? const Locale('ar')
                                  : const Locale('en'));
                            },
                            children: const [
                              Text("AR",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Text("EN",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold))
                            ],
                          )),
                      const SizedBox(height: 20),
                      _buildRow(
                          local.appTheme,
                          isArabic,
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: const Color(0xFF275878),
                            constraints: const BoxConstraints(
                                minHeight: 32, minWidth: 50),
                            isSelected: [!isDarkMode, isDarkMode],
                            onPressed: (index) =>
                                setState(() => isDarkMode = index == 1),
                            children: const [
                              Icon(Icons.light_mode, size: 16),
                              Icon(Icons.dark_mode, size: 16)
                            ],
                          )),
                      const SizedBox(height: 25),
                      _buildRow(
                        local.subscriptionLower,
                        isArabic,
                        Text(
                          local.oneMonthLeft,
                          style: const TextStyle(
                              color: Color(0xFF275878),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, bool isArabic, Widget trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
        trailing,
      ],
    );
  }
}
