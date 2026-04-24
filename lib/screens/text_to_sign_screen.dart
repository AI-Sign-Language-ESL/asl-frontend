import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';
import '../services/to_sign_service.dart';
import '../services/speech_to_text_service.dart';
import '../main.dart'; // ThemeProvider + LocaleProvider

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final SignTranslationService _translationService = SignTranslationService();
  final SpeechToTextService _sttService = SpeechToTextService();

  VideoPlayerController? _videoController;

  bool _isListening = false;
  bool _httpLoading = false;
  bool isRealPerson = true;

  // Tracks which language the STT mic uses (separate from app locale)
  bool _isArabicSelected = true;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _sttService.init();
  }

  void _startListening() {
    _sttService.startListening(
      localeId: _isArabicSelected ? 'ar_EG' : 'en_US',
      onResult: (text) {
        setState(() {
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        });
      },
    );
    setState(() => _isListening = true);
  }

  void _stopListening() {
    _sttService.stopListening();
    setState(() => _isListening = false);
  }

  Future<void> _sendTextToSign() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _httpLoading = true;
      _videoController?.dispose();
      _videoController = null;
    });

    try {
      final videoUrl =
          await _translationService.translateTextToSign(text: text);
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      await _videoController!.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('TRANSLATION ERROR: $e');
    } finally {
      if (mounted) setState(() => _httpLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // ── Language picker popup — same style as SignToTextScreen ────────────────
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
          child: Row(children: [
            const Text("🇺🇸"),
            const SizedBox(width: 10),
            Text(
              'English',
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ]),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Row(children: [
            const Text("🇪🇬"),
            const SizedBox(width: 10),
            Text(
              'العربية',
              style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
          ]),
        ),
      ],
      onSelected: (value) {
        // Changes the app locale via LocaleProvider (same as sign-to-text)
        final newLocale =
            value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);
        // Also sync the STT mic language
        setState(() => _isArabicSelected = value == 'ar');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabicUI =
        Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // ── Adaptive palette ──────────────────────────────────────────────────
    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color accentColor =
        isDarkMode ? const Color(0xFF4A90C4) : AppColors.primaryBlue;
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;

    // Sub-toggle: outer pill uses primaryBlue family in both modes
    // Active pill is a lighter shade so the selected side is clearly distinct
    final Color toggleBg =
        isDarkMode ? const Color(0xFF1A3A52) : const Color(0xFF275878);
    final Color toggleActiveBg =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF4A7A9B);

    final Color frameColor =
        isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);
    final Color inputFillColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBorderColor =
        isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade300;
    final Color inputHintColor = isDarkMode ? Colors.white38 : Colors.black38;
    final Color inputTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color iconAreaColor =
        isDarkMode ? const Color(0xFF4A90C4) : AppColors.primaryBlue;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,

      // Drawer — respects RTL same as other screens
      drawer: isArabicUI
          ? null
          : CustomSidebar(selectedIndex: 1, onItemTapped: (_) {}),
      endDrawer: isArabicUI
          ? CustomSidebar(selectedIndex: 1, onItemTapped: (_) {})
          : null,

      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar (matches sign_to_text layout exactly) ─────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isArabicUI
                    ? [
                        // Arabic: hamburger | logo | language-picker
                        IconButton(
                          icon:
                              Icon(Icons.menu, color: menuIconColor, size: 32),
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
                        // English: language-picker | logo | hamburger
                        _buildLanguagePicker(isDarkMode),
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
                                : Image.asset('assets/TAFAHOM.png',
                                    width: 120,
                                    height: 40,
                                    fit: BoxFit.contain),
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.menu, color: menuIconColor, size: 32),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openDrawer(),
                        ),
                      ],
              ),
            ),

            // ── Translation mode toggle ───────────────────────────────────
            TranslationModeToggle(
              isSignToText: false,
              onSignToText: () =>
                  Navigator.pushReplacementNamed(context, '/sign-to-text'),
              onTextToSign: () {},
            ),
            const SizedBox(height: 15),

            // ── Real person / Character sub-toggle ────────────────────────
            _buildSubToggle(
              isArabicUI,
              toggleBg,
              toggleActiveBg,
            ),
            const SizedBox(height: 15),

            // ── Video frame ───────────────────────────────────────────────
            Expanded(child: _buildVideoFrame(frameColor, accentColor)),

            // ── Input bar ─────────────────────────────────────────────────
            _buildInputBar(
              isArabicUI,
              iconAreaColor,
              inputFillColor,
              inputBorderColor,
              inputHintColor,
              inputTextColor,
            ),
          ],
        ),
      ),
    );
  }

  // ── Video frame ────────────────────────────────────────────────────────────
  Widget _buildVideoFrame(Color frameColor, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: frameColor, width: 4),
      ),
      child: Center(
        child: _httpLoading
            ? CircularProgressIndicator(color: accentColor)
            : (_videoController != null &&
                    _videoController!.value.isInitialized)
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : Icon(
                    isRealPerson ? Icons.person : Icons.face,
                    size: 70,
                    color: frameColor,
                  ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────
  Widget _buildInputBar(
    bool isArabic,
    Color iconAreaColor,
    Color fillColor,
    Color borderColor,
    Color hintColor,
    Color textColor,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: () => _isListening ? _stopListening() : _startListening(),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : iconAreaColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                style: TextStyle(color: textColor),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: isArabic ? 'تحدث أو اكتب...' : 'Speak or type...',
                  hintStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: iconAreaColor, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: iconAreaColor),
                    onPressed: _sendTextToSign,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Real person / Character sub-toggle ────────────────────────────────────
  Widget _buildSubToggle(
    bool isArabic,
    Color bg,
    Color activeBg,
  ) {
    return Container(
      height: 40,
      width: 260,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment:
                isRealPerson ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                color: activeBg,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isRealPerson = true),
                  child: Center(
                    child: Text(
                      isArabic ? 'شخص حقيقي' : 'Real person',
                      style: TextStyle(
                        color: isRealPerson ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isRealPerson = false),
                  child: Center(
                    child: Text(
                      isArabic ? 'مجسم' : 'Character',
                      style: TextStyle(
                        color: !isRealPerson ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
