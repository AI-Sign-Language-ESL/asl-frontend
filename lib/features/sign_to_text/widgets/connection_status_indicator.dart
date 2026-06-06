import 'package:flutter/material.dart';
import '../providers/sign_to_text_provider.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  final SignToTextProvider provider;

  const ConnectionStatusIndicator({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final (Color dotColor, String label) = switch (provider.status) {
      SignToTextStatus.connecting => (Colors.orange, 'Connecting...'),
      SignToTextStatus.connected => (Colors.green, 'Connected'),
      SignToTextStatus.translating => (Colors.amber, 'Translating...'),
      SignToTextStatus.error => (Colors.red, 'Error'),
      SignToTextStatus.idle => (Colors.grey, 'Idle'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
