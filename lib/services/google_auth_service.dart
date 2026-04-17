import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class GoogleAuthService {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<void> loginWithGoogle(String idToken) async {
    final response = await ApiService.dio.post(
      "/authentication/login/google/",
      data: {
        "token": idToken,
      },
    );

    // ✅ BACKEND RETURNS access & refresh DIRECTLY
    final access = response.data["access"];
    final refresh = response.data["refresh"];

    if (access == null || refresh == null) {
      throw Exception("Invalid backend response: tokens missing");
    }

    await _storage.write(key: "access", value: access);
    await _storage.write(key: "refresh", value: refresh);
  }
}
