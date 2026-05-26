import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../providers/locale/app_locale_provider.dart';

/// Sidebar footer containing theme toggle switch and logout button.
/// Fixed at the bottom of the sidebar with a top divider separator.
class SidebarFooter extends StatelessWidget {
  /// Callback when logout is tapped
  final VoidCallback onLogout;

  /// Callback when theme toggle is tapped (null to hide toggle)
  final VoidCallback? onThemeToggle;

  /// Whether the sidebar is collapsed
  final bool isCollapsed;

  const SidebarFooter({
    super.key,
    required this.onLogout,
    this.onThemeToggle,
    this.isCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final isRtl = context.watch<AppLocaleProvider>().isRtl;
    final themeProvider = context.watch<AppThemeProvider>();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.sidebarDividerDark : AppColors.sidebarDivider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Theme toggle row
          if (onThemeToggle != null && !isCollapsed)
            _ThemeToggleRow(
              isDark: isDark,
              isRtl: isRtl,
              onTap: themeProvider.toggleTheme,
            ),

          if (onThemeToggle != null && !isCollapsed)
            const SizedBox(height: AppDimensions.spacingSm),

          /// Logout button
          _LogoutButton(
            isDark: isDark,
            isCollapsed: isCollapsed,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleRow extends StatelessWidget {
  final bool isDark;
  final bool isRtl;
  final VoidCallback onTap;

  const _ThemeToggleRow({
    required this.isDark,
    required this.isRtl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          height: AppDimensions.sidebarItemHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Row(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: AppDimensions.sidebarIconSize,
                color: isDark ? AppColors.accentYellow : AppColors.textMedium,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                isDark ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textLight : AppColors.textMedium,
                ),
              ),
              const Spacer(),
              _ToggleSwitch(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  final bool isDark;
  const _ToggleSwitch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryBlueLight : AppColors.sidebarDivider,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            left: isDark ? 2 : 22,
            right: isDark ? 22 : 2,
            top: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isDark;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.isDark,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          height: AppDimensions.sidebarItemHeight,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : AppDimensions.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.accentRed.withOpacity(0.15)
                : AppColors.accentRed.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                Icons.logout_rounded,
                size: AppDimensions.sidebarIconSize,
                color: AppColors.accentRed,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: AppDimensions.spacingMd),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentRed,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
