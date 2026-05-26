import 'package:flutter/material.dart';
import '../../core/utils/shared_prefs_helper.dart';
import '../../core/constants/app_dimensions.dart';

/// Sidebar state provider managing open/collapse state
class SidebarProvider extends ChangeNotifier {
  bool _isOpen = false;
  bool _isCollapsed = false;
  bool _isAnimating = false;

  bool get isOpen => _isOpen;
  bool get isCollapsed => _isCollapsed;
  bool get isAnimating => _isAnimating;

  double get sidebarWidth {
    if (_isCollapsed) return AppDimensions.sidebarCollapsedWidth;
    return AppDimensions.sidebarWidth;
  }

  /// Initialize sidebar state from persisted settings
  Future<void> init() async {
    _isCollapsed = await SharedPrefsHelper.getSidebarCollapsed();
    notifyListeners();
  }

  /// Toggle sidebar open/close (for mobile)
  Future<void> toggle() async {
    if (_isAnimating) return;
    _isAnimating = true;
    _isOpen = !_isOpen;
    notifyListeners();

    await Future.delayed(
      const Duration(milliseconds: AppDimensions.animDurationNormal),
    );
    _isAnimating = false;
    notifyListeners();
  }

  /// Open sidebar
  void open() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  /// Close sidebar
  void close() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  /// Toggle collapsed state (for desktop)
  Future<void> toggleCollapse() async {
    _isCollapsed = !_isCollapsed;
    await SharedPrefsHelper.saveSidebarCollapsed(_isCollapsed);
    notifyListeners();
  }

  /// Set collapsed state explicitly
  Future<void> setCollapsed(bool value) async {
    if (_isCollapsed != value) {
      _isCollapsed = value;
      await SharedPrefsHelper.saveSidebarCollapsed(value);
      notifyListeners();
    }
  }
}
