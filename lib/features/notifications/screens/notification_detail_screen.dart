import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/notification/notification_provider.dart';
import '../../../core/constants/colors.dart';

class NotificationDetailScreen extends StatelessWidget {
  final int notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notif = notificationProvider.notifications.firstWhere(
      (n) => n.id == notificationId,
    );

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;

    IconData icon;
    Color iconColor;
    switch (notif.type) {
      case 'contribution_approved':
        icon = Icons.check_circle_rounded;
        iconColor = Colors.green;
        break;
      case 'contribution_rejected':
        icon = Icons.cancel_rounded;
        iconColor = Colors.red;
        break;
      case 'contribution_submitted':
        icon = Icons.cloud_upload_rounded;
        iconColor = AppColors.primaryBlue;
        break;
      case 'tokens':
        icon = Icons.token_rounded;
        iconColor = Colors.amber;
        break;
      case 'meeting_invite':
        icon = Icons.video_call_rounded;
        iconColor = Colors.purple;
        break;
      case 'subscription':
        icon = Icons.workspace_premium_rounded;
        iconColor = AppColors.primaryBlue;
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primaryBlue;
    }

    String _timeAgo(String isoDate) {
      try {
        final dt = DateTime.parse(isoDate);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        if (diff.inDays < 7) return '${diff.inDays}d ago';
        return '${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        return '';
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              notif.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _timeAgo(notif.createdAt),
              style: TextStyle(fontSize: 13, color: subtitleColor),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notif.message,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
