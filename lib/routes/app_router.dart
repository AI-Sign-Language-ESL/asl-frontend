import 'package:flutter/material.dart';
import '../features/sidebar/widgets/app_shell.dart';

/// App routes configuration using GoRouter
/// Provides clean URL-based navigation with smooth transitions
class AppRouter {
  /// Get the initial route based on auth state
  static String getInitialRoute(bool isLoggedIn) {
    return isLoggedIn ? '/home' : '/login';
  }

  /// Navigate to a specific page index via the AppShell
  static void navigateToPage(BuildContext context, int pageIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppShell(
            key: ValueKey(pageIndex),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
