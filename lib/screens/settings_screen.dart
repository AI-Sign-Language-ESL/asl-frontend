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
  static const Color underlineColor = Color(0xFFD5EBF5);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    // ── Consume ThemeProvider ─────────────────────────────────────────────
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    // ── Adaptive colours ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBorder =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color titleColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color dividerColor =
        isDarkMode ? const Color(0xFF2C2C2C) : underlineColor;
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: isArabic
          ? null
          : CustomSidebar(selectedIndex: 6, onItemTapped: (index) {}),
      endDrawer: isArabic
          ? CustomSidebar(selectedIndex: 6, onItemTapped: (index) {})
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: menuIconColor,
                            size: 32,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'تَفَاهُمٌ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ]
                    : [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: isDarkMode
                                ? Text(
                                    'TAFAHOM',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: titleColor,
                                      letterSpacing: 2,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/TAFAHOM.png',
                                    width: 120,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: menuIconColor,
                            size: 32,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ],
              ),
            ),

            // ── Settings card ─────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              padding: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: cardBorder, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Section header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: dividerColor, width: 2),
                      ),
                    ),
                    child: Text(
                      local.settings,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),

                        // ── Language toggle ──────────────────────────────
                        _buildRow(
                          local.appLanguage,
                          isArabic,
                          labelColor,
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: titleColor,
                            color: labelColor,
                            borderColor: isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                            selectedBorderColor: titleColor,
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 50,
                            ),
                            isSelected: [isArabic, !isArabic],
                            onPressed: (index) {
                              localeProvider.setLocale(
                                index == 0
                                    ? const Locale('ar')
                                    : const Locale('en'),
                              );
                            },
                            children: const [
                              Text(
                                "AR",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "EN",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Theme toggle ─────────────────────────────────
                        // Now wired to ThemeProvider so the whole app reacts
                        _buildRow(
                          local.appTheme,
                          isArabic,
                          labelColor,
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(30),
                            selectedColor: Colors.white,
                            fillColor: titleColor,
                            color: labelColor,
                            borderColor: isDarkMode
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300,
                            selectedBorderColor: titleColor,
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 50,
                            ),
                            isSelected: [!isDarkMode, isDarkMode],
                            onPressed: (index) {
                              // index 0 = light, index 1 = dark
                              themeProvider.toggleDarkMode(index == 1);
                            },
                            children: const [
                              Icon(Icons.light_mode, size: 16),
                              Icon(Icons.dark_mode, size: 16),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ── Subscription row ─────────────────────────────
                        _buildRow(
                          local.subscriptionLower,
                          isArabic,
                          labelColor,
                          Text(
                            local.oneMonthLeft,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildRow(
    String label,
    bool isArabic,
    Color labelColor,
    Widget trailing,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        trailing,
      ],
    );
  }
}
