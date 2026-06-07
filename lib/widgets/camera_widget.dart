import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../core/constants/colors.dart';
import '../providers/theme/app_theme_provider.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  bool _initializing = false;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_initializing) return;
    _initializing = true;
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) return;
      
      _controller = CameraController(
        _cameras[_selectedCameraIndex % _cameras.length],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _controller = null);
    } finally {
      if (mounted) _initializing = false;
    }
  }

  void _switchCamera() async {
    if (_cameras.length <= 1) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _disposeCamera();
    await _initCamera();
  }

  void _disposeCamera() {
    _controller?.dispose();
    _controller = null;
    _initializing = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
  
  Color _getRecordColor(TranslationProvider provider) {
    if (!provider.cameraActive) return Colors.grey.shade400; // Idle
    if (provider.status == TranslationStatus.connecting) return Colors.orange;
    if (provider.status == TranslationStatus.translating) return Colors.red;
    return Colors.green; // Ready
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<TranslationProvider>();

    final Color boxBg = isDark ? const Color(0xFF1E1E1E) : Colors.black87;
    final Color boxBorder = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color iconColor = Colors.white54;

    return Container(
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base layer: Camera or Placeholder
            if (_controller == null || !_controller!.value.isInitialized)
              Center(
                child: _initializing
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 60, color: iconColor),
                          const SizedBox(height: 12),
                          Text(
                            'Camera initializing...',
                            style: TextStyle(
                              fontSize: 17,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
              )
            else
              CameraPreview(_controller!),
            
            // Top Right: Camera Switch Button
            if (_cameras.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
                    onPressed: _switchCamera,
                  ),
                ),
              ),

            // Bottom Center: Start/Stop Recording Button
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    provider.setCameraActive(!provider.cameraActive);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 3),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getRecordColor(provider),
                        borderRadius: provider.cameraActive
                            ? BorderRadius.circular(12) // Rounded square when recording
                            : BorderRadius.circular(30), // Circle when idle
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
