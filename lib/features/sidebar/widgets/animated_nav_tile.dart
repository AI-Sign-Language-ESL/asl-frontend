import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Premium navigation tile with animated active indicator,
/// smooth hover effects, ripple animation, and rounded backgrounds.
///
/// Features:
/// - Animated left/right indicator bar (position adapts to RTL)
/// - Scale animation on selection
/// - Hover state with subtle background tint
/// - Rounded active background with glassmorphism feel
class AnimatedNavTile extends StatefulWidget {
  /// Icon displayed on the tile
  final IconData icon;

  /// Label text
  final String label;

  /// Whether this tile is currently selected
  final bool isSelected;

  /// Whether the sidebar is collapsed (icon only)
  final bool isCollapsed;

  /// Custom active color (defaults to primary blue)
  final Color? activeColor;

  /// Callback when tile is tapped
  final VoidCallback onTap;

  const AnimatedNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCollapsed = false,
    this.activeColor,
  });

  @override
  State<AnimatedNavTile> createState() => _AnimatedNavTileState();
}

class _AnimatedNavTileState extends State<AnimatedNavTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final activeColor = widget.activeColor ?? AppColors.primaryBlue;

    final bgColor = _computeBackground(activeColor);
    final iconColor = _computeIconColor(activeColor);
    final textColor = _computeTextColor(activeColor);
    final fontWeight = widget.isSelected ? FontWeight.w600 : FontWeight.w500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: AppDimensions.animDurationNormal),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 8 : AppDimensions.spacingMd,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovered) => setState(() => _isHovered = hovered),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          splashColor: activeColor.withValues(alpha: 0.12),
          highlightColor: activeColor.withValues(alpha: 0.06),
          child: Container(
            height: AppDimensions.sidebarItemHeight,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Stack(
              children: [
                /// Animated indicator bar (slides in/out)
                _AnimatedIndicator(
                  isActive: widget.isSelected,
                  isRtl: isRtl,
                  color: activeColor,
                ),
                /// Icon + label
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed
                        ? 0
                        : AppDimensions.spacingMd,
                    vertical: AppDimensions.spacingSm,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.isCollapsed
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        widget.icon,
                        size: AppDimensions.sidebarIconSize,
                        color: iconColor,
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: fontWeight,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(target: widget.isSelected ? 1 : 0).scale(
          begin: const Offset(0.97, 1),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
  }

  Color _computeBackground(Color activeColor) {
    if (widget.isSelected) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.dark
          ? AppColors.sidebarActiveDark
          : AppColors.sidebarActiveLight;
    }
    if (_isHovered) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03);
    }
    return Colors.transparent;
  }

  Color _computeIconColor(Color activeColor) {
    if (widget.isSelected) return activeColor;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textLight
        : AppColors.textMedium;
  }

  Color _computeTextColor(Color activeColor) {
    if (widget.isSelected) return activeColor;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColors.textLight
        : AppColors.textMedium;
  }
}

/// Animated indicator bar that slides in when active
class _AnimatedIndicator extends StatelessWidget {
  final bool isActive;
  final bool isRtl;
  final Color color;

  const _AnimatedIndicator({
    required this.isActive,
    required this.isRtl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: AppDimensions.animDurationNormal),
      curve: Curves.easeOutCubic,
      left: isRtl ? null : (isActive ? 0 : -4),
      right: isRtl ? (isActive ? 0 : -4) : null,
      top: 10,
      bottom: 10,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: AppDimensions.animDurationNormal),
        opacity: isActive ? 1.0 : 0.0,
        child: Container(
          width: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.horizontal(
              left: isRtl ? Radius.zero : const Radius.circular(4),
              right: isRtl ? const Radius.circular(4) : Radius.zero,
            ),
          ),
        ),
      ),
    );
  }
}
