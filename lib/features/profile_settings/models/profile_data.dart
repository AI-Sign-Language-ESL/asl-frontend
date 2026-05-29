import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final String memberSince;
  final String plan;

  const UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarUrl = '',
    this.role = '',
    this.memberSince = '',
    this.plan = '',
  });
}

class Activity {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;

  const Activity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
  });
}

class StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double change;

  const StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.change = 0.0,
  });
}

class DashboardColors {
  DashboardColors._();

  static const Color background = Color(0xFFF5F7FA);
  static const Color cardBackground = Colors.white;
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color gradientStart = Color(0xFF3B82F6);
  static const Color gradientEnd = Color(0xFF2563EB);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkSurface = Color(0xFF0F172A);
}
