import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../main.dart'; // ThemeProvider
import 'custom_sidebar.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final bool isOrganization;

  const ProfileScreen({
    Key? key,
    required this.userName,
    this.isOrganization = false,
  }) : super(key: key);

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // ── Adaptive palette ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBorder =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color titleColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color dividerColor =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color nameTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color chevronColor =
        isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: isArabic
          ? null
          : CustomSidebar(
              selectedIndex: 5,
              onItemTapped: (index) => Navigator.pop(context),
            ),
      endDrawer: isArabic
          ? CustomSidebar(
              selectedIndex: 5,
              onItemTapped: (index) => Navigator.pop(context),
            )
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

            // ── Profile content ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: cardBorder, width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Section header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: dividerColor, width: 2),
                          ),
                        ),
                        child: Text(
                          local.profile,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          children: [
                            // Avatar row
                            InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                isOrganization
                                    ? '/org-profile'
                                    : '/user-profile',
                              ),
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        'https://randomuser.me/api/portraits/men/32.jpg',
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: nameTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildMenuItem(
                              Icons.person_outline,
                              local.personalInfo,
                              isArabic,
                              isDarkMode,
                              titleColor,
                              chevronColor,
                              () => Navigator.pushNamed(
                                context,
                                isOrganization
                                    ? '/org-profile'
                                    : '/user-profile',
                              ),
                            ),
                            _buildMenuItem(
                              Icons.lock_outline,
                              "Change Password",
                              isArabic,
                              isDarkMode,
                              titleColor,
                              chevronColor,
                              () => Navigator.pushNamed(
                                context,
                                '/reset-password',
                              ),
                            ),
                            _buildMenuItem(
                              Icons.card_membership,
                              "Manage Subscription",
                              isArabic,
                              isDarkMode,
                              titleColor,
                              chevronColor,
                              () =>
                                  Navigator.pushNamed(context, '/subscription'),
                            ),
                            _buildMenuItem(
                              Icons.logout,
                              local.logout,
                              isArabic,
                              isDarkMode,
                              titleColor,
                              chevronColor,
                              () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    bool isArabic,
    bool isDarkMode,
    Color iconColor,
    Color chevronColor,
    VoidCallback onTap,
  ) {
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: Icon(
          isArabic ? Icons.chevron_left : Icons.chevron_right,
          color: chevronColor,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
