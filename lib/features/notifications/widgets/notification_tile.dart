import 'package:flutter/material.dart';
import '../../../providers/notification/notification_provider.dart';
import '../../../core/constants/colors.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.isDark,
    this.onTap,
    this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'contribution_approved':
        return Icons.check_circle_rounded;
      case 'contribution_rejected':
        return Icons.cancel_rounded;
      case 'tokens':
        return Icons.token_rounded;
      case 'meeting_invite':
        return Icons.video_call_rounded;
      case 'subscription':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'contribution_approved':
        return Colors.green;
      case 'contribution_rejected':
        return Colors.red;
      case 'tokens':
        return Colors.amber;
      case 'meeting_invite':
        return Colors.purple;
      case 'subscription':
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryBlue;
    }
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

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white54 : Colors.black54;

    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: !notification.isRead
              ? _colorForType(notification.type).withValues(alpha: 0.08)
              : bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorForType(notification.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: _colorForType(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        Text(
                          _timeAgo(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
