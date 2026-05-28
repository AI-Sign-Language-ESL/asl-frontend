import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../providers/locale/app_locale_provider.dart';
import '../../../providers/sidebar/sidebar_provider.dart';
import '../../../providers/sidebar/navigation_provider.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'sidebar_header.dart';
import 'profile_card.dart';
import 'animated_nav_tile.dart';
import 'sidebar_footer.dart';

/// Menu item data model for sidebar navigation entries
class SidebarMenuItem {
  final IconData icon;
  final String label;
  final int index;

  const SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

/// Premium sidebar with glassmorphism, animations, and full RTL support.
///
/// Combines [SidebarHeader], [ProfileCard], animated nav tiles,
/// and [SidebarFooter] into a cohesive navigation component.
class PremiumSidebar extends StatefulWidget {
  final VoidCallback? onLogoutConfirmed;
  final VoidCallback? onNavigate;

  const PremiumSidebar({super.key, this.onLogoutConfirmed, this.onNavigate});

  @override
  State<PremiumSidebar> createState() => _PremiumSidebarState();
}

class _PremiumSidebarState extends State<PremiumSidebar> {
  void _handleLogout(BuildContext context) {
    final local = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        title: Text(
          local?.logOut ?? 'Logout',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthProvider>().logout();
              widget.onLogoutConfirmed?.call();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  List<SidebarMenuItem> _getMenuItems(BuildContext context) {
    final local = AppLocalizations.of(context);
    return [
      SidebarMenuItem(icon: Icons.home_rounded, label: local?.home ?? 'Home', index: 0),
      SidebarMenuItem(icon: Icons.translate_rounded, label: local?.textToSign ?? 'Text to Sign', index: 1),
      SidebarMenuItem(icon: Icons.sign_language_rounded, label: local?.signToText ?? 'Sign to Text', index: 2),
      SidebarMenuItem(icon: Icons.cloud_upload_rounded, label: local?.contributeDataset ?? 'Contribute to Dataset', index: 3),
      SidebarMenuItem(icon: Icons.workspace_premium_rounded, label: local?.subscription ?? 'Subscriptions', index: 4),
      SidebarMenuItem(icon: Icons.person_rounded, label: local?.profile ?? 'Profile', index: 5),
      SidebarMenuItem(icon: Icons.settings_rounded, label: local?.settings ?? 'Settings', index: 6),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final isCollapsed = context.watch<SidebarProvider>().isCollapsed;
    final currentPageIndex = context.watch<NavigationProvider>().currentPageIndex;
    final authProvider = context.watch<AuthProvider>();
    final isRtl = context.watch<AppLocaleProvider>().isRtl;
    final themeProvider = context.watch<AppThemeProvider>();
    final menuItems = _getMenuItems(context);

    return Container(
      width: isCollapsed
          ? AppDimensions.sidebarCollapsedWidth
          : AppDimensions.sidebarWidth,
      decoration: BoxDecoration(
        color: isDark ? AppColors.sidebarBgDark : AppColors.sidebarBgLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          /// App header with logo + name
          SidebarHeader(isCollapsed: isCollapsed),
          const SizedBox(height: AppDimensions.spacingMd),

          /// User profile card
          ProfileCard(
            userName: authProvider.userName ?? 'Guest',
            userEmail: authProvider.userEmail ?? '',
            userRole: authProvider.isOrg ? 'Organization' : 'User',
            isOnline: authProvider.isLoggedIn,
            isCollapsed: isCollapsed,
            onTap: () {
              if (!authProvider.isLoggedIn) {
                widget.onNavigate?.call();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
                return;
              }
              context.read<NavigationProvider>().navigateTo(5);
              widget.onNavigate?.call();
            },
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          /// Separator
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
              child: Divider(
                color: isDark ? AppColors.sidebarDividerDark : AppColors.sidebarDivider,
                height: 1,
              ),
            ),
          const SizedBox(height: AppDimensions.spacingSm),

          /// Menu items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return AnimatedNavTile(
                  key: ValueKey(item.index),
                  icon: item.icon,
                  label: item.label,
                  isSelected: currentPageIndex == item.index,
                  isCollapsed: isCollapsed,
                  onTap: () {
                    if (item.index == 5 && !authProvider.isLoggedIn) {
                      widget.onNavigate?.call();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                      return;
                    }
                    context.read<NavigationProvider>().navigateTo(item.index);
                    widget.onNavigate?.call();
                  },
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 50),
                      duration: const Duration(milliseconds: 200),
                    )
                    .slideX(
                      begin: isRtl ? 0.12 : -0.12,
                      end: 0,
                      delay: Duration(milliseconds: index * 50),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                    );
              },
            ),
          ),

          /// Footer with theme toggle + logout
          SidebarFooter(
            isCollapsed: isCollapsed,
            onThemeToggle: themeProvider.toggleTheme,
            onLogout: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}
