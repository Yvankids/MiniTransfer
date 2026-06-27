import 'package:flutter/material.dart';
import 'screens/login/login_screen.dart';
import 'screens/register/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/transfer/transfer_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.init();
  await ThemeService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp(
              title: 'MiniTransfer',
              debugShowCheckedModeBanner: false,
              locale: locale,
              themeMode: themeMode,
              // Light Theme
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: const Color(0xFF6C63FF),
                scaffoldBackgroundColor: const Color(0xFFF8F9FE),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6C63FF),
                  brightness: Brightness.light,
                  surface: Colors.white,
                  onSurface: const Color(0xFF1A1A2E),
                ),
                fontFamily: 'Roboto',
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF1A1A2E),
                  elevation: 0,
                ),
              ),
              // Dark Theme
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: const Color(0xFF6C63FF),
                scaffoldBackgroundColor: const Color(0xFF0D0E15),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6C63FF),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF141522),
                  onSurface: Colors.white,
                ),
                fontFamily: 'Roboto',
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF141522),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              home: const AppEntryResolver(),
              routes: {
                '/welcome': (context) => const WelcomeScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/transfer': (context) => const TransferScreen(),
                '/history': (context) => const HistoryScreen(),
              },
            );
          },
        );
      },
    );
  }
}

class AppEntryResolver extends StatelessWidget {
  const AppEntryResolver({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenStorage.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}
