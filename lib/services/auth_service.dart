// lib/auth/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tafahom_english_light/core/network/dio_client.dart';

class LoginResult {
  final bool requires2FA;
  final String? tempToken;

  LoginResult({
    required this.requires2FA,
    this.tempToken,
  });
}

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ---------------- LOGIN ----------------
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      "/auth/login/",
      data: {
        "email": email,
        "password": password,
      },
    );

    // 🔐 2FA required
    if (response.data["requires_2fa"] == true) {
      return LoginResult(
        requires2FA: true,
        tempToken: response.data["temp_token"],
      );
    }

    // ✅ Normal login
    await _storage.write(
      key: "access_token",
      value: response.data["access"],
    );
    await _storage.write(
      key: "refresh_token",
      value: response.data["refresh"],
    );

    return LoginResult(requires2FA: false);
  }

  // ---------------- LOGIN WITH 2FA ----------------
  Future<void> loginWith2FA({
    required String tempToken,
    required String otp,
  }) async {
    final response = await _dio.post(
      "/auth/login/2fa/",
      data: {
        "temp_token": tempToken,
        "otp": otp,
      },
    );

    await _storage.write(
      key: "access_token",
      value: response.data["access"],
    );
    await _storage.write(
      key: "refresh_token",
      value: response.data["refresh"],
    );
  }

  // ---------------- PASSWORD RESET (REQUEST) ----------------
  Future<void> requestPasswordReset({
    required String email,
  }) async {
    await _dio.post(
      "/auth/security/password/reset/request/",
      data: {
        "email": email,
      },
    );
  }

  // ---------------- PASSWORD RESET (CONFIRM) ----------------
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _dio.post(
      "/auth/security/password/reset/confirm/",
      data: {
        "token": token,
        "new_password": newPassword,
      },
    );
  }

  // ---------------- USER SIGNUP ----------------
  Future<void> registerUser(Map<String, dynamic> data) async {
    await _dio.post("/auth/register/basic/", data: data);
  }

  // ---------------- ORGANIZATION SIGNUP ----------------
  Future<void> registerOrganization(Map<String, dynamic> data) async {
    await _dio.post("/auth/register/organization/", data: data);
  }

  // ---------------- PROFILE ----------------
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get("/auth/me/");
    return response.data;
  }

  // ---------------- LOGOUT ----------------
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
