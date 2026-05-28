import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/theme/app_theme_provider.dart';

/// Profile card displayed in the sidebar showing user avatar,
/// name, email, and role with an online status indicator.
/// Tappable — navigates to the profile page when tapped.
class ProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final bool isOnline;
  final bool isCollapsed;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.userName,
    this.userEmail = '',
    this.userRole = '',
    this.isOnline = true,
    this.isCollapsed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Container(
            padding: EdgeInsets.all(
              isCollapsed ? 8 : AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.sidebarActiveDark
                  : AppColors.sidebarActiveLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryBlueLight.withValues(alpha: 0.15)
                    : AppColors.primaryBlue.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: isCollapsed
                ? _CollapsedAvatar(userName: userName, isOnline: isOnline)
                : _ProfileContent(
                    userName: userName,
                    userEmail: userEmail,
                    userRole: userRole,
                    isOnline: isOnline,
                    isDark: isDark,
                  ),
          ),
        ),
      ),
    );
  }
}

class _CollapsedAvatar extends StatelessWidget {
  final String userName;
  final bool isOnline;
  const _CollapsedAvatar({required this.userName, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (isOnline) const _OnlineDot(dark: true),
      ],
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final bool isOnline;
  final bool isDark;

  const _ProfileContent({
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.isOnline,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (isOnline) _OnlineDot(dark: isDark),
          ],
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryWhite : AppColors.textDark,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (userEmail.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textLight : AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (userRole.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  userRole,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlueLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OnlineDot extends StatelessWidget {
  final bool dark;
  const _OnlineDot({required this.dark});

  @override
  Widget build(BuildContext context) {
    final bgColor = dark
        ? AppColors.sidebarActiveDark
        : AppColors.sidebarActiveLight;

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.onlineGreen,
          shape: BoxShape.circle,
          border: Border.all(color: bgColor, width: 2),
        ),
      ),
    );
  }
}
