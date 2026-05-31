import 'package:flutter/material.dart';

import '../models/welcome_data.dart';

class WelcomeActionCard extends StatelessWidget {
  final ActionCard card;
  final void Function(ActionButton button)? onButtonAction;

  const WelcomeActionCard({
    super.key,
    required this.card,
    this.onButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: textSecondary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_resolveIcon(card.icon), color: _iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (card.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        card.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (card.buttons.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: card.buttons.map((btn) => _buildButton(context, btn)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, ActionButton button) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;

    if (button.actionType.contains('upgrade') || button.actionType.contains('basic')) {
      bgColor = const Color(0xFF275878);
      fgColor = Colors.white;
    } else if (button.actionType.contains('join') || button.actionType.contains('positive')) {
      bgColor = const Color(0xFF10B981);
      fgColor = Colors.white;
    } else {
      bgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
      fgColor = isDark ? Colors.white : const Color(0xFF275878);
    }

    return ElevatedButton(
      onPressed: () => _handleAction(context, button),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(button.label),
    );
  }

  void _handleAction(BuildContext context, ActionButton button) {
    onButtonAction?.call(button);
  }

  Color get _iconColor {
    switch (card.icon) {
      case 'meeting':
        return const Color(0xFF7C3AED);
      case 'upgrade':
      case 'premium':
        return const Color(0xFFD97706);
      case 'lesson':
      case 'learning':
        return const Color(0xFF2563EB);
      case 'translator':
        return const Color(0xFF059669);
      case 'support':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF275878);
    }
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'meeting':
        return Icons.video_call_rounded;
      case 'upgrade':
      case 'premium':
        return Icons.workspace_premium_rounded;
      case 'lesson':
      case 'learning':
        return Icons.school_rounded;
      case 'translator':
        return Icons.translate_rounded;
      case 'support':
        return Icons.support_agent_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      case 'help':
        return Icons.help_outline_rounded;
      default:
        return Icons.circle_rounded;
    }
  }
}
