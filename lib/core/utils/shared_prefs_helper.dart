import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for persisting app settings using SharedPreferences
class SharedPrefsHelper {
  static const String _themeKey = 'is_dark_mode';
  static const String _localeKey = 'app_locale';
  static const String _sidebarOpenKey = 'sidebar_open';
  static const String _selectedPageKey = 'selected_page';
  static const String _sidebarCollapsedKey = 'sidebar_collapsed';

  /// Initialize SharedPreferences (call once at app startup)
  static Future<SharedPreferences> init() async {
    return await SharedPreferences.getInstance();
  }

  // Theme persistence
  static Future<bool> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_themeKey, isDark);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  // Locale persistence
  static Future<bool> saveLocale(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_localeKey, localeCode);
  }

  static Future<String> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en';
  }

  // Sidebar state persistence
  static Future<bool> saveSidebarOpen(bool isOpen) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_sidebarOpenKey, isOpen);
  }

  static Future<bool> getSidebarOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sidebarOpenKey) ?? false;
  }

  // Selected page persistence
  static Future<bool> saveSelectedPage(int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(_selectedPageKey, pageIndex);
  }

  static Future<int> getSelectedPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_selectedPageKey) ?? 0;
  }

  // Sidebar collapsed state (for desktop)
  static Future<bool> saveSidebarCollapsed(bool isCollapsed) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_sidebarCollapsedKey, isCollapsed);
  }

  static Future<bool> getSidebarCollapsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sidebarCollapsedKey) ?? false;
  }
}
