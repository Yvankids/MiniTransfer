import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/logo_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'title': 'Fast. Secure.\nSimple.',
      'subtitle': 'The modern way to transfer money across borders with zero hassle.',
      'debrief': 'MiniTransfer empowers you to send and receive funds instantly. Experience lightning-fast transactions with top-tier security encryption.',
      'getStarted': 'Get Started',
      'login': 'Sign In',
    },
    'fr': {
      'title': 'Rapide. Sûr.\nSimple.',
      'subtitle': 'La façon moderne de transférer de l\'argent sans tracas.',
      'debrief': 'MiniTransfer vous permet d\'envoyer et de recevoir des fonds instantanément. Profitez de transactions ultra-rapides avec une sécurité de pointe.',
      'getStarted': 'Commencer',
      'login': 'Se Connecter',
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        final langCode = locale.languageCode;
        
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeNotifier,
          builder: (context, themeMode, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: Stack(
                children: [
                  // Background Decorative Elements
                  Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                    ),
                  ),
                  
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Bar: Redesigned Logo + Toggles
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const LogoWidget(size: 48),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    onPressed: () => ThemeService.toggleTheme(),
                                  ),
                                  const SizedBox(width: 8),
                                  _LanguageToggle(
                                    currentLang: langCode,
                                    onChanged: (val) => LanguageService.changeLanguage(val ? 'en' : 'fr'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Content Section
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _get('title', langCode),
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.displayLarge?.color ?? Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _get('subtitle', langCode),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 18,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                                    boxShadow: [
                                      if (!isDark)
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                    ],
                                  ),
                                  child: Text(
                                    _get('debrief', langCode),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                                      fontSize: 14,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Action Buttons
                          CustomButton(
                            label: _get('getStarted', langCode),
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                            gradient: const [Color(0xFF6C63FF), Color(0xFF928DFF)],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                _get('login', langCode),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final String currentLang;
  final Function(bool) onChanged;

  const _LanguageToggle({required this.currentLang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'EN',
            isSelected: currentLang == 'en',
            onTap: () => onChanged(true),
          ),
          _ToggleItem(
            label: 'FR',
            isSelected: currentLang == 'fr',
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
