import 'package:flutter/material.dart';
import '../widgets/translation_mode_toggle.dart';
import '../core/constants/colors.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  bool _isLoading = false;

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
            isSignToText: false,
            onSignToText: () =>
                Navigator.pushReplacementNamed(context, '/sign-to-text'),
            onTextToSign: () {},
          ),

          const SizedBox(height: 20),

          /// AVATAR / OUTPUT
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: _isLoading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text("Waiting for output..."),
                        ],
                      )
                    : const Text("No output yet"),
              ),
            ),
          ),

          /// INPUT BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "type or speak...",
                prefixIcon: const Icon(Icons.mic),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
