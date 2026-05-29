import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';

class TokenProvider extends ChangeNotifier {
  int _totalTokens = 0;
  int _tokensUsed = 0;
  int _bonusTokens = 0;
  int _remainingTokens = 0;
  int _weeklyLimit = 50;
  bool _loading = false;

  int get totalTokens => _totalTokens;
  int get tokensUsed => _tokensUsed;
  int get bonusTokens => _bonusTokens;
  int get remainingTokens => _remainingTokens;
  int get weeklyLimit => _weeklyLimit;
  bool get loading => _loading;
  double get usageRatio => _weeklyLimit > 0 ? (_tokensUsed / _weeklyLimit).clamp(0.0, 1.0) : 0.0;

  Future<void> fetchBalance() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/api/v1/billing/me/tokens/');
      final data = response.data as Map<String, dynamic>;
      _totalTokens = data['total_tokens'] as int? ?? 0;
      _tokensUsed = data['tokens_used'] as int? ?? 0;
      _bonusTokens = data['bonus_tokens'] as int? ?? 0;
      _remainingTokens = data['remaining_tokens'] as int? ?? 0;
      _weeklyLimit = data['weekly_tokens_limit'] as int? ?? 50;
      debugPrint('[TokenProvider] Balance fetched: $_remainingTokens remaining');
    } catch (e) {
      debugPrint('[TokenProvider] Failed to fetch balance: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
