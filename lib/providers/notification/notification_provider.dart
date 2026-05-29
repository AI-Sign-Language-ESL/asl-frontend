import 'package:flutter/foundation.dart';
import '../../services/api_service.dart';

class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? actionUrl;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.actionUrl,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      isRead: json['read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _loading = false;

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      final response = await ApiService.dio.get('/api/v1/notifications/');
      final data = response.data as List;
      _notifications = data.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('[NotificationProvider] Fetched ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to fetch: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await ApiService.dio.post('/api/v1/notifications/$id/read/');
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        final old = _notifications[idx];
        _notifications[idx] = AppNotification(
          id: old.id,
          type: old.type,
          title: old.title,
          message: old.message,
          isRead: true,
          actionUrl: old.actionUrl,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark $id as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.dio.post('/api/v1/notifications/read-all/');
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id,
        type: n.type,
        title: n.title,
        message: n.message,
        isRead: true,
        actionUrl: n.actionUrl,
        createdAt: n.createdAt,
      )).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to mark all as read: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await ApiService.dio.delete('/api/v1/notifications/$id/delete/');
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationProvider] Failed to delete $id: $e');
    }
  }
}
