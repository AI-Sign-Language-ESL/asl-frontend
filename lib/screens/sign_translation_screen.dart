import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../providers/translation_provider.dart';
import '../providers/locale/app_locale_provider.dart';
import '../providers/theme/app_theme_provider.dart';
import '../widgets/translation_mode_toggle.dart';
import '../widgets/tafahom_logo.dart';
import '../widgets/camera_widget.dart';
import '../widgets/translation_widget.dart';
import '../widgets/translation_history_widget.dart';
import '../features/sidebar/widgets/modern_hamburger_icon.dart';

class SignTranslationScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  const SignTranslationScreen({super.key, this.onMenuTap});

  @override
  State<SignTranslationScreen> createState() => _SignTranslationScreenState();
}

class _SignTranslationScreenState extends State<SignTranslationScreen>
    with SingleTickerProviderStateMixin {
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
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _timer?.cancel();
    context.read<TranslationProvider>().setCameraActive(false);
    super.dispose();
  }

  void _toggleSpeak(TranslationProvider provider) {
    if (provider.currentText == null || provider.currentText!.isEmpty) return;

    if (provider.isSpeaking) {
      provider.stopSpeaking();
      _stopPlayback();
    } else {
      setState(() => _secondsElapsed = 0);
      _waveController.repeat();
      _startTimer();
      provider.speak(provider.currentText!);
    }
  }

  void _stopPlayback() {
    _waveController.stop();
    _timer?.cancel();
  }

  void _startTimer() {
    _secondsElapsed = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLanguagePicker(bool isDarkMode) {
    final localeProvider =
        Provider.of<AppLocaleProvider>(context, listen: false);
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
              Text('English',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'ar',
          child: Row(
            children: [
              const Text("🇪🇬"),
              const SizedBox(width: 10),
              Text('العربية',
                  style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        final newLocale =
            value == 'ar' ? const Locale('ar') : const Locale('en');
        localeProvider.setLocale(newLocale);
      },
    );
  }

  Widget _buildTestButton(
      BuildContext context, TranslationProvider provider, Color accentColor) {
    return Center(
      child: OutlinedButton.icon(
        onPressed:
            provider.isTesting ? null : () => provider.testGloss('سبب رغبه شراء'),
        icon: provider.isTesting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.science_outlined, size: 18),
        label: const Text('Test Translation'),
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<AppLocaleProvider>();
    final bool isArabic = localeProvider.locale.languageCode == 'ar';
    final bool isDarkMode = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<TranslationProvider>();

    final Color scaffoldBg =
        isDarkMode ? const Color(0xFF121212) : AppColors.primaryWhite;
    final Color accentColor =
        isDarkMode ? const Color(0xFF4A90C4) : const Color(0xFF275878);
    final Color audioBorder = accentColor;
    final Color timerColor =
        isDarkMode ? Colors.grey.shade500 : Colors.grey;
    final Color waveInactiveColor =
        isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400;
    final Color boxBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  isArabic
                      ? _buildLanguagePicker(isDarkMode)
                      : ModernHamburgerIcon(
                          color: accentColor,
                          size: 28,
                          onTap: widget.onMenuTap ?? () {},
                        ),
                  const Spacer(),
                  const TafahomLogo(height: 22),
                  const Spacer(),
                  isArabic
                      ? ModernHamburgerIcon(
                          color: accentColor,
                          size: 28,
                          onTap: widget.onMenuTap ?? () {},
                        )
                      : _buildLanguagePicker(isDarkMode),
                ],
              ),
            ),
            TranslationModeToggle(
              isSignToText: true,
              onSignToText: () {},
              onTextToSign: () =>
                  Navigator.pushReplacementNamed(context, '/text-to-sign'),
            ),
            const SizedBox(height: 8),
            _buildTestButton(context, provider, accentColor),
            const SizedBox(height: 8),
            if (provider.isTesting)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (provider.error != null &&
                provider.currentText == null &&
                provider.status != TranslationStatus.error)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Large Camera Preview (approx 55-65%)
                    const Expanded(
                      flex: 6,
                      child: CameraWidget(),
                    ),
                    const SizedBox(height: 12),
                    
                    // Translation Result Card
                    const Expanded(
                      flex: 3,
                      child: TranslationWidget(),
                    ),
                    const SizedBox(height: 8),

                    // Connection Status Indicator & Errors
                    if (provider.isConnected ||
                        provider.status == TranslationStatus.translating ||
                        provider.status == TranslationStatus.connecting)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: provider.status == TranslationStatus.connecting
                                    ? Colors.orange
                                    : provider.status == TranslationStatus.translating
                                        ? Colors.amber
                                        : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              provider.status == TranslationStatus.connecting
                                  ? 'Connecting...'
                                  : provider.status == TranslationStatus.translating
                                      ? 'Translating...'
                                      : 'Connected',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (provider.status == TranslationStatus.error && provider.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    // Compact Audio Player
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: boxBg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: audioBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: provider.currentText != null
                                ? () => _toggleSpeak(provider)
                                : null,
                            icon: Icon(
                              provider.isSpeaking
                                  ? Icons.stop_circle_rounded
                                  : Icons.play_circle_fill,
                              color: provider.currentText != null ? accentColor : Colors.grey,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 24,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(20, (i) {
                                  double height = provider.isSpeaking
                                      ? 5 + _random.nextInt(16).toDouble()
                                      : 6 + (i % 5 * 1.5).toDouble();
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    width: 3,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: provider.isSpeaking ? accentColor : waveInactiveColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDuration(_secondsElapsed),
                            style: TextStyle(
                              color: timerColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.volume_up, color: timerColor, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
