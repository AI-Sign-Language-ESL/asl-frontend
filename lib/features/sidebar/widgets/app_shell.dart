import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../providers/sidebar/sidebar_provider.dart';
import '../../../providers/sidebar/navigation_provider.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/notification/notification_provider.dart';
import 'premium_sidebar.dart';

// Original screens — imported only for rendering, no circular dependency
import '../../../screens/home_screen.dart';
import '../../../screens/text_to_sign_screen.dart';
import '../../sign_to_text/screens/sign_to_text_screen.dart';
import '../../../screens/dataset_contribution_screen.dart';
import '../../../screens/subscription_screen.dart';
import '../../../screens/settings_screen.dart';
import '../../profile_settings/screens/profile_settings_screen.dart';

/// Main app shell that wraps original screens with the premium sidebar.
///
/// Responsive behavior:
/// - Desktop (>= 1200px): persistent sidebar with collapse toggle
/// - Mobile/Tablet: hamburger menu opens sidebar as drawer
///
/// All original screens are preserved unchanged. The shell only
/// provides the navigation chrome (sidebar + collapse button).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onLogout() {
    if (mounted) {
      context.read<NavigationProvider>().resetToHome();
      context.read<NotificationProvider>().fetchNotifications();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }

  Widget _buildCurrentPage(VoidCallback onMenuTap) {
    final authProvider = context.watch<AuthProvider>();
    final navigationProvider = context.watch<NavigationProvider>();
    final pages = [
      HomeScreen(
        username: authProvider.firstName ?? authProvider.userName ?? 'User',
        usernameLower: (authProvider.userName ?? 'user').toLowerCase(),
        onMenuTap: onMenuTap,
      ),
      TextToSignScreen(onMenuTap: onMenuTap),
      SignToTextScreen(onMenuTap: onMenuTap),
      DatasetContributionScreen(onMenuTap: onMenuTap),
      SubscriptionScreen(onMenuTap: onMenuTap),
      ProfileSettingsScreen(
        onMenuTap: onMenuTap,
      ),
      SettingsScreen(onMenuTap: onMenuTap),
    ];
    return pages[navigationProvider.currentPageIndex];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    context.watch<AppThemeProvider>();
    final sidebarProvider = context.watch<SidebarProvider>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppDimensions.breakpointDesktop;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final currentPage = _buildCurrentPage(() => _scaffoldKey.currentState?.openDrawer());

    // Desktop: persistent sidebar
    if (isDesktop) {
      return Scaffold(
        body: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            PremiumSidebar(onLogoutConfirmed: _onLogout),
            Container(
              width: 1,
              color: isDark ? const Color(0xFF1E293B) : AppColors.sidebarDivider,
            ),
            Expanded(
              child: Stack(
                children: [
                  currentPage,
                  /// Collapse toggle button
                  Positioned(
                    top: AppDimensions.spacingMd,
                    left: isRtl ? null : AppDimensions.spacingSm,
                    right: isRtl ? AppDimensions.spacingSm : null,
                    child: _CollapseButton(
                      isDark: isDark,
                      isCollapsed: sidebarProvider.isCollapsed,
                      isRtl: isRtl,
                      onTap: () => sidebarProvider.toggleCollapse(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Tablet: hamburger + drawer
    return Scaffold(
      key: _scaffoldKey,
      body: currentPage,
      drawer: Drawer(
        shape: RoundedRectangleBorder(
          borderRadius: isRtl
              ? const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXl),
                  bottomLeft: Radius.circular(AppDimensions.radiusXl),
                )
              : const BorderRadius.only(
                  topRight: Radius.circular(AppDimensions.radiusXl),
                  bottomRight: Radius.circular(AppDimensions.radiusXl),
                ),
        ),
        child: PremiumSidebar(
          onLogoutConfirmed: _onLogout,
          onNavigate: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

/// Small floating button to collapse/expand the desktop sidebar
class _CollapseButton extends StatelessWidget {
  final bool isDark;
  final bool isCollapsed;
  final bool isRtl;
  final VoidCallback onTap;

  const _CollapseButton({
    required this.isDark,
    required this.isCollapsed,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.primaryWhite,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isCollapsed
                ? (isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded)
                : (isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
            size: 20,
            color: isDark ? AppColors.textLight : AppColors.textMedium,
          ),
        ),
      ),
    );
  }
}
