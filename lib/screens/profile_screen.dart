import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const Color underlineColor = Color(0xFFD5EBF5);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: CustomSidebar(
        selectedIndex: 5,
        onItemTapped: (index) {
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: isArabic
            ? const Text('تَفَاهُمٌ',
                style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF275878)))
            : Image.asset('assets/TAFAHOM.png',
                width: 120, height: 30, fit: BoxFit.contain),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFD5EBF5), width: 3),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Profile Title with Full Width Underline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: underlineColor, width: 2),
                    ),
                  ),
                  child: Text(
                    local.profile,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF275878),
                    ),
                  ),
                ),

                // 2. Profile Content Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      // User Info (Tappable - Navigates to User Profile)
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/user-profile'),
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
                              Column(
                                crossAxisAlignment: isArabic
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  const Text("Mahmoud Ahmed",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text(local.signInterpreter,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Menu Items with Logic
                      _buildMenuItem(
                        Icons.person_outline,
                        local.personalInfo,
                        isArabic,
                        () => Navigator.pushNamed(context, '/user-profile'),
                      ),
                      _buildMenuItem(
                        Icons.lock_outline,
                        "Change Password", // Add this to your ARB if needed
                        isArabic,
                        () => Navigator.pushNamed(context, '/reset-password'),
                      ),
                      _buildMenuItem(
                        Icons.card_membership,
                        "Manage Subscription", // Add this to your ARB if needed
                        isArabic,
                        () => Navigator.pushNamed(context, '/subscription'),
                      ),
                      _buildMenuItem(
                        Icons.logout,
                        local.logout,
                        isArabic,
                        () {
                          // Logout Logic: Clear tokens and pop to login
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        },
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

  Widget _buildMenuItem(
      IconData icon, String title, bool isArabic, VoidCallback onTap) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Icon(icon, color: const Color(0xFF275878), size: 24),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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
