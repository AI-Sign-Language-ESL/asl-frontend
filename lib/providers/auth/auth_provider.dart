import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';

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

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Initialize auth state from storage
  Future<void> init() async {
    _userName = await _storage.read(key: 'user_name');
    _userEmail = await _storage.read(key: 'user_email');
    _isOrg = (await _storage.read(key: 'is_org')) == 'true';

    const tokenStorage = FlutterSecureStorage();
    final accessToken = await tokenStorage.read(key: 'access');
    final refreshToken = await tokenStorage.read(key: 'refresh');

    final loggedInStr = await _storage.read(key: 'is_logged_in');
    if (loggedInStr == 'true' && (accessToken == null || refreshToken == null)) {
      _userName = null;
      _userEmail = null;
      _isOrg = false;
      _isLoggedIn = false;
      await _storage.delete(key: 'is_logged_in');
      await _storage.delete(key: 'user_name');
      await _storage.delete(key: 'user_email');
      await _storage.delete(key: 'is_org');
      await AuthService.logout();
      notifyListeners();
      return;
    }

    _isLoggedIn = loggedInStr == 'true';
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

    await _storage.write(key: 'is_logged_in', value: 'true');
    await _storage.write(key: 'user_name', value: name);
    if (email != null) await _storage.write(key: 'user_email', value: email);
    await _storage.write(key: 'is_org', value: org ? 'true' : 'false');

    notifyListeners();
  }

  /// Logout and clear session
  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    _isOrg = false;
    _isLoggedIn = false;

    await _storage.delete(key: 'is_logged_in');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'is_org');

    // Make sure we also clear tokens via AuthService
    await AuthService.logout();

    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? email}) async {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;

    if (name != null) await _storage.write(key: 'user_name', value: name);
    if (email != null) await _storage.write(key: 'user_email', value: email);

    notifyListeners();
  }
}
