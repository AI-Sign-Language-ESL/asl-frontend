// lib/screens/sign_to_text_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({Key? key}) : super(key: key);

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  bool isSignToTextMode = true;
  bool isRealPerson = true;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitializing = false;

  final TextEditingController _inputTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isSignToTextMode) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;

    setState(() => _isCameraInitializing = true);

    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }

    if (mounted) {
      setState(() => _isCameraInitializing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _inputTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryBlue,
        title: Text(
          local.tafahom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      endDrawer: CustomSidebar(
        selectedIndex: isSignToTextMode ? 2 : 1,
        onItemTapped: (index) {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: isSignToTextMode
                ? _buildSignToTextInterface(local)
                : _buildTextToSignInterface(local),
          ),
        ],
      ),
    );
  }

  Widget _buildSignToTextInterface(AppLocalizations local) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: _isCameraInitializing
                ? const Center(child: CircularProgressIndicator())
                : _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CameraPreview(_cameraController!),
                      )
                    : Center(
                        child: Text(
                          local.cameraNotAvailable,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextToSignInterface(AppLocalizations local) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Spacer(),
          TextField(
            controller: _inputTextController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: local.typeYourMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                local.getStarted, // ✅ EXISTING KEY
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
