import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';

/// Authentication state provider managing login/logout state
class AuthProvider extends ChangeNotifier {
  String? _userName;
  String? _firstName;
  String? _userEmail;
  String? _plan;
  bool _isOrg = false;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  String? get firstName => _firstName;
  String? get userEmail => _userEmail;
  String? get plan => _plan;
  bool get isOrg => _isOrg;
  bool get isLoggedIn => _isLoggedIn;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Initialize auth state from storage
  Future<void> init() async {
    _userName = await _storage.read(key: 'user_name');
    _firstName = await _storage.read(key: 'first_name');
    _userEmail = await _storage.read(key: 'user_email');
    _plan = await _storage.read(key: 'user_plan');
    _isOrg = (await _storage.read(key: 'is_org')) == 'true';

    const tokenStorage = FlutterSecureStorage();
    final accessToken = await tokenStorage.read(key: 'access');
    final refreshToken = await tokenStorage.read(key: 'refresh');

    final loggedInStr = await _storage.read(key: 'is_logged_in');
    if (loggedInStr == 'true' && (accessToken == null || refreshToken == null)) {
      await _clearAll();
      await AuthService.logout();
      notifyListeners();
      return;
    }

    _isLoggedIn = loggedInStr == 'true';

    // If logged in but plan is missing (e.g. first launch after update), fetch it
    if (_isLoggedIn && _plan == null) {
      try {
        final profile = await AuthService.getProfile();
        final fetchedPlan = profile['plan'] as String?;
        if (fetchedPlan != null) {
          _plan = fetchedPlan;
          await _storage.write(key: 'user_plan', value: fetchedPlan);
        }
      } catch (_) {
        // Silently fail; plan stays null (defaults to 'Free' in display)
      }
    }

    notifyListeners();
  }

  /// Login with user details
  Future<void> login({
    required String name,
    String? firstName,
    String? email,
    String? plan,
    bool org = false,
  }) async {
    _userName = name;
    _firstName = firstName ?? name;
    _userEmail = email;
    _plan = plan;
    _isOrg = org;
    _isLoggedIn = true;

    await _storage.write(key: 'is_logged_in', value: 'true');
    await _storage.write(key: 'user_name', value: name);
    if (firstName != null) await _storage.write(key: 'first_name', value: firstName);
    if (email != null) await _storage.write(key: 'user_email', value: email);
    if (plan != null) await _storage.write(key: 'user_plan', value: plan);
    await _storage.write(key: 'is_org', value: org ? 'true' : 'false');

    notifyListeners();
  }

  /// Logout and clear session
  Future<void> logout() async {
    await _clearAll();
    await AuthService.logout();
    notifyListeners();
  }

  Future<void> _clearAll() async {
    _userName = null;
    _firstName = null;
    _userEmail = null;
    _plan = null;
    _isOrg = false;
    _isLoggedIn = false;

    await _storage.delete(key: 'is_logged_in');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'first_name');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_plan');
    await _storage.delete(key: 'is_org');
  }

  /// Update user profile
  Future<void> updateProfile({String? name, String? firstName, String? email, String? plan}) async {
    if (name != null) _userName = name;
    if (firstName != null) _firstName = firstName;
    if (email != null) _userEmail = email;
    if (plan != null) _plan = plan;

    if (name != null) await _storage.write(key: 'user_name', value: name);
    if (firstName != null) await _storage.write(key: 'first_name', value: firstName);
    if (email != null) await _storage.write(key: 'user_email', value: email);
    if (plan != null) await _storage.write(key: 'user_plan', value: plan);

    notifyListeners();
  }
}
