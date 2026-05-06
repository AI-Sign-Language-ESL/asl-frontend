import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart'
    show AppLocalizations;

import '../main.dart'; // ThemeProvider
import 'sign_to_text_screen.dart';
import 'dataset_contribution_screen.dart';
import 'custom_sidebar.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color primaryBlue = Color(0xFF275878);
  static const Color primaryBlueDark = Color(0xFF4A90C4);
  static const Color background = Color(0xFFD5EBF5);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  HomeScreen({
    super.key,
    required this.username,
    required String usernameLower,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // ── Adaptive palette ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : primaryWhite;
    final Color accent = isDarkMode ? primaryBlueDark : primaryBlue;
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color usernameColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: CustomSidebar(selectedIndex: 0, onItemTapped: (int p1) {}),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Center(
                      child: isArabic
                          ? Text(
                              'تَفَاهُمٌ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: accent,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : isDarkMode
                              ? Text(
                                  'TAFAHOM',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
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
                    icon: Icon(Icons.menu, color: menuIconColor, size: 32),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Welcome ──────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 34, height: 0.7),
                  children: [
                    TextSpan(
                      text: local.welcome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    TextSpan(
                      text: ' $username',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: usernameColor,
                      ),
                    ),
                    TextSpan(
                      text: local.exclamationEmoji,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildMainCard(context, local, isArabic, isDarkMode, accent),
              const SizedBox(height: 20),
              _buildDialectsCard(local, isArabic, isDarkMode, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    AppLocalizations local,
    bool isArabic,
    bool isDarkMode,
    Color accent,
  ) {
    final Color cardBg =
        isDarkMode ? const Color(0xFF1A2D3D) : const Color(0xFF7FA1B6);
    final Color descColor = isDarkMode ? Colors.white60 : Colors.black;
    final Color btnBg = isDarkMode ? const Color(0xFF4A90C4) : primaryBlue;
    final Color secondBtnBg = isDarkMode ? const Color(0xFF2A2A2A) : background;
    final Color secondBtnText = isDarkMode ? Colors.white70 : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
              children: isArabic
                  ? [
                      TextSpan(
                        text: "تعزيز حق ",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text: "التواصل ",
                        style: TextStyle(color: accent),
                      ),
                      TextSpan(
                        text: "لكل أفراد المجتمع.",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.white70,
                        ),
                      ),
                    ]
                  : [
                      TextSpan(
                        text: "Bridging the Gap Between ",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text: "Sound ",
                        style: TextStyle(color: accent),
                      ),
                      TextSpan(
                        text: "and ",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.white70,
                        ),
                      ),
                      TextSpan(
                        text: "Silence.",
                        style: TextStyle(color: accent),
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 13),
          Text(
            local.mainDescription,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: descColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          // Start Translating Button
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignToTextScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: btnBg,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              local.startTranslating,
              style: const TextStyle(
                color: primaryWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Contribute Button
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DatasetContributionScreen(),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: secondBtnBg,
              foregroundColor: secondBtnText,
              minimumSize: const Size(double.infinity, 52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              local.contributeDataset,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: secondBtnText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialectsCard(
    AppLocalizations local,
    bool isArabic,
    bool isDarkMode,
    Color accent,
  ) {
    final Color cardBg =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFD5EBF5);
    final Color labelColor = isDarkMode ? Colors.white : Colors.black;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.supportedDialects,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  _DialectChip(
                    flag: '🇪🇬',
                    label: 'ESL',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 15),
                  _DialectChip(
                    flag: '🇺🇸',
                    label: 'ASL',
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: isArabic ? null : 10,
          left: isArabic ? 10 : null,
          bottom: -10,
          child: Opacity(
            opacity: 0.2,
            child: Icon(Icons.translate, size: 140, color: accent),
          ),
        ),
      ],
    );
  }
}

class _DialectChip extends StatelessWidget {
  final String flag;
  final String label;
  final bool isDarkMode;

  const _DialectChip({
    required this.flag,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode ? Colors.white24 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
