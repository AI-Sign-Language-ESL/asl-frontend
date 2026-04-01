import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';
import '../main.dart'; // ← Import this to access LocaleProvider

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _httpLoading = false;
  bool _isListening = false;
  bool isRealPerson = true;

  static const Color frameColor = Color(0xFFD5EBF5);
  static const Color activeToggleColor = Color(0xFF98A8B4);
  static const Color inactiveToggleColor = Color(0xFF275878);

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() => _textController.text = result.recognizedWords);
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _sendTextToSign() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _httpLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _httpLoading = false);
  }

  // Updated Language Picker - Now changes the whole app
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
            children: [
              Text("🇺🇸"),
              SizedBox(width: 10),
              Text('English'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              Text("🇪🇬"),
              SizedBox(width: 10),
              Text('العربية'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        final newLocale =
            value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);

        // Optional: Small delay + rebuild current screen for smoother transition
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current locale from Provider (this makes the screen react to language changes)
    final localeProvider = Provider.of<LocaleProvider>(context);
    final bool isArabic = localeProvider.locale.languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isArabic
          ? null
          : CustomSidebar(selectedIndex: 1, onItemTapped: (_) {}),
      endDrawer: isArabic
          ? CustomSidebar(selectedIndex: 1, onItemTapped: (_) {})
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
              isSignToText: false,
              onSignToText: () =>
                  Navigator.pushReplacementNamed(context, '/sign-to-text'),
              onTextToSign: () {},
            ),
            const SizedBox(height: 15),
            _buildSubToggle(isArabic),
            const SizedBox(height: 15),

            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: frameColor, width: 4),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_httpLoading)
                      const CircularProgressIndicator(
                          strokeWidth: 6, color: frameColor)
                    else
                      Icon(
                        isRealPerson
                            ? Icons.person
                            : Icons.face_retouching_natural,
                        size: 60,
                        color: frameColor,
                      ),
                    const SizedBox(height: 25),
                    Text(
                      _httpLoading
                          ? (isArabic ? "جاري العمل..." : "Processing...")
                          : (isRealPerson
                              ? (isArabic
                                  ? "بانتظار الشخص الحقيقي..."
                                  : "Waiting for Real Person...")
                              : (isArabic
                                  ? "بانتظار المجسم..."
                                  : "Waiting for Character...")),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildInputBar(isArabic),
          ],
        ),
      ),
    );
  }

  // Keep your existing _buildInputBar and _buildSubToggle methods unchanged
  Widget _buildInputBar(bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : const Color(0xFF275878),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: TextField(
                controller: _textController,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: _isListening
                      ? (isArabic ? "جاري الاستماع..." : "Listening...")
                      : (isArabic ? "اكتب او تحدث..." : "type or speak..."),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Color(0xFF275878)),
                    onPressed: _sendTextToSign,
                  ),
                ),
                onSubmitted: (_) => _sendTextToSign(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubToggle(bool isArabic) {
    return Container(
      height: 40,
      width: 260,
      decoration: BoxDecoration(
        color: inactiveToggleColor,
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
                color: activeToggleColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => isRealPerson = true),
                  child: Center(
                    child: Text(
                      isArabic ? "شخص حقيقي" : "Real person",
                      style: TextStyle(
                        color: isRealPerson ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => isRealPerson = false),
                  child: Center(
                    child: Text(
                      isArabic ? "مجسم" : "Character",
                      style: TextStyle(
                        color: !isRealPerson ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
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
