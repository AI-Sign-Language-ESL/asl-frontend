import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _httpLoading = false;
  String _signResult = "";

  Future<void> _sendTextToSign() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _httpLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/translation/text-to-sign/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ACCESS_TOKEN_HERE',
        },
        body: jsonEncode({
          'text': _textController.text.trim(),
          'language': 'ase',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _signResult = data['result'] ?? 'No result';
        });
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('HTTP exception: $e');
    }

    setState(() => _httpLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Text → Sign'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomSidebar(
        selectedIndex: 1,
        onItemTapped: (_) {},
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          TranslationModeToggle(
            isSignToText: false,
            onSignToText: () {
              Navigator.pushReplacementNamed(context, '/sign-to-text');
            },
            onTextToSign: () {}, // already in this mode
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: _httpLoading
                        ? const CircularProgressIndicator()
                        : Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _signResult.isEmpty
                                  ? 'No output yet'
                                  : _signResult,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Type text here...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.send, size: 32),
                        color: AppColors.primaryBlue,
                        onPressed: _httpLoading ? null : _sendTextToSign,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
