import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../main.dart'; // ThemeProvider
import 'custom_sidebar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  Widget _buildHamburger(bool isArabic) {
    return Builder(
      builder: (context) => IconButton(
        icon: Icon(
          Icons.menu,
          color: context.watch<ThemeProvider>().isDarkMode
              ? Colors.white70
              : Colors.black,
          size: 30,
        ),
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
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // ── Adaptive palette ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color titleColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color appBarBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color subTitleColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
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
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: isArabic
            ? Text(
                'تَفَاهُمٌ',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              )
            : isDarkMode
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
                    height: 30,
                    fit: BoxFit.contain,
                  ),
        leading: isArabic
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [const SizedBox(width: 8), _buildHamburger(isArabic)],
              )
            : null,
        actions: isArabic
            ? [const SizedBox(width: 12)]
            : [_buildHamburger(isArabic), const SizedBox(width: 12)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              local.choosePlan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: subTitleColor,
              ),
            ),
            const SizedBox(height: 30),
            _buildPlanCard(
              context,
              "E£ 100",
              local.for1Month,
              [local.plus100Coin, local.textToSign, local.speech],
              false,
              isDarkMode,
              titleColor,
            ),
            const SizedBox(height: 20),
            _buildPlanCard(
              context,
              "E£ 240",
              local.for3Months,
              [local.plus150Coin, local.textToSign, local.meetings],
              true,
              isDarkMode,
              titleColor,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 250), () {
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/text_to_sign');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/sign_to_text');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/dataset-contribution');
          break;
        case 4:
          break;
        case 5:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 6:
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
    bool isDarkMode,
    Color accentColor,
  ) {
    final local = AppLocalizations.of(context)!;
    final Color cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color normalBorder =
        isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade300;
    final Color featureTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color durationColor = isDarkMode ? Colors.grey.shade500 : Colors.grey;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: isPopular
                ? Border.all(color: accentColor, width: 3)
                : Border.all(color: normalBorder),
          ),
          child: Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Text(duration, style: TextStyle(color: durationColor)),
              const SizedBox(height: 20),
              ...features.map(
                (f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: accentColor),
                      const SizedBox(width: 10),
                      Text(f, style: TextStyle(color: featureTextColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  local.subscribeNow,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
