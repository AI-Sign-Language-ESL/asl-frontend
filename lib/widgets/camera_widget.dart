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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<TranslationProvider>();
    if (provider.cameraActive && _controller == null && !_initializing) {
      _initCamera();
    } else if (!provider.cameraActive && _controller != null) {
      _disposeCamera();
    }
  }

  Future<void> _initCamera() async {
    if (_initializing) return;
    _initializing = true;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras.first,
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<TranslationProvider>();

    final Color boxBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color boxBorder =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color iconColor = isDark ? Colors.white38 : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: _controller == null || !_controller!.value.isInitialized
            ? _buildPlaceholder(provider, iconColor, isDark)
            : _buildPreview(),
      ),
    );
  }

  Widget _buildPlaceholder(
      TranslationProvider provider, Color iconColor, bool isDark) {
    return Center(
      child: provider.cameraActive && _initializing
          ? const CircularProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined, size: 60, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  'Camera is off',
                  style: TextStyle(
                    fontSize: 17,
                    color: isDark ? Colors.white54 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<TranslationProvider>().setCameraActive(true);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF4A90C4)
                        : AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.stop_circle_outlined,
                color: Colors.white, size: 28),
            onPressed: () {
              context.read<TranslationProvider>().setCameraActive(false);
            },
          ),
        ),
      ],
    );
  }
}
