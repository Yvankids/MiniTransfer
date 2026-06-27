import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  // ValueNotifier to allow widgets to listen to language changes
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey) ?? 'en';
    localeNotifier.value = Locale(langCode);
  }

  static Future<void> changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
    localeNotifier.value = Locale(langCode);
  }

  static String get currentLanguage => localeNotifier.value.languageCode;
}
