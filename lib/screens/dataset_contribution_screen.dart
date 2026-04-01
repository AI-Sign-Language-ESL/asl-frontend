import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

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
  static const Color frameColor = Color(0xFFD5EBF5);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 3),
  );

  final TextEditingController _meaningController = TextEditingController();

  // Animation for glowing effect
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  bool _isVideoSelected = false;

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

  // Show options: Record or Gallery
  Future<void> _showVideoSourceOptions() async {
    if (_isVideoSelected) return; // Prevent re-selection after success

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF275878), size: 28),
              title: Text(isArabic ? "تصوير فيديو جديد" : "Record New Video"),
              onTap: () {
                Navigator.pop(context);
                _recordVideoFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: Color(0xFF275878), size: 28),
              title:
                  Text(isArabic ? "اختيار من المعرض" : "Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
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
      if (video != null) {
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
      if (video != null) {
        setState(() {
          _pickedVideo = video;
          _isVideoSelected = true;
        });
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
    }
  }

  Future<void> _submitContribution() async {
    if (_pickedVideo == null || _meaningController.text.trim().isEmpty) return;

    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? "شكراً لمساهمتك!"
                  : "Thank you for your contribution!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? "تم إرسال فيديوك بنجاح"
                  : "Your video has been submitted successfully",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? "حسناً"
                  : "OK",
              style: const TextStyle(fontSize: 18, color: Color(0xFF275878)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _pickedVideo = null;
      _isVideoSelected = false;
      _meaningController.clear();
    });
  }

  void _handleSidebarTap(BuildContext context, int index) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      switch (index) {
        case 0:
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/text_to_sign');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/sign_to_text');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/subscription');
          break;
        case 5:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        case 6:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: isArabic
          ? null
          : CustomSidebar(
              selectedIndex: 3,
              onItemTapped: (index) => _handleSidebarTap(context, index)),
      endDrawer: isArabic
          ? CustomSidebar(
              selectedIndex: 3,
              onItemTapped: (index) => _handleSidebarTap(context, index))
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: isArabic
                        ? [
                            IconButton(
                                icon: const Icon(Icons.menu,
                                    color: Colors.black, size: 32),
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openEndDrawer()),
                            Expanded(
                                child: Center(
                                    child: const Text('تَفَاهُمٌ',
                                        style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF275878))))),
                            const SizedBox(width: 48),
                          ]
                        : [
                            const SizedBox(width: 48),
                            Expanded(
                                child: Center(
                                    child: Image.asset('assets/TAFAHOM.png',
                                        width: 120,
                                        height: 40,
                                        fit: BoxFit.contain))),
                            IconButton(
                                icon: const Icon(Icons.menu,
                                    color: Colors.black, size: 32),
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer()),
                          ],
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: frameColor, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Icon(Icons.cloud_upload_outlined,
                                size: 70, color: Colors.black87),
                            const SizedBox(height: 10),
                            Text(
                              isArabic ? "ساعدنا نكبر" : "Help Us Grow",
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF212121)),
                            ),
                            const SizedBox(height: 30),

                            // Meaning Field
                            Align(
                              alignment: isArabic
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Text(
                                isArabic
                                    ? "ماذا تعنى هذه الإشارة؟"
                                    : "What does this sign mean?",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _meaningController,
                              textAlign:
                                  isArabic ? TextAlign.right : TextAlign.left,
                              textDirection: isArabic
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: isArabic
                                    ? "مثال: \"أهلاً وسهلاً\""
                                    : 'e.g. "Good morning"',
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Video Box - Changes after selection
                            GestureDetector(
                              onTap: _isVideoSelected
                                  ? null
                                  : _showVideoSourceOptions,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: _isVideoSelected
                                      ? Colors.green.shade50
                                      : const Color(0xFFEDF2F5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _isVideoSelected
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: _isVideoSelected ? 3 : 1,
                                  ),
                                  boxShadow: _isVideoSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.6),
                                            blurRadius: _glowAnimation.value,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isVideoSelected)
                                      const Icon(Icons.check_circle,
                                          size: 60, color: Colors.green)
                                    else
                                      const Icon(Icons.videocam_outlined,
                                          size: 60, color: Colors.black87),
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
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (!_isVideoSelected)
                                      Text(
                                        isArabic
                                            ? "بحد أقصى 10 ثواني"
                                            : "Max 10 seconds",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    if (_isVideoSelected)
                                      const Text(
                                        "✓ Ready to submit",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: (_pickedVideo != null &&
                                        _meaningController.text
                                            .trim()
                                            .isNotEmpty)
                                    ? _submitContribution
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF275878),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  isArabic
                                      ? "إرسال المساهمة"
                                      : "Submit Contribution",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Confetti
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
                  Colors.pink
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
