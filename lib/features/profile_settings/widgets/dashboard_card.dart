import 'package:flutter/material.dart';
import '../models/profile_data.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool isDark;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? DashboardColors.darkCard : Colors.white;
    final border = isDark
        ? DashboardColors.darkBorder.withValues(alpha: 0.5)
        : DashboardColors.border.withValues(alpha: 0.5);

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
