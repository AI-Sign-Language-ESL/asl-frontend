import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart'
    show AppLocalizations;

// ✅ IMPORT YOUR TARGET SCREENS
import 'sign_to_text_screen.dart';
import 'dataset_contribution_screen.dart';
import 'custom_sidebar.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= TOP BAR =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/TAFAHOM TYPO.png',
                    width: 130,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  Row(
                    children: [
                      Icon(Icons.notifications_none,
                          color: Colors.grey.shade700),
                      const SizedBox(width: 12),

                      // ✅ FIXED HAMBURGER BUTTON
                      IconButton(
                        icon: Icon(Icons.menu, color: Colors.grey.shade700),
                        onPressed: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Sidebar",
                            barrierColor: Colors.black.withOpacity(0.3),
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder: (_, __, ___) {
                              return Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: double.infinity,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: CustomSidebar(
                                      selectedIndex: 0,
                                      onItemTapped: (index) {
                                        Navigator.pop(context); // close sidebar
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            transitionBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ================= WELCOME =================
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 30),
                  children: [
                    TextSpan(
                      text: local.welcome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F4E6A),
                      ),
                    ),
                    TextSpan(
                      text: '$username',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: local.exclamationEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= MAIN CARD =================
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF8FAFC3),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  // ... (truncated 1602 characters)...
                  children: [
                    // ... (assuming no additional strings in truncated part; add if there are)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignToTextScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F5D7C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          local.startTranslating,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DatasetContributionScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8F3FA),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          local.contributeDataset,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= SUPPORTED DIALECTS =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1EEF6),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.supportedDialects,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        _DialectChip(flag: '🇪🇬', label: 'ESL'),
                        SizedBox(width: 12),
                        _DialectChip(flag: '🇺🇸', label: 'ASL'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DIALECT CHIP =================
class _DialectChip extends StatelessWidget {
  final String flag;
  final String label;

  const _DialectChip({
    required this.flag,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE1EEF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
