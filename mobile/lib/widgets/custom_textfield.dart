import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? iconColor;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefix,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.iconColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use provided colors or fallback to theme-aware defaults
    final effectiveLabelColor = widget.labelColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    final effectiveFillColor = widget.fillColor ?? (isDark ? const Color(0xFF181926) : const Color(0xFFF0F1F7));
    final effectiveTextColor = widget.textColor ?? theme.colorScheme.onSurface;
    final effectiveIconColor = widget.iconColor ?? theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: effectiveLabelColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          style: TextStyle(color: effectiveTextColor),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: effectiveTextColor.withOpacity(0.3)),
            prefixIcon: widget.prefixIcon != null 
                ? Icon(widget.prefixIcon, color: effectiveIconColor) 
                : null,
            prefix: widget.prefix,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: effectiveTextColor.withOpacity(0.4),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            filled: true,
            fillColor: effectiveFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: effectiveIconColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }
}
