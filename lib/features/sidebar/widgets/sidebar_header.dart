import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../providers/locale/app_locale_provider.dart';

/// Premium sidebar header with animated logo and app name.
/// Displays a gradient logo with shadow, followed by the app name.
/// In collapsed mode, only the centered logo is shown.
class SidebarHeader extends StatelessWidget {
  /// Whether the sidebar is in collapsed state
  final bool isCollapsed;

  const SidebarHeader({super.key, this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final isRtl = context.watch<AppLocaleProvider>().isRtl;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : AppDimensions.spacingMd,
        vertical: AppDimensions.spacingMd,
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _LogoCard(isDark: isDark),
          if (!isCollapsed) ...[
            const SizedBox(width: AppDimensions.spacingSm),
            _AppNameText(isDark: isDark),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideX(
          begin: isRtl ? 0.15 : -0.15,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
  }
}

class _LogoCard extends StatelessWidget {
  final bool isDark;
  const _LogoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.translate_rounded,
        color: AppColors.textWhite,
        size: 22,
      ),
    );
  }
}

class _AppNameText extends StatelessWidget {
  final bool isDark;
  const _AppNameText({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'TAFAHOM',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}
