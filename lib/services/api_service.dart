import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static late Dio dio;

  // ✅ Tokens
  static String? accessToken;
  static String? refreshToken;

  // ✅ INIT (call this once in main.dart)
  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://tafahom.io", // ✅ IMPORTANT
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    // ✅ INTERCEPTOR (AUTO ADD TOKEN)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (accessToken != null) {
            options.headers["Authorization"] = "Bearer $accessToken";
          }

          return handler.next(options);
        },

        // ✅ OPTIONAL: HANDLE 401 (future upgrade)
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // You can implement refresh token logic here later
            print("Unauthorized → token may be expired");
          }
          return handler.next(error);
        },
      ),
    );

    // ✅ OPTIONAL: LOGGING (REMOVE IN PRODUCTION)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  // =========================
  // ✅ AUTH HELPERS
  // =========================

  static void setTokens({
    required String access,
    required String refresh,
  }) {
    accessToken = access;
    refreshToken = refresh;
  }

  static void clearTokens() {
    accessToken = null;
    refreshToken = null;
  }

  static Future<void> loadTokensFromStorage() async {
    const storage = FlutterSecureStorage();
    accessToken = await storage.read(key: "access");
    refreshToken = await storage.read(key: "refresh");
  }
}