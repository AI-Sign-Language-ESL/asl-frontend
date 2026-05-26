import 'package:flutter/material.dart';
import '../../core/utils/shared_prefs_helper.dart';
import '../../core/constants/app_dimensions.dart';

/// Navigation state provider for tracking current page and transitions
class NavigationProvider extends ChangeNotifier {
  int _currentPageIndex = 0;
  bool _isTransitioning = false;

  int get currentPageIndex => _currentPageIndex;
  bool get isTransitioning => _isTransitioning;

  /// Initialize with persisted page
  Future<void> init() async {
    _currentPageIndex = await SharedPrefsHelper.getSelectedPage();
    notifyListeners();
  }

  /// Navigate to a page with animation
  Future<void> navigateTo(int index) async {
    if (_currentPageIndex == index || _isTransitioning) return;
    _isTransitioning = true;
    notifyListeners();

    await Future.delayed(
      const Duration(milliseconds: AppDimensions.animDurationShort),
    );

    _currentPageIndex = index;
    await SharedPrefsHelper.saveSelectedPage(index);
    _isTransitioning = false;
    notifyListeners();
  }

  /// Reset to home page
  void resetToHome() {
    _currentPageIndex = 0;
    notifyListeners();
  }
}
