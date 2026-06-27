import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'is_dark_mode';
  
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true; // Default to dark
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = themeNotifier.value == ThemeMode.dark;
    await prefs.setBool(_themeKey, !isDark);
    themeNotifier.value = !isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
}
