import 'package:flutter/material.dart';
import '../../models/register_request.dart';
import '../../services/auth_service.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0E15), // Very dark navy background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section with Back Button, Header and Progress
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: const BoxDecoration(
                  color: Color(0xFF141522), // Slightly lighter top section
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1F2E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join thousands using\nMiniTransfer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7E8494),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Progress Indicator Dots
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252836),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFF252836),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 1 OF 3 — PERSONAL INFO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7E8494).withValues(alpha: 0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      fillColor: const Color(0xFF181926),
                      textColor: Colors.white,
                      labelColor: const Color(0xFF7E8494),
                      iconColor: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 24),
                    
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      fillColor: const Color(0xFF181926),
                      textColor: Colors.white,
                      labelColor: const Color(0xFF7E8494),
                      iconColor: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Phone Number',
                      hint: '6XX XXX XXX',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      prefix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1F2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+237',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      fillColor: const Color(0xFF181926),
                      textColor: Colors.white,
                      labelColor: const Color(0xFF7E8494),
                      iconColor: const Color(0xFF6C63FF),
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Password',
                      hint: 'Min. 8 characters',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      fillColor: const Color(0xFF181926),
                      textColor: Colors.white,
                      labelColor: const Color(0xFF7E8494),
                      iconColor: const Color(0xFF6C63FF),
                    ),

                    const SizedBox(height: 12),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    const SizedBox(height: 32),
                    
                    CustomButton(
                      label: 'Continue',
                      onPressed: _register,
                      isLoading: _isLoading,
                      gradient: const [
                        Color(0xFF6C63FF),
                        Color(0xFF928DFF),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Color(0xFF7E8494)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
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
  }
}
