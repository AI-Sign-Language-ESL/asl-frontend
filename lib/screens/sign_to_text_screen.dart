import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';

// Remove this import:
// import '../services/websocket_client.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  CameraController? _cameraController;
  bool _cameraLoading = false;
  String _recognizedText = "";

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    if (_cameraController != null) return;

    try {
      setState(() => _cameraLoading = true);

      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    } finally {
      if (mounted) setState(() => _cameraLoading = false);
    }
  }

  void _stopCamera() {
    _cameraController?.dispose();
    _cameraController = null;
    setState(() => _recognizedText = "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign → Text'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: CustomSidebar(
        selectedIndex: 2,
        onItemTapped: (_) {}, // will be handled in sidebar
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          TranslationModeToggle(
            isSignToText: true,
            onSignToText: () {}, // already in this mode
            onTextToSign: () {
              Navigator.pushReplacementNamed(context, '/text-to-sign');
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _cameraController == null
                        ? Center(
                            child: ElevatedButton(
                              onPressed: _cameraLoading ? null : _startCamera,
                              child: Text(_cameraLoading
                                  ? 'Loading...'
                                  : 'Start Camera'),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CameraPreview(_cameraController!),
                          ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _recognizedText.isEmpty
                        ? 'Waiting for output...'
                        : _recognizedText,
                    style: const TextStyle(fontSize: 16),
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
