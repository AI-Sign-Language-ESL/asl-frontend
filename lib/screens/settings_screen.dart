import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../providers/locale/app_locale_provider.dart';
import '../../../features/sidebar/widgets/modern_hamburger_icon.dart';
import '../widgets/tafahom_logo.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const SettingsScreen({Key? key, this.onMenuTap}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final localeProvider = context.watch<AppLocaleProvider>();
    final themeProvider = context.watch<AppThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;
    final isArabic = localeProvider.locale.languageCode == 'ar';

    final scaffoldBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    const primaryColor = Color(0xFF2563EB);
    final accentColor = isDarkMode ? const Color(0xFF60A5FA) : const Color(0xFF275878);
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final menuIconColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isArabic, menuIconColor, accentColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      local.settings,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic ? 'إدارة تفضيلات تطبيقك' : 'Manage your app preferences',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: isArabic ? 'المظهر واللغة' : 'Appearance & Language',
                      icon: Icons.palette_outlined,
                      children: [
                        _buildSettingCard(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: local.appLanguage,
                          subtitle: isArabic ? 'اختر لغة التطبيق' : 'Choose app language',
                          trailing: _buildLanguageToggle(localeProvider, isArabic, cardBg, borderColor),
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 12),
                        _buildSettingCard(
                          icon: themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: local.appTheme,
                          subtitle: isDarkMode ? (isArabic ? 'الوضع الداكن' : 'Dark mode') : (isArabic ? 'الوضع الفاتح' : 'Light mode'),
                          trailing: _buildThemeToggle(themeProvider, cardBg, borderColor, primaryColor),
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: isArabic ? 'الاشتراك' : 'Subscription',
                      icon: Icons.workspace_premium_outlined,
                      children: [
                        _buildSettingCard(
                          icon: Icons.credit_card_rounded,
                          iconColor: primaryColor,
                          title: local.subscriptionLower,
                          subtitle: isArabic ? 'إدارة خطتك المدفوعة' : 'Manage your paid plan',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isArabic ? 'شهر واحد متبقي' : '1 month left',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: isArabic ? 'حول' : 'About',
                      icon: Icons.info_outline_rounded,
                      children: [
                        _buildInfoRow(
                          icon: Icons.info_outline_rounded,
                          iconColor: textSecondary,
                          title: isArabic ? 'الإصدار' : 'Version',
                          value: '1.0.0',
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.shield_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: isArabic ? 'الخصوصية' : 'Privacy Policy',
                          value: isArabic ? 'عرض' : 'View',
                          cardBg: cardBg,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isLink: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isArabic, Color menuIconColor, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildHamburgerButton(menuIconColor),
          const Spacer(),
          const TafahomLogo(height: 22),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHamburgerButton(Color iconColor) {
    return ModernHamburgerIcon(
      color: iconColor,
      size: 24,
      onTap: widget.onMenuTap ?? () {},
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final themeProvider = context.watch<AppThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textSecondary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color cardBg,
    required Color textPrimary,
    required Color textSecondary,
    bool isLink = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLink ? const Color(0xFF2563EB) : textSecondary,
            ),
          ),
          if (isLink) ...[
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF2563EB)),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(
    AppLocaleProvider localeProvider,
    bool isArabic,
    Color cardBg,
    Color borderColor,
  ) {
    final themeProvider = context.watch<AppThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    const primaryColor = Color(0xFF2563EB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: 'AR',
            isSelected: isArabic,
            onTap: () => localeProvider.setLocale(const Locale('ar')),
            primaryColor: primaryColor,
            textPrimary: textPrimary,
          ),
          _buildToggleOption(
            label: 'EN',
            isSelected: !isArabic,
            onTap: () => localeProvider.setLocale(const Locale('en')),
            primaryColor: primaryColor,
            textPrimary: textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color textPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(
    AppThemeProvider themeProvider,
    Color cardBg,
    Color borderColor,
    Color primaryColor,
  ) {
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: Container(
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? primaryColor : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isDark ? 26 : 2,
              top: 2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 14,
                  color: isDark ? primaryColor : const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
