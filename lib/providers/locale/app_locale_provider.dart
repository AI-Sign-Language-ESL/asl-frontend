import 'package:flutter/material.dart';
import '../../core/utils/shared_prefs_helper.dart';

/// Locale provider with Arabic RTL support and persistence
class AppLocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isRtl => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  /// Initialize locale from persisted settings
  Future<void> init() async {
    final savedLocale = await SharedPrefsHelper.getLocale();
    _locale = Locale(savedLocale);
    notifyListeners();
  }

  /// Set locale (en or ar)
  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      await SharedPrefsHelper.saveLocale(newLocale.languageCode);
      notifyListeners();
    }
  }

  /// Switch to Arabic
  Future<void> switchToArabic() async {
    await setLocale(const Locale('ar'));
  }

  /// Switch to English
  Future<void> switchToEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    if (isRtl) {
      await switchToEnglish();
    } else {
      await switchToArabic();
    }
  }
}
