import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  // =====================================================
  // 🌍 BASE URLS
  // =====================================================
  static const String authBaseUrl =
      "https://tafahom.io/api/v1/authentication";
  static const String usersBaseUrl =
      "https://tafahom.io/api/v1/users";

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const Map<String, String> _jsonHeaders = {
    "Content-Type": "application/json",
  };

  // =====================================================
  // 🔐 LOGIN
  // =====================================================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$authBaseUrl/login/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = _decode(response);

    if (response.statusCode != 200) {
      throw data["detail"] ?? data.toString();
    }

    // 2FA case
    if (data["requires_2fa"] == true) {
      return data;
    }

    await _saveTokens(
      access: data["access"],
      refresh: data["refresh"],
    );

    return data;
  }

  // =====================================================
  // 🔐 LOGIN WITH 2FA
  // =====================================================
  static Future<Map<String, dynamic>> login2FA({
    required int userId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse("$authBaseUrl/login-2fa/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "user_id": userId,
        "token": token,
      }),
    );

    final data = _decode(response);

    if (response.statusCode != 200) {
      throw data["detail"] ?? "2FA failed";
    }

    await _saveTokens(
      access: data["access"],
      refresh: data["refresh"],
    );

    return data;
  }

  // =====================================================
  // 🌐 GOOGLE AUTH
  // =====================================================
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse("$authBaseUrl/login/google/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "id_token": idToken,
      }),
    );

    final data = _decode(response);

    if (response.statusCode != 200) {
      throw data["detail"] ?? "Google auth failed";
    }

    await _saveTokens(
      access: data["access"],
      refresh: data["refresh"],
    );

    return data;
  }

  // =====================================================
  // 🔄 REFRESH TOKEN
  // =====================================================
  static Future<String?> refreshAccessToken() async {
    final refresh = await _storage.read(key: "refresh");
    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse("$authBaseUrl/token/refresh/"),
      headers: _jsonHeaders,
      body: jsonEncode({"refresh": refresh}),
    );

    if (response.statusCode != 200) {
      await logout();
      return null;
    }

    final data = _decode(response);
    await _storage.write(key: "access", value: data["access"]);

    // ✅ ALSO UPDATE ApiService TOKEN
    ApiService.accessToken = data["access"];

    return data["access"];
  }

  // =====================================================
  // 👤 PROFILE
  // =====================================================
  static Future<Map<String, dynamic>> getProfile() async {
    final access = await _storage.read(key: "access");

    if (access == null) {
      throw "Not authenticated";
    }

    final response = await http.get(
      Uri.parse("$usersBaseUrl/me/"),
      headers: {
        ..._jsonHeaders,
        "Authorization": "Bearer $access",
      },
    );

    if (response.statusCode == 401) {
      final newAccess = await refreshAccessToken();
      if (newAccess == null) throw "Session expired";
      return getProfile();
    }

    if (response.statusCode != 200) {
      throw "Failed to load profile";
    }

    return _decode(response);
  }

  // =====================================================
  // 👤 REGISTER USER
  // =====================================================
  static Future<Map<String, dynamic>> registerBasicUser({
    required String username,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$usersBaseUrl/register/basic/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "username": username,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      }),
    );

    final data = _decode(response);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw data["detail"] ?? data.toString();
    }

    return data;
  }

  // =====================================================
  // 🏢 REGISTER ORGANIZATION
  // =====================================================
  static Future<Map<String, dynamic>> registerOrganization({
    required String username,
    required String firstName,
    required String lastName,
    required String organizationName,
    required String activity,
    required String email,
    required String password,
    String? jobTitle,
  }) async {
    final response = await http.post(
      Uri.parse("$usersBaseUrl/register/organization/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "username": username,
        "first_name": firstName,
        "last_name": lastName,
        "organization_name": organizationName,
        "activity_type": activity,
        "job_title": jobTitle ?? "",
        "email": email,
        "password": password,
      }),
    );

    final data = _decode(response);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw data["detail"] ?? data.toString();
    }

    return data;
  }

  // =====================================================
  // 🔑 PASSWORD RESET
  // =====================================================
  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse("$authBaseUrl/password/reset/"),
      headers: _jsonHeaders,
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      throw "Failed to send reset email";
    }
  }

  static Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$authBaseUrl/password/reset/confirm/"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "token": token,
        "new_password": newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw "Password reset failed";
    }
  }

  // =====================================================
  // 🚪 LOGOUT
  // =====================================================
  static Future<void> logout() async {
    await _storage.deleteAll();

    // ✅ CLEAR ApiService TOKEN
    ApiService.clearTokens();
  }

  // =====================================================
  // 🔐 TOKEN STORAGE (🔥 ONLY CHANGE HERE)
  // =====================================================
  static Future<void> _saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: "access", value: access);
    await _storage.write(key: "refresh", value: refresh);

    // ✅ THIS IS THE FIX (CONNECT TO DIO)
    ApiService.setTokens(access: access, refresh: refresh);
  }

  // =====================================================
  // 🧩 JSON DECODER
  // =====================================================
  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    return jsonDecode(utf8.decode(response.bodyBytes))
        as Map<String, dynamic>;
  }
}