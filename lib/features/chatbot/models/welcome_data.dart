class QuickAction {
  final String id;
  final String title;
  final String icon;
  final String actionType;
  final String? payload;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.actionType,
    this.payload,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? 'smart_toy',
      actionType: json['action_type'] as String? ?? '',
      payload: json['payload'] as String?,
    );
  }
}

class ActionButton {
  final String label;
  final String actionType;
  final String? payload;

  const ActionButton({
    required this.label,
    required this.actionType,
    this.payload,
  });

  factory ActionButton.fromJson(Map<String, dynamic> json) {
    return ActionButton(
      label: json['label'] as String? ?? '',
      actionType: json['action_type'] as String? ?? '',
      payload: json['payload'] as String?,
    );
  }
}

class ActionCard {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<ActionButton> buttons;

  const ActionCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttons,
  });

  factory ActionCard.fromJson(Map<String, dynamic> json) {
    return ActionCard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'info',
      buttons: (json['buttons'] as List<dynamic>?)
              ?.map((e) => ActionButton.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class WelcomeData {
  final String welcomeMessage;
  final List<QuickAction> quickActions;
  final List<ActionCard> actionCards;

  const WelcomeData({
    required this.welcomeMessage,
    required this.quickActions,
    required this.actionCards,
  });

  factory WelcomeData.fromJson(Map<String, dynamic> json) {
    return WelcomeData(
      welcomeMessage: json['welcome_message'] as String? ?? '',
      quickActions: (json['quick_actions'] as List<dynamic>?)
              ?.map((e) => QuickAction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      actionCards: (json['action_cards'] as List<dynamic>?)
              ?.map((e) => ActionCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get isEmpty =>
      welcomeMessage.isEmpty && quickActions.isEmpty && actionCards.isEmpty;

  static const WelcomeData empty = WelcomeData(
    welcomeMessage: '',
    quickActions: [],
    actionCards: [],
  );
}
