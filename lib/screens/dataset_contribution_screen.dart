import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';
import '../services/dataset_service.dart';
import '../main.dart'; // ThemeProvider

class DatasetContributionScreen extends StatefulWidget {
  const DatasetContributionScreen({Key? key}) : super(key: key);

  @override
  State<DatasetContributionScreen> createState() =>
      _DatasetContributionScreenState();
}

class _DatasetContributionScreenState extends State<DatasetContributionScreen>
    with SingleTickerProviderStateMixin {
  XFile? _pickedVideo;
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  final TextEditingController _meaningController = TextEditingController();
  final DatasetService _datasetService = DatasetService();

  bool _isLoading = false;
  bool _isVideoSelected = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2, end: 8).animate(_glowController);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _glowController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  // ── Video source picker ───────────────────────────────────────────────────
  Future<void> _showVideoSourceOptions() async {
    if (_isVideoSelected) return;

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.read<ThemeProvider>().isDarkMode;
    final Color sheetBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color iconColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color textColor = isDarkMode ? Colors.white70 : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: iconColor, size: 28),
              title: Text(
                isArabic ? "تصوير فيديو جديد" : "Record New Video",
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _recordVideoFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: iconColor, size: 28),
              title: Text(
                isArabic ? "اختيار من المعرض" : "Choose from Gallery",
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _pickVideoFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _recordVideoFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 10),
      );
      if (video != null && mounted) {
        setState(() {
          _pickedVideo = video;
          _isVideoSelected = true;
        });
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        setState(() {
          _pickedVideo = video;
          _isVideoSelected = true;
        });
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitContribution() async {
    if (_pickedVideo == null || _meaningController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _datasetService.submitContribution(
        word: _meaningController.text.trim(),
        videoPath: _pickedVideo!.path,
      );

      // Guard: widget may have been disposed while the network call was running
      if (!mounted) return;

      // Stop the loading spinner first, then schedule the dialog for the
      // next frame so we never call showDialog inside an active setState.
      setState(() => _isLoading = false);

      _confettiController.play();

      // Capture theme/locale BEFORE the async gap (still valid here because
      // we already passed the mounted check above).
      final bool isDarkMode = context.read<ThemeProvider>().isDarkMode;
      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';

      // Schedule dialog after the current frame completes — this prevents
      // "showDialog called during build / setState" crashes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            backgroundColor:
                isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  isArabic
                      ? "شكراً لمساهمتك!"
                      : "Thank you for your contribution!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? "تم إرسال فيديوك بنجاح"
                      : "Your video has been submitted successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade500 : Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _resetForm();
                },
                child: Text(
                  isArabic ? "حسناً" : "OK",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDarkMode
                        ? const Color(0xFF4A90C4)
                        : const Color(0xFF275878),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint("Submit Error: $e");

      final bool isArabic =
          Localizations.localeOf(context).languageCode == 'ar';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? "حدث خطأ، يرجى المحاولة مرة أخرى"
                : "An error occurred. Please try again.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    if (!mounted) return;
    setState(() {
      _pickedVideo = null;
      _isVideoSelected = false;
      _meaningController.clear();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : Colors.white;
    final Color accentColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color menuIconColor = isDarkMode ? Colors.white70 : Colors.black;
    final Color titleColor =
        isDarkMode ? Colors.white : const Color(0xFF212121);
    final Color labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color inputFillColor =
        isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBorderColor =
        isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade300;
    final Color inputHintColor = isDarkMode ? Colors.white38 : Colors.black38;
    final Color inputTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final Color videoBgNormal =
        isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFEDF2F5);
    final Color videoBorderNormal =
        isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade400;
    final Color videoIconColor = isDarkMode ? Colors.white54 : Colors.black87;
    final Color videoSubTextColor =
        isDarkMode ? Colors.white38 : Colors.black54;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      drawer: isArabic
          ? null
          : CustomSidebar(selectedIndex: 3, onItemTapped: (_) {}),
      endDrawer: isArabic
          ? CustomSidebar(selectedIndex: 3, onItemTapped: (_) {})
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: isArabic
                        ? [
                            IconButton(
                              icon: Icon(Icons.menu,
                                  color: menuIconColor, size: 32),
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
                            const SizedBox(width: 48),
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
                            IconButton(
                              icon: Icon(Icons.menu,
                                  color: menuIconColor, size: 32),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                          ],
                  ),
                ),

                // ── Scrollable content ───────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.cloud_upload_outlined,
                              size: 70, color: menuIconColor),
                          const SizedBox(height: 10),
                          Text(
                            isArabic ? "ساعدنا نكبر" : "Help Us Grow",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Label
                          Align(
                            alignment: isArabic
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              isArabic
                                  ? "ماذا تعنى هذه الإشارة؟"
                                  : "What does this sign mean?",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: labelColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Text field
                          TextField(
                            controller: _meaningController,
                            style: TextStyle(color: inputTextColor),
                            textAlign:
                                isArabic ? TextAlign.right : TextAlign.left,
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: isArabic
                                  ? "مثال: \"أهلاً وسهلاً\""
                                  : 'e.g. "Good morning"',
                              hintStyle: TextStyle(color: inputHintColor),
                              filled: true,
                              fillColor: inputFillColor,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: inputBorderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: accentColor, width: 2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ── Video pick box with glow animation ───────
                          GestureDetector(
                            onTap: _isVideoSelected
                                ? null
                                : _showVideoSourceOptions,
                            child: AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: _isVideoSelected
                                        ? (isDarkMode
                                            ? Colors.green.shade900
                                                .withOpacity(0.4)
                                            : Colors.green.shade50)
                                        : videoBgNormal,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _isVideoSelected
                                          ? Colors.green
                                          : videoBorderNormal,
                                      width: _isVideoSelected ? 3 : 1,
                                    ),
                                    boxShadow: _isVideoSelected
                                        ? [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.4),
                                              blurRadius: _glowAnimation.value,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: child,
                                );
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isVideoSelected)
                                    const Icon(Icons.check_circle,
                                        size: 60, color: Colors.green)
                                  else
                                    Icon(Icons.videocam_outlined,
                                        size: 60, color: videoIconColor),
                                  const SizedBox(height: 12),
                                  Text(
                                    _isVideoSelected
                                        ? (isArabic
                                            ? "تم تسجيل الفيديو بنجاح"
                                            : "Video Recorded Successfully")
                                        : (isArabic
                                            ? "تسجيل فيديو"
                                            : "Record Video"),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: _isVideoSelected
                                          ? Colors.green
                                          : videoIconColor,
                                    ),
                                  ),
                                  if (!_isVideoSelected)
                                    Text(
                                      isArabic
                                          ? "بحد أقصى 10 ثواني"
                                          : "Max 10 seconds",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: videoSubTextColor),
                                    ),
                                  if (_isVideoSelected)
                                    const Text(
                                      "✓ Ready to submit",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // ── Submit button ────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: (_pickedVideo != null &&
                                      _meaningController.text
                                          .trim()
                                          .isNotEmpty &&
                                      !_isLoading)
                                  ? _submitContribution
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                disabledBackgroundColor: isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      isArabic
                                          ? "إرسال المساهمة"
                                          : "Submit Contribution",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Confetti ──────────────────────────────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.06,
                numberOfParticles: 60,
                gravity: 0.15,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.orange,
                  Colors.pink,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
