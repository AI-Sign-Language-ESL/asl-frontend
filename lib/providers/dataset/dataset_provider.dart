import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';

class DatasetProvider extends ChangeNotifier {
  int _totalContributions = 0;
  int _approvedContributions = 0;
  int _pendingContributions = 0;
  int _rejectedContributions = 0;
  bool _loading = false;

  int get totalContributions => _totalContributions;
  int get approvedContributions => _approvedContributions;
  int get pendingContributions => _pendingContributions;
  int get rejectedContributions => _rejectedContributions;
  bool get loading => _loading;

  Future<void> fetchContributions() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/api/v1/dataset/contributions/me/');
      final dynamic body = response.data;
      final List data;
      if (body is List) {
        data = body;
      } else if (body is Map && body['results'] is List) {
        data = body['results'] as List;
      } else {
        data = [];
      }
      _totalContributions = data.length;
      _approvedContributions = 0;
      _pendingContributions = 0;
      _rejectedContributions = 0;

      for (final item in data) {
        final status = item['status'] as String?;
        switch (status) {
          case 'approved':
            _approvedContributions++;
            break;
          case 'pending':
          case 'processing':
            _pendingContributions++;
            break;
          case 'rejected':
            _rejectedContributions++;
            break;
        }
      }

      debugPrint('[DatasetProvider] Contributions: $_totalContributions total, $_approvedContributions approved');
    } catch (e) {
      debugPrint('[DatasetProvider] Failed to fetch: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
