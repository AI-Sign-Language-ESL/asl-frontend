import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/colors.dart';
import 'custom_sidebar.dart';

class DatasetContributionScreen extends StatefulWidget {
  const DatasetContributionScreen({Key? key}) : super(key: key);

  @override
  State<DatasetContributionScreen> createState() =>
      _DatasetContributionScreenState();
}

class _DatasetContributionScreenState extends State<DatasetContributionScreen> {
  XFile? _pickedVideo;
  final ImagePicker _picker = ImagePicker();
  static const Color frameColor = Color(0xFFD5EBF5);

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _pickedVideo = video;
      });
    }
  }

  void _navigate(BuildContext context, int index) {
    Navigator.pop(context);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
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
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      // 1. Always use endDrawer for the right-side sidebar
      endDrawer: CustomSidebar(
        selectedIndex: 3,
        onItemTapped: (index) => _navigate(context, index),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        // 2. Clear leading to ensure no back button or auto-menu appears on the left
        leading: null,

        title: isArabic
            ? const Text('تَفَاهُمٌ',
                style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF275878)))
            : Image.asset('assets/TAFAHOM.png',
                width: 120, height: 30, fit: BoxFit.contain),

        // 3. Place the menu button in actions to keep it on the right
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              // 4. Specifically call openEndDrawer()
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
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
                const SizedBox(height: 10),
                Text(
                  isArabic
                      ? "سجل إشارة وأخبرنا ماذا تعنى، لتحسين قاعدة بياناتنا."
                      : "Record a sign and tell us what it means to improve our dataset.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment:
                      isArabic ? Alignment.centerRight : Alignment.centerLeft,
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
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection:
                      isArabic ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: isArabic
                        ? "مثال: \"أهلاً وسهلاً\""
                        : 'e.g. "Good morning"',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2F5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.grey.shade400,
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_outlined,
                            size: 60, color: Colors.black87),
                        const SizedBox(height: 10),
                        Text(
                          isArabic ? "تسجيل فيديو" : "Record Video",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isArabic ? "بحد اقصي 10 ثواني" : "Max 10 seconds",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF275878),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isArabic ? "إرسال" : "Submit contribution",
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
