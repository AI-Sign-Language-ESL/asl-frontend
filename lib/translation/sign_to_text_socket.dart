import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SignToTextSocket {
  late WebSocketChannel _channel;

  void connect({
    required String token,
    required Function(String) onMessage,
    required Function() onDone,
    required Function(Object error) onError,
  }) {
    _channel = WebSocketChannel.connect(
      Uri.parse(
        'ws://127.0.0.1:8000/ws/translation/sign-to-text/?token=$token',
      ),
    );

    _channel.stream.listen(
      (data) {
        final decoded = jsonDecode(data);
        if (decoded['text'] != null) {
          onMessage(decoded['text']);
        }
      },
      onDone: onDone,
      onError: onError,
    );
  }

  void sendFrame(String base64Frame) {
    _channel.sink.add(jsonEncode({
      "frame": base64Frame,
    }));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
