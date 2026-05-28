import 'package:flutter/material.dart';

/// Clean, modern hamburger menu button with subtle background.
class ModernHamburgerIcon extends StatelessWidget {
  final Color? color;
  final double size;
  final VoidCallback onTap;

  const ModernHamburgerIcon({
    super.key,
    this.color,
    this.size = 28,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).iconTheme.color ?? Colors.black;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.menu_rounded, color: iconColor, size: size),
        ),
      ),
    );
  }
}
