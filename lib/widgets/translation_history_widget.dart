import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/translation_provider.dart';
import '../providers/theme/app_theme_provider.dart';

class TranslationHistoryWidget extends StatelessWidget {
  const TranslationHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppThemeProvider>().isDarkMode;
    final provider = context.watch<TranslationProvider>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (provider.history.isEmpty) return const SizedBox.shrink();

    final Color boxBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color boxBorder =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFD5EBF5);

    return Container(
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: boxBorder, width: 2.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        context.read<TranslationProvider>().clearHistory(),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark
                                ? const Color(0xFF4A90C4)
                                : const Color(0xFF275878))
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final entry = provider.history[index];
                  final timeStr =
                      '${entry.timestamp.hour}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isArabic
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (entry.gloss.isNotEmpty)
                                Text(
                                  entry.gloss,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black45,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              Text(
                                entry.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white30 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
