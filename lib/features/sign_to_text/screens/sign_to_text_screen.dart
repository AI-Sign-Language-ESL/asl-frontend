import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../providers/locale/app_locale_provider.dart';
import '../../../providers/theme/app_theme_provider.dart';
import '../../../widgets/translation_mode_toggle.dart';
import '../../../widgets/tafahom_logo.dart';
import '../../../features/sidebar/widgets/modern_hamburger_icon.dart';
import '../providers/sign_to_text_provider.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/landmark_overlay.dart';

class SignToTextScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final TranslationMode initialMode;

  const SignToTextScreen({
    super.key, 
    this.onMenuTap,
    this.initialMode = TranslationMode.webSocket,
  });

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _cameraInitializing = false;
  bool _cameraReady = false;

  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  late AnimationController _waveController;
  final Random _random = Random();
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        if (_isSpeaking) setState(() {});
      });
    _initTts();
    _initProvider();
  }

  Future<void> _initProvider() async {
    final provider = Provider.of<SignToTextProvider>(context, listen: false);
    await provider.init();
    
    // Defer the mode set so it doesn't build during init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.setMode(widget.initialMode);
      }
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar-SA");
    _tts.setCompletionHandler(() => _stopPlayback());
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _waveController.dispose();
    _timer?.cancel();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initCameras() async {
    if (_cameras != null) return;
    _cameras = await availableCameras();
  }

  CameraDescription _getFrontCamera() {
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }
    try {
      return _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
    } catch (_) {
      return _cameras!.first;
    }
  }

  Future<void> _startCamera() async {
    if (_cameraReady) return;
    try {
      setState(() => _cameraInitializing = true);
      await _initCameras();
      final camera = _getFrontCamera();
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_onCameraImage);
      if (mounted) {
        setState(() {
          _cameraReady = true;
          _cameraInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      if (mounted) setState(() => _cameraInitializing = false);
    }
  }

  void _onCameraImage(CameraImage image) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final provider = Provider.of<SignToTextProvider>(context, listen: false);
    if (!provider.isTranslating) return;
    provider.onCameraImage(image, _cameraController!.description);
  }

  void _stopCamera() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _cameraController = null;
    _cameraReady = false;
  }

  void _toggleTranslation(SignToTextProvider provider) {
    if (provider.isTranslating) {
      provider.stopTranslation();
      _stopCamera();
    } else {
      provider.startTranslation();
      _startCamera();
    }
  }

  void _toggleSpeak(SignToTextProvider provider) {
    if (provider.currentText == null || provider.currentText!.isEmpty) return;
    if (_isSpeaking) {
      _tts.stop();
      _stopPlayback();
    } else {
      setState(() => _secondsElapsed = 0);
      _waveController.repeat();
      _startTimer();
      _isSpeaking = true;
      _tts.speak(provider.currentText!);
    }
  }

  void _stopPlayback() {
    _isSpeaking = false;
    _waveController.stop();
    _timer?.cancel();
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLanguagePicker(bool isDarkMode) {
    final localeProvider = Provider.of<AppLocaleProvider>(context, listen: false);
    final Color iconBg = isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      padding: EdgeInsets.zero,
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
        child: const Icon(Icons.language, color: Colors.white, size: 20),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              const Text("🇺🇸"),
              const SizedBox(width: 10),
              Text('English', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              const Text("🇪🇬"),
              const SizedBox(width: 10),
              Text('العربية', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        final newLocale = value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<AppLocaleProvider>();
    final bool isArabic = localeProvider.locale.languageCode == 'ar';
    final bool isDarkMode = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<SignToTextProvider>();

    final Color scaffoldBg = isDarkMode ? const Color(0xFF121212) : AppColors.primaryWhite;
    final Color accentColor = isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color boxBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color boxBorder = isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color audioBorder = accentColor;
    final Color timerColor = isDarkMode ? Colors.grey.shade500 : Colors.grey;
    final Color waveInactiveColor = isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isArabic, isDarkMode, accentColor),
            TranslationModeToggle(
              isSignToText: true,
              onSignToText: () {},
              onTextToSign: () => Navigator.pushReplacementNamed(context, '/text-to-sign'),
            ),
            const SizedBox(height: 8),
            _buildStatusBar(provider, isDarkMode),
            const SizedBox(height: 8),
            _buildProtocolToggle(provider, isDarkMode, accentColor, boxBorder),
            const SizedBox(height: 8),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildCameraSection(provider, isDarkMode, boxBg, boxBorder, accentColor),
                    const SizedBox(height: 12),
                    
                    if (provider.mode == TranslationMode.http && provider.cameraActive)
                      _buildHttpStatus(provider, isDarkMode, boxBg, boxBorder, accentColor),
                      
                    const SizedBox(height: 12),
                    
                    if (provider.currentGloss != null)
                      _buildGlossBadge(provider, isDarkMode),
                      
                    _buildTranslationBoxHeader(provider, isDarkMode),
                    _buildTranslationBox(provider, isDarkMode, boxBg, boxBorder),
                    const SizedBox(height: 12),
                    
                    if (provider.error != null)
                      _buildErrorDisplay(provider),
                      
                    _buildControlButtons(provider, isDarkMode, accentColor, boxBg, boxBorder),
                    const SizedBox(height: 12),
                    _buildAudioControls(provider, accentColor, timerColor, waveInactiveColor, boxBg, audioBorder),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isArabic, bool isDarkMode, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          isArabic
              ? _buildLanguagePicker(isDarkMode)
              : ModernHamburgerIcon(color: accentColor, size: 28, onTap: widget.onMenuTap ?? () {}),
          const Spacer(),
          const TafahomLogo(height: 22),
          const Spacer(),
          isArabic
              ? ModernHamburgerIcon(color: accentColor, size: 28, onTap: widget.onMenuTap ?? () {})
              : _buildLanguagePicker(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildStatusBar(SignToTextProvider provider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConnectionStatusIndicator(provider: provider),
          if (provider.status == SignToTextStatus.connecting)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          const Spacer(),
          if (provider.isTranslating)
            GestureDetector(
              onTap: () => provider.toggleOverlay(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  provider.showOverlay ? 'Hide Overlay' : 'Show Overlay',
                  style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : Colors.black54),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProtocolToggle(SignToTextProvider provider, bool isDarkMode, Color accentColor, Color boxBorder) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: boxBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setMode(TranslationMode.webSocket),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.mode == TranslationMode.webSocket ? accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'WebSocket',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: provider.mode == TranslationMode.webSocket 
                          ? Colors.white 
                          : (isDarkMode ? Colors.white54 : Colors.black54),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => provider.setMode(TranslationMode.http),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.mode == TranslationMode.http ? accentColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'HTTP Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: provider.mode == TranslationMode.http 
                          ? Colors.white 
                          : (isDarkMode ? Colors.white54 : Colors.black54),
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

  Widget _buildHttpStatus(SignToTextProvider provider, bool isDarkMode, Color boxBg, Color boxBorder, Color accentColor) {
    String statusText = 'Collecting';
    Color statusColor = accentColor;
    
    if (provider.status == SignToTextStatus.cooldown) {
      statusText = 'Cooldown (1.5s)';
      statusColor = Colors.orange;
    } else if (provider.status == SignToTextStatus.connecting) {
      statusText = 'Predicting...';
      statusColor = Colors.blue;
    } else if (provider.status == SignToTextStatus.translating) {
      statusText = 'Collecting';
      statusColor = Colors.green;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: boxBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HTTP Status',
                style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                statusText,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: statusColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Frame Buffer',
                style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '${provider.frameCount} / 96',
                style: TextStyle(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'monospace',
                  color: isDarkMode ? Colors.white : Colors.black87
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection(
    SignToTextProvider provider,
    bool isDarkMode,
    Color boxBg,
    Color boxBorder,
    Color accentColor,
  ) {
    final iconColor = isDarkMode ? Colors.white38 : Colors.black;

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: _cameraReady && _cameraController != null && _cameraController!.value.isInitialized
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(_cameraController!),
                  if (provider.showOverlay &&
                      provider.latestLandmarks != null &&
                      provider.latestCameraImage != null &&
                      provider.latestCamera != null &&
                      _cameraController!.value.previewSize != null)
                    LandmarkOverlay(
                      landmarks: provider.latestLandmarks!,
                      cameraImage: provider.latestCameraImage!,
                      previewSize: _cameraController!.value.previewSize!,
                      camera: provider.latestCamera!,
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.white, size: 28),
                      onPressed: () {
                        provider.stopTranslation();
                        _stopCamera();
                      },
                    ),
                  ),
                  if (provider.status == SignToTextStatus.translating && provider.currentGloss == null && provider.mode == TranslationMode.webSocket)
                    const Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              )
            : _buildCameraPlaceholder(provider, iconColor, isDarkMode, accentColor),
      ),
    );
  }

  Widget _buildCameraPlaceholder(
    SignToTextProvider provider,
    Color iconColor,
    bool isDarkMode,
    Color accentColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 60, color: iconColor),
          const SizedBox(height: 12),
          Text(
            'Camera is off',
            style: TextStyle(fontSize: 17, color: isDarkMode ? Colors.white54 : Colors.black87),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cameraInitializing ? null : () => _toggleTranslation(provider),
            icon: _cameraInitializing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_cameraInitializing ? 'Starting...' : 'Start Translation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossBadge(SignToTextProvider provider, bool isDarkMode) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: (isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878)).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Gloss: ${provider.currentGloss!}',
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white70 : Colors.black87,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTranslationBoxHeader(SignToTextProvider provider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            provider.mode == TranslationMode.webSocket ? 'Live Translation' : 'Batch Translation',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: provider.cameraActive ? provider.clearTranslation : null,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationBox(
    SignToTextProvider provider,
    bool isDarkMode,
    Color boxBg,
    Color boxBorder,
  ) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final Color textColor = isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 150),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            physics: const ClampingScrollPhysics(),
            child: _buildTranslationContent(provider, textColor, isArabic, isDarkMode),
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationContent(
    SignToTextProvider provider,
    Color textColor,
    bool isArabic,
    bool isDarkMode,
  ) {
    if ((provider.status == SignToTextStatus.translating || provider.status == SignToTextStatus.connecting) && provider.currentGloss == null && provider.currentText == null) {
      return Row(
        children: [
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text(
            'Translating...',
            style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white54 : Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }
    if (provider.currentText == null) {
      return Text(
        'Translation will appear here',
        style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white54 : Colors.black54, fontStyle: FontStyle.italic),
      );
    }
    return Text(
      provider.currentText!,
      style: TextStyle(fontSize: 20, color: textColor, height: 1.4, fontWeight: FontWeight.w600),
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _buildErrorDisplay(SignToTextProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ),
          GestureDetector(
            onTap: () => provider.clearError(),
            child: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(
    SignToTextProvider provider,
    bool isDarkMode,
    Color accentColor,
    Color boxBg,
    Color boxBorder,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: boxBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: provider.isTranslating ? Icons.stop_rounded : Icons.play_arrow_rounded,
            label: provider.isTranslating ? 'Stop' : 'Start',
            color: provider.isTranslating ? Colors.red : Colors.green,
            onTap: provider.status == SignToTextStatus.connecting && provider.mode == TranslationMode.webSocket
                ? null
                : () => _toggleTranslation(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls(
    SignToTextProvider provider,
    Color accentColor,
    Color timerColor,
    Color waveInactiveColor,
    Color boxBg,
    Color audioBorder,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: audioBorder, width: 1.5),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: provider.currentText != null ? () => _toggleSpeak(provider) : null,
            icon: Icon(
              _isSpeaking ? Icons.stop_circle_rounded : Icons.play_circle_fill,
              color: provider.currentText != null ? accentColor : Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(20, (i) {
                  double height = _isSpeaking
                      ? 5 + _random.nextInt(20).toDouble()
                      : 8 + (i % 5 * 2).toDouble();
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 3,
                    height: height,
                    decoration: BoxDecoration(
                      color: _isSpeaking ? accentColor : waveInactiveColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(_secondsElapsed),
            style: TextStyle(color: timerColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Icon(Icons.volume_up, color: timerColor),
        ],
      ),
    );
  }
}
