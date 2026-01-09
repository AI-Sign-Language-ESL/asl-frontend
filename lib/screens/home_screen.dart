import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart'
    show AppLocalizations;

import 'sign_to_text_screen.dart';
import 'dataset_contribution_screen.dart';
import 'custom_sidebar.dart'; // Ensure this file exports CustomSidebar

class HomeScreen extends StatelessWidget {
  final String username;

  // Use a GlobalKey to manage the Scaffold state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color background = Color(0xFFD5EBF5);
  static const Color primaryBlue = Color(0xFF275878);
  static const Color cardBlue = Color(0xFF8FAFC3);
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

    return Scaffold(
      key: _scaffoldKey, // 1. Assign the key here
      backgroundColor: primaryWhite,
      // 2. Add the CustomSidebar as a drawer (or endDrawer for RTL support)
      drawer: CustomSidebar(
        selectedIndex: 0,
        onItemTapped: (int p1) {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP BAR =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isArabic)
                    const Text(
                      'تَفَاهُمٌ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF275878),
                        height: 1.1,
                      ),
                      textAlign: TextAlign.right,
                    )
                  else
                    Image.asset(
                      'assets/TAFAHOM.png',
                      width: 120,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  Row(
                    children: [
                      const Icon(Icons.notifications,
                          color: Color(0xFFD4AF37), size: 28),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.black, size: 32),
                        onPressed: () {
                          // 3. Open the drawer using the scaffold key
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ================= WELCOME =================
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 34, height: 0.7),
                  children: [
                    TextSpan(
                      text: local.welcome,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    TextSpan(
                      text: ' $username',
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    TextSpan(
                      text: local.exclamationEmoji,
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildMainCard(context, local, isArabic),
              const SizedBox(height: 20),
              _buildDialectsCard(local, isArabic),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep your _buildMainCard and _buildDialectsCard methods exactly as they were)

  Widget _buildMainCard(
      BuildContext context, AppLocalizations local, bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 127, 161, 182),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled title to match multi-color design in screenshots [cite: 11, 14]
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
              children: isArabic
                  ? [
                      const TextSpan(
                          text: "تعزيز حق ",
                          style: TextStyle(color: Colors.white70)),
                      const TextSpan(
                          text: "التواصل ",
                          style: TextStyle(color: primaryBlue)),
                      const TextSpan(
                          text: "لكل أفراد المجتمع.",
                          style: TextStyle(color: Colors.white70)),
                    ]
                  : [
                      const TextSpan(
                          text: "Bridging the Gap Between ",
                          style: TextStyle(color: Colors.white70)),
                      const TextSpan(
                          text: "Sound ", style: TextStyle(color: primaryBlue)),
                      const TextSpan(
                          text: "and ",
                          style: TextStyle(color: Colors.white70)),
                      const TextSpan(
                          text: "Silence.",
                          style: TextStyle(color: primaryBlue)),
                    ],
            ),
          ),
          const SizedBox(height: 13),
          Text(
            local.mainDescription,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 17),
          // Start Translating Button
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SignToTextScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              local.startTranslating,
              style: const TextStyle(
                  color: primaryWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          // Contribute Button
          ElevatedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DatasetContributionScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: background,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              local.contributeDataset,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialectsCard(AppLocalizations local, bool isArabic) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Color(0xFFD5EBF5), // EXACT COLOR: #A5BCCA8A
            borderRadius: BorderRadius.circular(35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.supportedDialects,
                style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
              const SizedBox(height: 25),
              Row(
                children: const [
                  _DialectChip(flag: '🇪🇬', label: 'ESL'),
                  SizedBox(width: 15),
                  _DialectChip(flag: '🇺🇸', label: 'ASL'),
                ],
              ),
            ],
          ),
        ),
        // Watermark Icon exactly as seen in design [cite: 11, 12]
        Positioned(
          right: isArabic ? null : 10,
          left: isArabic ? 10 : null,
          bottom: -10,
          child: Opacity(
            opacity: 0.2,
            child: Icon(Icons.translate, size: 140, color: primaryBlue),
          ),
        ),
      ],
    );
  }
}

class _DialectChip extends StatelessWidget {
  final String flag;
  final String label;

  const _DialectChip({required this.flag, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
