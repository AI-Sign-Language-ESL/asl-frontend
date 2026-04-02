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
  static const Color underlineColor = Color(0xFFD5EBF5);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isArabic
          ? null
          : CustomSidebar(
              selectedIndex: 6,
              onItemTapped: (index) {},
            ),
      endDrawer: isArabic
          ? CustomSidebar(
              selectedIndex: 6,
              onItemTapped: (index) {},
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            //Custom top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
                        // Arabic: hamburger LEFT → logo center → spacer RIGHT
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.black, size: 32),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                        Expanded(
                          child: Center(
                            child: const Text(
                              'تَفَاهُمٌ',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF275878)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ]
                    : [
                        // English: spacer LEFT → logo center → hamburger RIGHT
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: Image.asset('assets/TAFAHOM.png',
                                width: 120, height: 40, fit: BoxFit.contain),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.black, size: 32),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ],
              ),
            ),

            // Settings content
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: const Color(0xFFD5EBF5), width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 15),
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: underlineColor, width: 2)),
                    ),
                    child: Text(
                      local.settings,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF275878)),
                    ),
                  ),
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
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
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
                              Icon(Icons.dark_mode, size: 16),
                            ],
                          ),
                        ),
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
