import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication state provider managing login/logout state
class AuthProvider extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isOrg = false;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isOrg => _isOrg;
  bool get isLoggedIn => _isLoggedIn;

  /// Initialize auth state from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _isOrg = prefs.getBool('is_org') ?? false;
    notifyListeners();
  }

  /// Login with user details
  Future<void> login({
    required String name,
    String? email,
    bool org = false,
  }) async {
    _userName = name;
    _userEmail = email;
    _isOrg = org;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);
    await prefs.setBool('is_org', org);

    notifyListeners();
  }

  /// Logout and clear session
  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    _isOrg = false;
    _isLoggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('is_org');

    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    if (name != null) await prefs.setString('user_name', name);
    if (email != null) await prefs.setString('user_email', email);

    notifyListeners();
  }
}
