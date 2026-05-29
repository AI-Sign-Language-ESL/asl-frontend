import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification/notification_provider.dart';
import '../widgets/notification_tile.dart';
import '../../../core/constants/colors.dart';

class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const NotificationsScreen({super.key, this.onMenuTap});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => notificationProvider.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        size: 64,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => notificationProvider.fetchNotifications(),
                  child: ListView.separated(
                    itemCount: notificationProvider.notifications.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    itemBuilder: (context, index) {
                      final notif = notificationProvider.notifications[index];
                      return NotificationTile(
                        notification: notif,
                        isDark: isDark,
                        onTap: () {
                          if (!notif.isRead) {
                            notificationProvider.markAsRead(notif.id);
                          }
                        },
                        onDelete: () =>
                            notificationProvider.delete(notif.id),
                      );
                    },
                  ),
                ),
    );
  }
}
