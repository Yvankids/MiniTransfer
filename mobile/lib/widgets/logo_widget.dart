import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 48,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Redesigned Geometric Logo - Not AI looking
          // Background soft shape
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(size * 0.15),
              ),
            ),
          ),
          // Main brand shape
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF928DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size * 0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: size * 0.2,
                    offset: Offset(0, size * 0.08),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: showText
                  ? Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: size * 0.35,
                      ),
                    )
                  : null,
            ),
          ),
          // Accent line/element to make it look like a transfer
          Positioned(
            top: size * 0.3,
            left: size * 0.2,
            child: Container(
              width: size * 0.25,
              height: size * 0.05,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(size),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
