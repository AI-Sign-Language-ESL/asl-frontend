import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/api_service.dart';

/// Sends user text to backend, receives animation names,
/// and forwards them to a Unity WebGL build running in a WebView.
///
/// Flow:
///   TextField → api.tafahom.io → ["ana_esmy", "m2hor"] → JSON → Unity
class UnitySignScreen extends StatefulWidget {
  const UnitySignScreen({super.key});

  @override
  State<UnitySignScreen> createState() => _UnitySignScreenState();
}

class _UnitySignScreenState extends State<UnitySignScreen> {
  final TextEditingController _textController = TextEditingController();
  late final WebViewController _webController;

  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            debugPrint('[UnitySign] Page loaded');
            setState(() => _statusMessage = 'Unity ready');
          },
          onWebResourceError: (error) {
            debugPrint('[UnitySign] WebView error: $error');
            setState(() => _statusMessage = 'Failed to load Unity');
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tafahom.io/unity/'));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 1. Send user text to backend
  /// 2. Receive animation list
  /// 3. Forward JSON to Unity via JavaScript bridge
  Future<void> _sendTextToUnity() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Translating…';
    });

    try {
      // ── POST to backend ──────────────────────────────────────────────
      debugPrint('[UnitySign] Sending text: "$text"');
      final response = await ApiService.dio.post(
        '/api/v1/translation/unity-sign/',
        data: {'text': text},
      );

      // ── Parse response ───────────────────────────────────────────────
      final data = response.data as Map<String, dynamic>;
      final animations = List<String>.from(data['animations'] ?? []);
      final jsonPayload = jsonEncode({'animations': animations});

      debugPrint('[UnitySign] Animations received: $animations');
      debugPrint('[UnitySign] JSON payload: $jsonPayload');

      // ── Send to Unity WebGL ──────────────────────────────────────────
      final jsCode = "window.receiveFlutterText('$jsonPayload');";
      await _webController.runJavaScript(jsCode);

      debugPrint('[UnitySign] JavaScript executed successfully');
      setState(() => _statusMessage = 'Sent to Unity ✓');
    } on DioException catch (e) {
      debugPrint('[UnitySign] API error: ${e.message}');
      if (e.response?.statusCode == 403) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic> && responseData['detail'] == 'Not enough credits.') {
          _showInsufficientCreditsDialog(responseData);
          return;
        }
      }
      setState(() => _statusMessage = 'API error: ${e.response?.statusCode ?? e.message}');
    } catch (e) {
      debugPrint('[UnitySign] Unexpected error: $e');
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showInsufficientCreditsDialog(Map<String, dynamic> data) {
    String resetDateStr = '';
    try {
      final nextReset = DateTime.parse(data['next_reset'] as String);
      resetDateStr = '${nextReset.day}/${nextReset.month}';
    } catch (_) {
      resetDateStr = 'next week';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Insufficient Credits'),
        content: Text(
          "You've run out of credits. "
          "Your credits will reset on $resetDateStr. "
          "Upgrade your plan to get more credits.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Translation'),
      ),
      body: Column(
        children: [
          // ── WebView (Unity) ──────────────────────────────────────────
          Expanded(
            child: WebViewWidget(controller: _webController),
          ),

          // ── Status indicator ─────────────────────────────────────────
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: _statusMessage!.contains('✓')
                  ? Colors.green.shade50
                  : _statusMessage!.contains('Error') || _statusMessage!.contains('error')
                      ? Colors.red.shade50
                      : Colors.grey.shade50,
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: _statusMessage!.contains('✓')
                      ? Colors.green.shade700
                      : _statusMessage!.contains('Error')
                          ? Colors.red.shade700
                          : Colors.grey.shade700,
                ),
              ),
            ),

          // ── Input area ───────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendTextToUnity(),
                    decoration: InputDecoration(
                      hintText: 'Enter text to translate…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendTextToUnity,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
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
