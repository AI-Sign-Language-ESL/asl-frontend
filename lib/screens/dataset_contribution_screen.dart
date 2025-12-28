import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../l10n/app_localizations.dart';
import 'custom_sidebar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DatasetContributionScreen extends StatelessWidget {
  const DatasetContributionScreen({Key? key}) : super(key: key);

  void _navigate(BuildContext context, int index) {
    Navigator.pop(context); // close sidebar first
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
      case 3:
        // already here
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
    final local = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,

      // === Right-side sidebar ===
      endDrawer: CustomSidebar(
        selectedIndex: 3, // current screen
        onItemTapped: (index) => _navigate(context, index),
      ),

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
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.cloud_upload_outlined,
              size: 80,
              color: AppColors.primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(height: 32),
            Text(
              local.helpUsGrow,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              local.recordSign,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              local.whatSignMean,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: local.egGoodMorning,
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.videocam_outlined,
                    size: 64,
                    color: AppColors.primaryBlue.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    local.uploadVideo,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(local.thankContribution)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  local.submitContribution,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
