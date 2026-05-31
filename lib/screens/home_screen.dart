import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart'
    show AppLocalizations;

import '../providers/theme/app_theme_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/notification/notification_provider.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../widgets/tafahom_logo.dart';
import '../features/sidebar/widgets/modern_hamburger_icon.dart';
import 'sign_to_text_screen.dart';
import 'text_to_sign_screen.dart';
import 'dataset_contribution_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final VoidCallback? onMenuTap;

  static const Color primaryBlue = Color(0xFF275878);
  static const Color primaryBlueDark = Color(0xFF4A90C4);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  HomeScreen({
    super.key,
    required this.username,
    required String usernameLower,
    this.onMenuTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final isDarkMode = context.watch<AppThemeProvider>().isDarkMode;
    final authProvider = context.watch<AuthProvider>();

    final scaffoldBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final accent = isDarkMode ? const Color(0xFF60A5FA) : primaryBlue;
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : primaryWhite;
    final textPrimary = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final menuIconColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, menuIconColor, isDarkMode, accent),
              const SizedBox(height: 24),
              _buildGreeting(context, textPrimary, textSecondary, accent, isDarkMode),
              const SizedBox(height: 28),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(context, accent, cardBg, textPrimary, textSecondary),
              const SizedBox(height: 28),
              Text(
                'Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeatures(context, cardBg, textPrimary, textSecondary, accent, isDarkMode),
              const SizedBox(height: 24),
              _buildBanner(context, accent, isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color menuIconColor, bool isDarkMode, Color accent) {
    return Row(
      children: [
          ModernHamburgerIcon(
            color: menuIconColor,
            size: 28,
            onTap: onMenuTap ?? () {},
          ),
          const Expanded(
            child: Center(
              child: TafahomLogo(height: 22),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<NotificationProvider>().fetchNotifications();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: menuIconColor,
                  size: 26,
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: ListenableBuilder(
                    listenable: context.read<NotificationProvider>(),
                    builder: (context, _) {
                      final unread = context.read<NotificationProvider>().unreadCount;
                      if (unread == 0) return const SizedBox.shrink();
                      return Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildGreeting(
    BuildContext context,
    Color textPrimary,
    Color textSecondary,
    Color accent,
    bool isDarkMode,
  ) {
    final local = AppLocalizations.of(context)!;
    final greetingKey = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          local.welcome,
          style: TextStyle(
            fontSize: 16,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                '$username!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: primaryWhite, size: 8),
                  SizedBox(width: 6),
                  Text(
                    'Free',
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    Color accent,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: [
        _ActionCard(
          icon: Icons.translate_rounded,
          title: 'Text to Sign',
          subtitle: 'Type & translate',
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TextToSignScreen()),
          ),
        ),
        _ActionCard(
          icon: Icons.sign_language_rounded,
          title: 'Sign to Text',
          subtitle: 'Camera translation',
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignToTextScreen()),
          ),
        ),
        _ActionCard(
          icon: Icons.cloud_upload_rounded,
          title: 'Contribute',
          subtitle: 'Add dataset videos',
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF047857)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DatasetContributionScreen()),
          ),
        ),
        _ActionCard(
          icon: Icons.workspace_premium_rounded,
          title: 'Premium',
          subtitle: 'Unlock all features',
          gradient: const LinearGradient(
            colors: [Color(0xFFD97706), Color(0xFFB45309)],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(
    BuildContext context,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color accent,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        _FeatureRow(
          icon: Icons.language_rounded,
          iconColor: const Color(0xFF2563EB),
          title: 'Multi-Language Support',
          description: 'Translate between sign language and text in real-time',
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),
        _FeatureRow(
          icon: Icons.camera_alt_rounded,
          iconColor: const Color(0xFF7C3AED),
          title: 'Real-Time Recognition',
          description: 'Advanced AI-powered sign language detection',
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 12),
        _FeatureRow(
          icon: Icons.group_rounded,
          iconColor: const Color(0xFF059669),
          title: 'Community Driven',
          description: 'Help improve the dataset by contributing videos',
          cardBg: cardBg,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildBanner(
    BuildContext context,
    Color accent,
    bool isDarkMode,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1E40AF), const Color(0xFF1E3A8A)]
              : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryWhite,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Unlock unlimited translations and premium features',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryWhite,
                    foregroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: primaryWhite,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Color cardBg;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDarkMode;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.cardBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textSecondary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
