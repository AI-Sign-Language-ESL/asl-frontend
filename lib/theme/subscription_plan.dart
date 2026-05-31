import 'package:flutter/material.dart';

class SubscriptionPlan {
  SubscriptionPlan._();

  static const String free = 'free';
  static const String basic = 'basic';
  static const String go = 'go';
  static const String enterprise = 'enterprise';
  static const String premium = 'premium';

  static const Color freeColor = Color(0xFF22C55E);
  static const Color basicColor = Color(0xFF3B82F6);
  static const Color goColor = Color(0xFF8B5CF6);
  static const Color enterpriseColor = Color(0xFFF59E0B);
  static const Color premiumColor = Color(0xFFF59E0B);

  static const Color freeGradientEnd = Color(0xFF16A34A);
  static const Color basicGradientEnd = Color(0xFF2563EB);
  static const Color goGradientEnd = Color(0xFF7C3AED);
  static const Color enterpriseGradientEnd = Color(0xFFD97706);
  static const Color premiumGradientEnd = Color(0xFFD97706);

  static const List<Color> freeGradientColors = [freeColor, freeGradientEnd];
  static const List<Color> basicGradientColors = [basicColor, basicGradientEnd];
  static const List<Color> goGradientColors = [goColor, goGradientEnd];
  static const List<Color> enterpriseGradientColors = [enterpriseColor, enterpriseGradientEnd];
  static const List<Color> premiumGradientColors = [premiumColor, premiumGradientEnd];

  static Color getColor(String? plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return freeColor;
      case SubscriptionPlan.basic:
        return basicColor;
      case SubscriptionPlan.go:
        return goColor;
      case SubscriptionPlan.enterprise:
      case SubscriptionPlan.premium:
        return enterpriseColor;
      default:
        return freeColor;
    }
  }

  static List<Color> getGradientColors(String? plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return freeGradientColors;
      case SubscriptionPlan.basic:
        return basicGradientColors;
      case SubscriptionPlan.go:
        return goGradientColors;
      case SubscriptionPlan.enterprise:
      case SubscriptionPlan.premium:
        return enterpriseGradientColors;
      default:
        return freeGradientColors;
    }
  }

  static LinearGradient getGradient(String? plan) {
    return LinearGradient(
      colors: getGradientColors(plan),
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static String displayName(String? plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.go:
        return 'GO';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
      case SubscriptionPlan.premium:
        return 'Premium';
      default:
        return 'Free';
    }
  }

  static bool shouldShowUpgrade(String? plan) {
    return plan == null || plan == SubscriptionPlan.free || plan == SubscriptionPlan.basic;
  }

  static String? nextPlanName(String? plan) {
    if (plan == null || plan == SubscriptionPlan.free) return 'Basic';
    if (plan == SubscriptionPlan.basic) return 'GO';
    return null;
  }
}
