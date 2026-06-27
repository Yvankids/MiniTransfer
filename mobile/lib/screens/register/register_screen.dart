import 'package:flutter/material.dart';
import '../../models/register_request.dart';
import '../../services/auth_service.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  final Map<String, Map<String, String>> _localizedText = {
    'en': {
      'create': 'Create account',
      'join': 'Join thousands using\nMiniTransfer',
      'step': 'STEP 1 OF 3 — PERSONAL INFO',
      'name': 'Full Name',
      'email': 'Email Address',
      'phone': 'Phone Number',
      'password': 'Password',
      'password_hint': 'Min. 8 characters',
      'continue': 'Continue',
      'already': 'Already have an account? ',
      'login': 'Login',
    },
    'fr': {
      'create': 'Créer un compte',
      'join': 'Rejoignez des milliers d\'utilisateurs\nsur MiniTransfer',
      'step': 'ÉTAPE 1 SUR 3 — INFOS PERSONNELLES',
      'name': 'Nom complet',
      'email': 'Adresse Email',
      'phone': 'Numéro de téléphone',
      'password': 'Mot de passe',
      'password_hint': 'Min. 8 caractères',
      'continue': 'Continuer',
      'already': 'Vous avez déjà un compte ? ',
      'login': 'Connexion',
    }
  };

  String _get(String key, String langCode) {
    return _localizedText[langCode]![key]!;
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.register(RegisterRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
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
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1D1F2E) : const Color(0xFFF0F1F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface, size: 20),
                              ),
                            ),
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
                          _get('create', lang),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _get('join', lang),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 6,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF252836) : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF252836) : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _get('step', lang),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        CustomTextField(
                          label: _get('name', lang),
                          hint: 'John Doe',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: _get('email', lang),
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          label: _get('phone', lang),
                          hint: '6XX XXX XXX',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          prefix: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1D1F2E) : const Color(0xFFF0F1F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+237',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        CustomTextField(
                          label: _get('password', lang),
                          hint: _get('password_hint', lang),
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                        ),

                        const SizedBox(height: 12),
                        if (_error != null)
                          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                        const SizedBox(height: 32),
                        
                        CustomButton(
                          label: _get('continue', lang),
                          onPressed: _register,
                          isLoading: _isLoading,
                          gradient: const [Color(0xFF6C63FF), Color(0xFF928DFF)],
                        ),
                        
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _get('already', lang),
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                _get('login', lang),
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
