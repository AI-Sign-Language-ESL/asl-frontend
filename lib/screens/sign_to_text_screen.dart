import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';
import '../main.dart'; // ← Required for LocaleProvider

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

  // Updated Language Picker
  Widget _buildLanguagePicker() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      padding: EdgeInsets.zero,
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF275878),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.language, color: Colors.white, size: 20),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'en',
          child: Row(
              children: [Text("🇺🇸"), SizedBox(width: 10), Text('English')]),
        ),
        const PopupMenuItem(
          value: 'ar',
          child: Row(
              children: [Text("🇪🇬"), SizedBox(width: 10), Text('العربية')]),
        ),
      ],
      onSelected: (value) {
        final newLocale =
            value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);

        // Optional smooth refresh
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  // Updated localized text using Provider instead of local variable
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
    // Listen to locale changes from Provider
    final localeProvider = Provider.of<LocaleProvider>(context);
    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    const Color backgroundBlue = Color(0xFFD5EBF5);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primaryWhite,
      drawer: isArabic
          ? null
          : CustomSidebar(selectedIndex: 2, onItemTapped: (_) {}),
      endDrawer: isArabic
          ? CustomSidebar(selectedIndex: 2, onItemTapped: (_) {})
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabic
                    ? [
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.black, size: 32),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                        ),
                        _buildLanguagePicker(),
                        Expanded(
                          child: Center(
                            child: const Text(
                              'تَفَاهُمٌ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF275878),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ]
                    : [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              'assets/TAFAHOM.png',
                              width: 120,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        _buildLanguagePicker(),
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.black, size: 32),
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
                  // Camera Box
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: backgroundBlue, width: 2.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: _cameraController == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined,
                                        size: 60, color: Colors.black),
                                    const SizedBox(height: 12),
                                    Text(
                                      _getLocalizedText(context, 'cameraOff'),
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed:
                                          _cameraLoading ? null : _startCamera,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(35)),
                                      ),
                                      child: Text(
                                        _cameraLoading
                                            ? _getLocalizedText(
                                                context, 'loading')
                                            : _getLocalizedText(
                                                context, 'startCamera'),
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
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

                  // Generated Text Box
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: backgroundBlue, width: 2.5),
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
                                  ? _getLocalizedText(context, 'generatedText')
                                  : _recognizedText,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Color(0xFF275878),
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

                  // Audio Controls
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: const Color(0xFF275878), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _speak,
                          icon: Icon(
                            _isPlaying
                                ? Icons.stop_circle_rounded
                                : Icons.play_circle_fill,
                            color: AppColors.primaryBlue,
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
                                        ? AppColors.primaryBlue
                                        : Colors.grey.shade400,
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
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.volume_up, color: Colors.grey),
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
