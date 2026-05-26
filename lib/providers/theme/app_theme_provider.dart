import 'package:flutter/material.dart';
import '../../core/utils/shared_prefs_helper.dart';

/// Theme provider with persistence and smooth transitions
class AppThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;

  /// Initialize theme from persisted settings
  Future<void> init() async {
    _isDarkMode = await SharedPrefsHelper.getThemeMode();
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await SharedPrefsHelper.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  /// Set theme explicitly
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      await SharedPrefsHelper.saveThemeMode(isDark);
      notifyListeners();
    }
  }
}
