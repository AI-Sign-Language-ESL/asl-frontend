import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class ProfileScreen extends StatelessWidget {
  /// The display name coming from the sign-in / sign-up response.
  final String userName;

  /// True when the signed-in account is an organisation account.
  /// Controls which profile detail screen is opened.
  final bool isOrganization;

  const ProfileScreen({
    Key? key,
    required this.userName,
    this.isOrganization = false,
  }) : super(key: key);

  static const Color underlineColor = Color(0xFFD5EBF5);
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
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
            // ── Top bar ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
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

            // ── Profile content ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    border:
                        Border.all(color: const Color(0xFFD5EBF5), width: 3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Section header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: underlineColor, width: 2)),
                        ),
                        child: Text(
                          local.profile,
                          textAlign:
                              isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF275878)),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Column(
                          children: [
                            // ── Avatar row (dynamic name, no subtitle) ────────
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
                                          'https://randomuser.me/api/portraits/men/32.jpg'),
                                    ),
                                    const SizedBox(width: 15),
                                    // Only the name – subtitle removed
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Personal Information ──────────────────────────
                            // Routes to org-profile or user-profile depending on
                            // the account type passed from the sign-in flow.
                            _buildMenuItem(
                              Icons.person_outline,
                              local.personalInfo,
                              isArabic,
                              () => Navigator.pushNamed(
                                context,
                                isOrganization
                                    ? '/org-profile'
                                    : '/user-profile',
                              ),
                            ),

                            // ── Change Password ───────────────────────────────
                            // Pushes the reset-password screen directly.
                            // The reset-password screen is responsible for
                            // pushing /reset-sent, and reset-sent pops back
                            // to /profile when done.
                            _buildMenuItem(
                              Icons.lock_outline,
                              "Change Password",
                              isArabic,
                              () => Navigator.pushNamed(
                                  context, '/reset-password'),
                            ),

                            // ── Manage Subscription ───────────────────────────
                            _buildMenuItem(
                              Icons.card_membership,
                              "Manage Subscription",
                              isArabic,
                              () =>
                                  Navigator.pushNamed(context, '/subscription'),
                            ),

                            // ── Logout ────────────────────────────────────────
                            _buildMenuItem(
                              Icons.logout,
                              local.logout,
                              isArabic,
                              () => Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false),
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
      IconData icon, String title, bool isArabic, VoidCallback onTap) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: const Color(0xFF275878), size: 24),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: Icon(
          isArabic ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
