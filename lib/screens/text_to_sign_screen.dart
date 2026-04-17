import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../widgets/translation_mode_toggle.dart';
import '../services/to_sign_service.dart';
import '../services/speech_to_text_service.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});

  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  final SignTranslationService _translationService = SignTranslationService();
  final SpeechToTextService _sttService = SpeechToTextService();

  VideoPlayerController? _videoController;

  bool _isListening = false;
  bool _httpLoading = false;
  bool isRealPerson = true;

  // 🔥 NEW: manual language control
  bool _isArabicSelected = true;

  static const Color frameColor = Color(0xFFD5EBF5);
  static const Color activeToggleColor = Color(0xFF98A8B4);
  static const Color inactiveToggleColor = Color(0xFF275878);

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _sttService.init();
  }

  // ================= 🎤 SPEECH =================

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

  // ================= 🔁 TEXT → SIGN =================

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

      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      await _videoController!.initialize();
      await _videoController!.play();

      setState(() {});
    } catch (e) {
      debugPrint('TRANSLATION ERROR: $e');
    } finally {
      setState(() => _httpLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final bool isArabicUI =
        Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomSidebar(selectedIndex: 1, onItemTapped: (_) {}),
      appBar: _buildAppBar(isArabicUI),
      body: Column(
        children: [
          const SizedBox(height: 10),
          TranslationModeToggle(
            isSignToText: false,
            onSignToText: () =>
                Navigator.pushReplacementNamed(context, '/sign-to-text'),
            onTextToSign: () {},
          ),
          const SizedBox(height: 15),

          // 🔥 NEW LANGUAGE TOGGLE
          _buildLanguageToggle(),

          const SizedBox(height: 10),
          _buildSubToggle(isArabicUI),
          const SizedBox(height: 15),
          Expanded(child: _buildVideoFrame()),
          _buildInputBar(isArabicUI),
        ],
      ),
    );
  }

  // ================= 🔥 LANGUAGE TOGGLE =================

  Widget _buildLanguageToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('🇪🇬 Arabic'),
          selected: _isArabicSelected,
          onSelected: (_) {
            setState(() => _isArabicSelected = true);
          },
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('🇺🇸 English'),
          selected: !_isArabicSelected,
          onSelected: (_) {
            setState(() => _isArabicSelected = false);
          },
        ),
      ],
    );
  }

  // ================= UI PARTS =================

  AppBar _buildAppBar(bool isArabic) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: isArabic
          ? const Text(
              'تَفَاهُمٌ',
              style: TextStyle(
                fontSize: 33,
                fontWeight: FontWeight.bold,
                color: Color(0xFF275878),
              ),
            )
          : Image.asset('assets/TAFAHOM.png', width: 120),
    );
  }

  Widget _buildVideoFrame() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: frameColor, width: 4),
      ),
      child: Center(
        child: _httpLoading
            ? const CircularProgressIndicator()
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

  Widget _buildInputBar(bool isArabic) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          textDirection:
              isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            GestureDetector(
              onTap: () => _isListening
                  ? _stopListening()
                  : _startListening(),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color:
                      _isListening ? Colors.red : AppColors.primaryBlue,
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
                textDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign:
                    isArabic ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText:
                      isArabic ? 'تحدث أو اكتب...' : 'Speak or type...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
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
                  onTap: () => setState(() => isRealPerson = true),
                  child: Center(
                    child: Text(
                      isArabic ? 'شخص حقيقي' : 'Real person',
                      style: TextStyle(
                        color: isRealPerson
                            ? Colors.white
                            : Colors.black54,
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
                        color: !isRealPerson
                            ? Colors.white
                            : Colors.black54,
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