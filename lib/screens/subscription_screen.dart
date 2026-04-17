import 'package:flutter/material.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  // Hamburger button only (no language picker as requested)
  Widget _buildHamburger(bool isArabic) {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.black, size: 30),
        onPressed: () => isArabic
            ? Scaffold.of(context).openEndDrawer()
            : Scaffold.of(context).openDrawer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,

      // Sidebar - Same as all other screens
      drawer: isArabic
          ? null
          : CustomSidebar(
              selectedIndex: 4,
              onItemTapped: (index) => _handleNavigation(context, index),
            ),
      endDrawer: isArabic
          ? CustomSidebar(
              selectedIndex: 4,
              onItemTapped: (index) => _handleNavigation(context, index),
            )
          : null,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: isArabic
            ? const Text(
                'تَفَاهُمٌ',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF275878),
                ),
              )
            : Image.asset(
                'assets/TAFAHOM.png',
                width: 120,
                height: 30,
                fit: BoxFit.contain,
              ),

        // Hamburger only - on correct side
        leading: isArabic
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  _buildHamburger(isArabic),
                ],
              )
            : null,

        actions: isArabic
            ? [const SizedBox(width: 12)]
            : [
                _buildHamburger(isArabic),
                const SizedBox(width: 12),
              ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              local.choosePlan,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            _buildPlanCard(
              context,
              "E£ 100",
              local.for1Month,
              [local.plus100Coin, local.textToSign, local.speech],
              false,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              "E£ 240",
              local.for3Months,
              [local.plus150Coin, local.textToSign, local.meetings],
              true,
            ),
          ],
        ),
      ),
    );
  }

  // Fixed Navigation Handler
  void _handleNavigation(BuildContext context, int index) {
    // Close drawer first
    Navigator.pop(context);

    // Small delay for smooth drawer close animation
    Future.delayed(const Duration(milliseconds: 250), () {
      switch (index) {
        case 0: // Home
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          break;
        case 1: // Text to Sign
          Navigator.pushReplacementNamed(context, '/text_to_sign');
          break;
        case 2: // Sign to Text
          Navigator.pushReplacementNamed(context, '/sign_to_text');
          break;
        case 3: // Dataset Contribution
          Navigator.pushReplacementNamed(context,
              '/dataset-contribution'); // Change if your route name is different
          break;
        case 4: // Subscription (do nothing - already here)
          break;
        case 5: // Profile
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 6: // Settings
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    });
  }

  Widget _buildPlanCard(
    BuildContext context,
    String price,
    String duration,
    List<String> features,
    bool isPopular,
  ) {
    final local = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isPopular
                ? Border.all(color: AppColors.primaryBlue, width: 3)
                : Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(duration, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Text(f),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  local.subscribeNow,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: 10,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                local.popular,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}
