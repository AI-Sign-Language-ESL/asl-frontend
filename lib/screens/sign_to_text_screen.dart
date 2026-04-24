import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';
import '../main.dart'; // LocaleProvider + ThemeProvider

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});

  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController? _cameraController;
  bool _cameraLoading = false;

  String _recognizedText =
      "Hello, this is a demonstration of sign translation. This box is scrollable and will display the text generated from sign language input captured by the camera above. You can also play this text using the audio controls below.";

  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;
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
        if (_isPlaying) setState(() {});
      });

    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
    _tts.setCompletionHandler(() => _stopPlayback());
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
      _waveController.stop();
      _timer?.cancel();
    });
  }

  Future<void> _speak() async {
    if (_recognizedText.isEmpty) return;

    if (_isPlaying) {
      await _tts.stop();
      _stopPlayback();
    } else {
      setState(() {
        _isPlaying = true;
        _secondsElapsed = 0;
      });
      _waveController.repeat();
      _startTimer();
      await _tts.speak(_recognizedText);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _waveController.dispose();
    _timer?.cancel();
    _tts.stop();
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
      debugPrint('Camera error: $e');
    } finally {
      if (mounted) setState(() => _cameraLoading = false);
    }
  }

  Widget _buildLanguagePicker(bool isDarkMode) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final Color iconBg =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);

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
              Text(
                'English',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              const Text("🇪🇬"),
              const SizedBox(width: 10),
              Text(
                'العربية',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        final newLocale =
            value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  String _getLocalizedText(BuildContext context, String key) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    final Map<String, Map<String, String>> translations = {
      'cameraOff': {'en': 'Camera is off', 'ar': 'الكاميرا متوقفة'},
      'startCamera': {'en': 'Start Camera', 'ar': 'تشغيل الكاميرا'},
      'loading': {'en': 'Loading...', 'ar': 'جاري التحميل...'},
      'generatedText': {'en': 'Generated text', 'ar': 'النص المُنشأ'},
    };

    return translations[key]?[isArabic ? 'ar' : 'en'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final bool isArabic = localeProvider.locale.languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // ── Adaptive palette ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : AppColors.primaryWhite;
    final Color accentColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color boxBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color boxBorder =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color audioBorder =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color cameraIconColor = isDarkMode ? Colors.white38 : Colors.black;
    final Color recognizedTextColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color timerColor = isDarkMode ? Colors.grey.shade500 : Colors.grey;
    final Color waveInactiveColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: isArabic
          ? null
          : CustomSidebar(selectedIndex: 2, onItemTapped: (_) {}),
      endDrawer: isArabic
          ? CustomSidebar(selectedIndex: 2, onItemTapped: (_) {})
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: menuIconColor,
                            size: 32,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'تَفَاهُمٌ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                        _buildLanguagePicker(isDarkMode),
                        const SizedBox(width: 4),
                      ]
                    : [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: isDarkMode
                                ? Text(
                                    'TAFAHOM',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor,
                                      letterSpacing: 2,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/TAFAHOM.png',
                                    width: 120,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                        _buildLanguagePicker(isDarkMode),
                        IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: menuIconColor,
                            size: 32,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ],
              ),
            ),

            TranslationModeToggle(
              isSignToText: true,
              onSignToText: () {},
              onTextToSign: () =>
                  Navigator.pushReplacementNamed(context, '/text-to-sign'),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Column(
                children: [
                  // ── Camera box ───────────────────────────────────────
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: boxBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: boxBorder, width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: _cameraController == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 60,
                                      color: cameraIconColor,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _getLocalizedText(context, 'cameraOff'),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed:
                                          _cameraLoading ? null : _startCamera,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            35,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _cameraLoading
                                            ? _getLocalizedText(
                                                context,
                                                'loading',
                                              )
                                            : _getLocalizedText(
                                                context,
                                                'startCamera',
                                              ),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ── Generated text box ───────────────────────────────
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: boxBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: boxBorder, width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowIndicator();
                            return true;
                          },
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(25),
                            physics: const ClampingScrollPhysics(),
                            child: Text(
                              _recognizedText.isEmpty
                                  ? _getLocalizedText(
                                      context,
                                      'generatedText',
                                    )
                                  : _recognizedText,
                              style: TextStyle(
                                fontSize: 18,
                                color: recognizedTextColor,
                                height: 1.4,
                              ),
                              textAlign:
                                  isArabic ? TextAlign.right : TextAlign.left,
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Audio controls ───────────────────────────────────
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: boxBg,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: audioBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _speak,
                          icon: Icon(
                            _isPlaying
                                ? Icons.stop_circle_rounded
                                : Icons.play_circle_fill,
                            color: accentColor,
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
                                double height = _isPlaying
                                    ? 5 + _random.nextInt(20).toDouble()
                                    : 8 + (i % 5 * 2).toDouble();
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 3,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: _isPlaying
                                        ? accentColor
                                        : waveInactiveColor,
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
                          style: TextStyle(
                            color: timerColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.volume_up, color: timerColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
