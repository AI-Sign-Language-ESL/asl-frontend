import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import '../providers/theme/app_theme_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../widgets/tafahom_logo.dart';
import '../widgets/plan_badge.dart';
import '../theme/subscription_plan.dart';
import '../features/sidebar/widgets/modern_hamburger_icon.dart';

class SubscriptionScreen extends StatelessWidget {
  final VoidCallback? onMenuTap;
  const SubscriptionScreen({Key? key, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<AppThemeProvider>().isDarkMode;

    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color appBarBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        leading: ModernHamburgerIcon(
          color: menuIconColor,
          size: 26,
          onTap: onMenuTap ?? () {},
        ),
        title: const TafahomLogo(height: 22),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            Text(
              local.choosePlan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Unlock the power of AI-driven sign language',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            _buildCurrentPlanBadge(context),
            const SizedBox(height: 28),
            _buildPlanCard(
              context,
              local.planFree,
              local.priceFree,
              Icons.person_outline_rounded,
              const Color(0xFF94A3B8),
              [
                _Feature(local.freeTokens, Icons.token_rounded),
                _Feature(local.basicTextTranslation, Icons.translate_rounded),
                _Feature(local.basicSignGeneration, Icons.sign_language_rounded),
                _Feature(local.communitySupport, Icons.forum_rounded),
              ],
              false,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              local.planBasic,
              local.priceBasic,
              Icons.star_outline_rounded,
              const Color(0xFF275878),
              [
                _Feature(local.basicTokens, Icons.token_rounded),
                _Feature(local.textToSpeech, Icons.record_voice_over_rounded),
                _Feature(local.speechToText, Icons.mic_rounded),
                _Feature(local.youtubeIntegration, Icons.video_library_rounded),
                _Feature(local.translationHistory, Icons.history_rounded),
                _Feature(local.generationHistory, Icons.auto_awesome_rounded),
              ],
              false,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              local.planGo,
              local.priceGo,
              Icons.rocket_launch_rounded,
              const Color(0xFFD97706),
              [
                _Feature(local.goTokens, Icons.token_rounded),
                _Feature(local.textToSpeech, Icons.record_voice_over_rounded),
                _Feature(local.speechToText, Icons.mic_rounded),
                _Feature(local.youtubeIntegration, Icons.video_library_rounded),
                _Feature(local.unlimitedTranslationHistory, Icons.history_rounded),
                _Feature(local.unlimitedGenerationHistory, Icons.auto_awesome_rounded),
                _Feature(local.priorityProcessing, Icons.speed_rounded),
              ],
              true,
              isDarkMode,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              local.planEnterprise,
              local.priceEnterprise,
              Icons.workspace_premium_rounded,
              const Color(0xFF7C3AED),
              [
                _Feature(local.enterpriseTokens, Icons.token_rounded),
                _Feature(local.createMeetings, Icons.videocam_rounded),
                _Feature(local.meetingChatHistory, Icons.chat_rounded),
                _Feature(local.unlimitedTranslationHistory, Icons.history_rounded),
                _Feature(local.unlimitedGenerationHistory, Icons.auto_awesome_rounded),
                _Feature(local.textToSpeech, Icons.record_voice_over_rounded),
                _Feature(local.speechToText, Icons.mic_rounded),
                _Feature(local.youtubeIntegration, Icons.video_library_rounded),
                _Feature(local.prioritySupport, Icons.support_agent_rounded),
              ],
              false,
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanBadge(BuildContext context) {
    final plan = context.watch<AuthProvider>().plan;

    return Center(
      child: Column(
        children: [
          Text(
            'Current Plan',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          PlanBadge(plan: plan, fontSize: 15),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    String planName,
    String priceText,
    IconData planIcon,
    Color accent,
    List<_Feature> features,
    bool isPopular,
    bool isDarkMode,
  ) {
    final local = AppLocalizations.of(context)!;
    final cardBg = isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isPopular
                ? accent.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: isPopular ? 24 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: isPopular ? 0.6 : 0.25),
                width: isPopular ? 2 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(planIcon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            priceText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD97706),
                              const Color(0xFFF59E0B),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          local.popular,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: accent,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            f.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF334155),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(f.icon, color: accent.withValues(alpha: 0.5), size: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      local.subscribeNow,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String label;
  final IconData icon;
  const _Feature(this.label, this.icon);
}
