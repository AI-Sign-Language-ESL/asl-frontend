// lib/screens/sign_to_text_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tafahom_english_light/l10n/app_localizations.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({Key? key}) : super(key: key);

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  bool isSignToTextMode = true; // true = Sign → Text    false = Text → Sign
  bool isRealPerson = true; // only relevant in Sign → Text mode

  // Camera related
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

      // AppBar with right-side menu
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
          // You can add navigation logic here if needed
        },
      ),

      body: Column(
        children: [
          // Mode Switcher: Sign to Text ↔ Text to Sign
          Container(
            margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isSignToTextMode) {
                        setState(() {
                          isSignToTextMode = true;
                        });
                        _initializeCamera();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSignToTextMode
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(
                        local.signToText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSignToTextMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isSignToTextMode) {
                        setState(() {
                          isSignToTextMode = false;
                        });
                        _cameraController?.dispose();
                        _cameraController = null;
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isSignToTextMode
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Text(
                        local.textToSign,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              !isSignToTextMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
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
        // Real person vs Animated character toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRealPerson = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isRealPerson
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          local.realPerson,
                          style: TextStyle(
                            color: isRealPerson
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isRealPerson = false),
                    child: Container(
                      decoration: BoxDecoration(
                        color: !isRealPerson
                            ? AppColors.primaryBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          local.character,
                          style: TextStyle(
                            color: !isRealPerson
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Camera preview area
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              local.cameraNotAvailable,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sign_language,
                  size: 80,
                  color: AppColors.primaryBlue.withOpacity(0.7),
                ),
                const SizedBox(height: 24),
                Text(
                  local.enterTextToSign,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _inputTextController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: local.typeYourMessage,
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 2),

          // Action button (can be connected to translation logic later)
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement text-to-sign conversion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                local.translate,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
