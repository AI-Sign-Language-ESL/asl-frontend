import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../widgets/translation_mode_toggle.dart';
import '../core/constants/colors.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  CameraController? _cameraController;
  bool _isInitializing = false;

  WebSocketChannel? _channel;
  String _recognizedText = "";

  @override
  void dispose() {
    _cameraController?.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _startCamera() async {
    setState(() => _isInitializing = true);

    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    _connectWebSocket();

    setState(() => _isInitializing = false);
  }

  void _connectWebSocket() {
    const token = "ACCESS_TOKEN_HERE";

    _channel = WebSocketChannel.connect(
      Uri.parse(
        "ws://127.0.0.1:8000/ws/translation/sign-to-text/?token=$token",
      ),
    );

    _channel!.stream.listen((data) {
      final decoded = jsonDecode(data);
      if (decoded["text"] != null) {
        setState(() => _recognizedText = decoded["text"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("TAFAHOM"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          TranslationModeToggle(
            isSignToText: true,
            onSignToText: () {},
            onTextToSign: () =>
                Navigator.pushReplacementNamed(context, '/text-to-sign'),
          ),

          const SizedBox(height: 20),

          /// CAMERA AREA
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: _cameraController == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 48),
                        const SizedBox(height: 12),
                        const Text("Camera is off"),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _isInitializing ? null : _startCamera,
                          child: const Text("Start camera"),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: CameraPreview(_cameraController!),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          /// GENERATED TEXT
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _recognizedText.isEmpty
                  ? "Waiting for output..."
                  : _recognizedText,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
