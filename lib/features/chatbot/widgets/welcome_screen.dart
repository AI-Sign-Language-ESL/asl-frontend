import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';

import '../models/welcome_data.dart';
import '../providers/chat_provider.dart';
import 'welcome_action_card.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _handleQuickAction(BuildContext context, QuickAction action) {
    switch (action.actionType) {
      case 'navigate':
        _handleNavigation(context, action.payload);
        break;
      case 'send_message':
        context.read<ChatProvider>().sendMessage(action.title);
        break;
      case 'open_url':
        if (action.payload != null) {
          _openUrl(context, action.payload!);
        }
        break;
    }
  }

  void _handleNavigation(BuildContext context, String? destination) {
    final route = destination?.replaceAll(RegExp(r'^/'), '');
    switch (route) {
      case 'text-to-sign':
        Navigator.pushNamed(context, '/text-to-sign');
        break;
      case 'sign-to-text':
        Navigator.pushNamed(context, '/sign-to-text');
        break;
      case 'subscription':
        Navigator.pushNamed(context, '/subscription');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      default:
        context.read<ChatProvider>().sendMessage(destination ?? '');
    }
  }

  void _handleButtonAction(BuildContext context, ActionButton button) {
    switch (button.actionType) {
      case 'navigate':
        _handleNavigation(context, button.payload);
        break;
      case 'send_message':
        context.read<ChatProvider>().sendMessage(button.payload ?? button.label);
        break;
      default:
        context.read<ChatProvider>().sendMessage(button.payload ?? button.label);
    }
  }

  void _openUrl(BuildContext context, String url) {
    // Fallback to sending as message if URL can't be launched
    context.read<ChatProvider>().sendMessage(url);
  }

  IconData _resolveIcon(String iconName) {
    switch (iconName) {
      case 'translate':
        return Icons.translate_rounded;
      case 'hand_gesture':
        return Icons.sign_language_rounded;
      case 'info':
        return Icons.info_outline_rounded;
      case 'help':
        return Icons.help_outline_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'play_lesson':
        return Icons.play_circle_rounded;
      case 'support':
        return Icons.support_agent_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'smart_toy':
        return Icons.smart_toy_rounded;
      default:
        return Icons.smart_toy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final local = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final data = provider.welcomeData;
    final hasData = !data.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Column(
        children: [
          _buildHeader(context, isDark, local, data, hasData),
          if (hasData) ...[
            const SizedBox(height: 8),
            if (data.welcomeMessage.isNotEmpty)
              _buildWelcomeMessage(context, data.welcomeMessage, textSecondary),
            if (data.quickActions.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildQuickActions(context, data.quickActions, textPrimary, isDark),
            ],
            if (data.actionCards.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildActionCards(context, data.actionCards, textPrimary, textSecondary, isDark),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations local,
      WelcomeData data, bool hasData) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF275878).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            size: 36,
            color: Color(0xFF275878),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          local.chatbotName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        if (!hasData) ...[
          const SizedBox(height: 8),
          Text(
            local.chatbotGreeting,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, String message, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF275878).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF275878).withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
            height: 1.6,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, List<QuickAction> actions,
      Color textPrimary, bool isDark) {
    final local = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            local.chatbotQuickActions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: actions.map((action) {
            return ActionChip(
              avatar: Icon(
                _resolveIcon(action.icon),
                size: 18,
                color: const Color(0xFF275878),
              ),
              label: Text(
                action.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF275878),
                ),
              ),
              onPressed: () => _handleQuickAction(context, action),
              backgroundColor: const Color(0xFF275878).withValues(alpha: 0.08),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, List<ActionCard> cards,
      Color textPrimary, Color textSecondary, bool isDark) {
    final local = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            local.chatbotSuggestions,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        ...cards.map((card) => WelcomeActionCard(
              card: card,
              onButtonAction: (button) => _handleButtonAction(context, button),
            )),
      ],
    );
  }
}
