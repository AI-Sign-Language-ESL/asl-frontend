import 'package:flutter/material.dart';
import '../theme/subscription_plan.dart';

class PlanBadge extends StatelessWidget {
  final String? plan;
  final bool showIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const PlanBadge({
    super.key,
    required this.plan,
    this.showIcon = true,
    this.fontSize = 13,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SubscriptionPlan.getGradientColors(plan);
    final isEnterprise = plan == SubscriptionPlan.enterprise;
    final name = SubscriptionPlan.displayName(plan);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: isEnterprise ? 0.5 : 0.35),
            blurRadius: isEnterprise ? 10 : 6,
            offset: Offset(0, isEnterprise ? 3 : 2),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: Row(
          key: ValueKey('${plan}_$showIcon'),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && isEnterprise)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: fontSize + 1,
                  color: Colors.white,
                ),
              ),
            if (showIcon && !isEnterprise)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.circle,
                  size: fontSize - 5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
