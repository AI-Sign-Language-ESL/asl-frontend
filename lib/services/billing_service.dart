import 'package:dio/dio.dart';
import 'package:tafahom_english_light/core/network/dio_client.dart';

class BillingService {
  final Dio _dio = DioClient().dio;

  // ---------------- PLANS ----------------
  Future<List<dynamic>> getPlans() async {
    final response = await _dio.get('/api/billing/plans/');
    return response.data;
  }

  // ---------------- MY SUBSCRIPTION ----------------
  Future<Map<String, dynamic>?> getMySubscription() async {
    final response = await _dio.get('/api/billing/my-subscription/');
    return response.data;
  }

  // ---------------- SUBSCRIBE ----------------
  Future<void> subscribe(int planId) async {
    await _dio.post(
      '/api/billing/subscribe/',
      data: {
        "plan_id": planId,
      },
    );
  }

  // ---------------- CANCEL ----------------
  Future<void> cancelSubscription() async {
    await _dio.post('/api/billing/cancel/');
  }
}
