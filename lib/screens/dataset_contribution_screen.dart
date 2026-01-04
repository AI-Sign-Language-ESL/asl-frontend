import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tafahom_english_light/l10n/app_localizations.dart';
import 'package:tafahom_english_light/core/constants/colors.dart';
import 'package:tafahom_english_light/services/dataset_contribution_service.dart';

class DatasetContributionScreen extends StatefulWidget {
  const DatasetContributionScreen({Key? key}) : super(key: key);

  @override
  State<DatasetContributionScreen> createState() =>
      _DatasetContributionScreenState();
}

class _DatasetContributionScreenState extends State<DatasetContributionScreen> {
  final _labelController = TextEditingController();
  final _service = DatasetContributionService();

  File? _videoFile;
  bool _isUploading = false;

  /// Pick video
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 15),
    );

    if (picked != null) {
      setState(() {
        _videoFile = File(picked.path);
      });
    }
  }

  /// Upload
  Future<void> _submit() async {
    final local = AppLocalizations.of(context)!;

    if (_videoFile == null || _labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.fillAllFields)),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _service.uploadContribution(
        video: _videoFile!, // ✅ CORRECT
        label: _labelController.text.trim(), // ✅ CORRECT
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(local.thankContribution)),
      );

      _labelController.clear();
      setState(() => _videoFile = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(local.contributeDataset),
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: local.egGoodMorning,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: _videoFile == null
                      ? Text(local.uploadVideo)
                      : const Icon(Icons.check_circle,
                          size: 60, color: Colors.green),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submit,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(local.submitContribution),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
