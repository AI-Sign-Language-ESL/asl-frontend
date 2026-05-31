import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_data.dart';
import '../widgets/dashboard_card.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/token/token_provider.dart';
import '../../../providers/dataset/dataset_provider.dart';
import '../../../providers/notification/notification_provider.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../widgets/tafahom_logo.dart';
import '../../../widgets/plan_badge.dart';
import '../../../theme/subscription_plan.dart';
import '../../notifications/screens/notifications_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const ProfileSettingsScreen({
    super.key,
    this.onMenuTap,
  });

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool get isDark => context.read<AppThemeProvider>().isDarkMode;

  String _userName = '';
  String _userEmail = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      _userName =       auth.userName ?? '';
      _userEmail = auth.userEmail ?? '';
      context.read<TokenProvider>().fetchBalance();
      context.read<DatasetProvider>().fetchContributions();
    });
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppThemeProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 768;
    final bg = isDark ? DashboardColors.darkBackground : DashboardColors.background;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final textPrimary =
        isDark ? DashboardColors.darkTextPrimary : DashboardColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: textPrimary.withValues(alpha: 0.7),
            ),
            onPressed: widget.onMenuTap ?? () {},
          ),
          const Spacer(),
          const TafahomLogo(height: 22),
          const Spacer(),
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DashboardColors.gradientStart, DashboardColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: ListenableBuilder(
                    listenable: context.read<NotificationProvider>(),
                    builder: (context, _) {
                      final unread = context.read<NotificationProvider>().unreadCount;
                      if (unread == 0) return const SizedBox.shrink();
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildProfileHeader(),
        const SizedBox(height: 24),
        _buildContributionsStats(),
        const SizedBox(height: 24),
        _buildAccountDetails(),
        const SizedBox(height: 24),
        _buildTokenBalance(),
        const SizedBox(height: 24),
        _buildSettingsSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildProfileHeader(),
        const SizedBox(height: 24),
        _buildContributionsStats(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAccountDetails()),
            const SizedBox(width: 24),
            Expanded(child: _buildTokenBalance()),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DashboardColors.gradientStart, DashboardColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _userName.isNotEmpty
                  ? _userName.split(' ').map((e) => e[0]).take(2).join()
                  : '?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _userName.isNotEmpty ? _userName : 'User',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          if (_userEmail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _userEmail,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (_userRole.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _userRole,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContributionsStats() {
    final provider = context.watch<DatasetProvider>();
    final textPrimary =
        isDark ? DashboardColors.darkTextPrimary : DashboardColors.textPrimary;
    final textSecondary =
        isDark ? DashboardColors.darkTextSecondary : DashboardColors.textSecondary;

    return DashboardCard(
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.cloud_upload_rounded,
              provider.loading ? '...' : '${provider.totalContributions}',
              'Total',
              DashboardColors.primaryBlue,
              textPrimary,
              textSecondary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.check_circle_rounded,
              provider.loading ? '...' : '${provider.approvedContributions}',
              'Approved',
              DashboardColors.success,
              textPrimary,
              textSecondary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: textSecondary.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.hourglass_empty_rounded,
              provider.loading ? '...' : '${provider.pendingContributions}',
              'Pending',
              DashboardColors.warning,
              textPrimary,
              textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color,
      Color textPrimary, Color textSecondary) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails() {
    final textPrimary =
        isDark ? DashboardColors.darkTextPrimary : DashboardColors.textPrimary;
    final textSecondary =
        isDark ? DashboardColors.darkTextSecondary : DashboardColors.textSecondary;

    final details = <(String, String, IconData)>[
      if (_userName.isNotEmpty) ('Full Name', _userName, Icons.person_outline_rounded),
      if (_userEmail.isNotEmpty) ('Email', _userEmail, Icons.email_outlined),
      if (_userRole.isNotEmpty) ('Role', _userRole, Icons.work_outline_rounded),
    ];

    return DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: DashboardColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...details.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Icon(d.$3, size: 18, color: textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            d.$2,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: TextButton.styleFrom(
                foregroundColor: DashboardColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: DashboardColors.primaryBlue.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenBalance() {
    final textPrimary =
        isDark ? DashboardColors.darkTextPrimary : DashboardColors.textPrimary;
    final textSecondary =
        isDark ? DashboardColors.darkTextSecondary : DashboardColors.textSecondary;
    final tokenProvider = context.watch<TokenProvider>();
    final authProvider = context.watch<AuthProvider>();
    final remainingTokens = tokenProvider.remainingTokens;
    final weeklyLimit = tokenProvider.weeklyLimit;
    final usageRatio = tokenProvider.usageRatio;
    final usagePercent = (usageRatio * 100).round();
    final plan = authProvider.plan;

    return DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.token_rounded,
                  color: DashboardColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Subscription',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              PlanBadge(plan: plan, showIcon: false, fontSize: 11, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.gradientStart.withValues(alpha: 0.1),
                  DashboardColors.gradientEnd.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: DashboardColors.primaryBlue.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Token Balance',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: DashboardColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: DashboardColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DashboardColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tokenProvider.loading ? '...' : remainingTokens.toString(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: DashboardColors.primaryBlue,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'tokens remaining',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: usageRatio,
                  backgroundColor: DashboardColors.primaryBlue.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usagePercent > 80
                        ? DashboardColors.warning
                        : DashboardColors.primaryBlue,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),
                Text(
                  '$usagePercent% of $weeklyLimit weekly limit used',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.rocket_launch_rounded, size: 18),
              label: const Text('Upgrade Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final textPrimary =
        isDark ? DashboardColors.darkTextPrimary : DashboardColors.textPrimary;
    final textSecondary =
        isDark ? DashboardColors.darkTextSecondary : DashboardColors.textSecondary;

    final settings = [
      ('Dark Mode', Icons.dark_mode_rounded, null, () => context.read<AppThemeProvider>().toggleTheme(), true),
      ('Notifications', Icons.notifications_outlined, null, () {}, false),
      ('Language', Icons.language_rounded, 'English', () {}, false),
      ('Privacy', Icons.shield_outlined, null, () {}, false),
      ('Help & Support', Icons.help_outline_rounded, null, () {}, false),
    ];

    return DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DashboardColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: DashboardColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...settings.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isLast = i == settings.length - 1;

            if (s.$5) {
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.$2, size: 20, color: textSecondary),
                  ),
                  title: Text(
                    s.$1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (_) => s.$4(),
                    activeColor: DashboardColors.primaryBlue,
                  ),
                  onTap: null,
                  dense: true,
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s.$2, size: 20, color: textSecondary),
                ),
                title: Text(
                  s.$1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (s.$3 != null)
                      Text(
                        s.$3 as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: textSecondary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                onTap: s.$4,
                dense: true,
              ),
            );
          }),
        ],
      ),
    );
  }
}
