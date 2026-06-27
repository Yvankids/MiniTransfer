import 'package:flutter/material.dart';
import '../../models/login_request.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'welcome': 'Welcome back',
      'signin_to': 'Sign in to MiniTransfer',
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot password?',
      'signin': 'Sign In',
      'or_continue': 'or continue with',
      'google': 'Google',
      'apple': 'Apple',
      'no_account': "Don't have an account? ",
      'register': 'Register',
    },
    'fr': {
      'welcome': 'Bon retour',
      'signin_to': 'Connectez-vous à MiniTransfer',
      'email': 'Email',
      'password': 'Mot de passe',
      'forgot_password': 'Mot de passe oublié ?',
      'signin': 'Se Connecter',
      'or_continue': 'ou continuer avec',
      'google': 'Google',
      'apple': 'Apple',
      'no_account': "Vous n'avez pas de compte ? ",
      'register': "S'inscrire",
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.login(LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, child) {
        final lang = locale.languageCode;
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const LogoWidget(size: 64),
                            IconButton(
                              onPressed: () => ThemeService.toggleTheme(),
                              icon: Icon(
                                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _get('welcome', lang),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _get('signin_to', lang),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: _get('email', lang),
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 24),
                        CustomTextField(
                          label: _get('password', lang),
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              _get('forgot_password', lang),
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        
                        if (_error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        CustomButton(
                          label: _get('signin', lang),
                          onPressed: _login,
                          isLoading: _isLoading,
                          gradient: const [
                            Color(0xFF6C63FF),
                            Color(0xFF928DFF),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.2))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _get('or_continue', lang),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: theme.dividerColor.withOpacity(0.2))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.g_mobiledata, color: theme.colorScheme.onSurface, size: 28),
                                label: Text(_get('google', lang), style: TextStyle(color: theme.colorScheme.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.apple, color: theme.colorScheme.onSurface, size: 22),
                                label: Text(_get('apple', lang), style: TextStyle(color: theme.colorScheme.onSurface)),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_get('no_account', lang), style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/register'),
                              child: Text(
                                _get('register', lang),
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
