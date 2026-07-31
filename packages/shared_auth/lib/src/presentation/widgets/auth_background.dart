import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final BrandConfig brand;

  const AuthBackground({super.key, required this.child, required this.brand});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D16) : const Color(0xFFF7FAFC),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0A1220), Color(0xFF101A2B)]
              : const [Color(0xFFF9FCFD), Color(0xFFEFF7F8)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -80,
              child: _Glow(color: brand.accentColor, size: 280),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _Glow(color: brand.accentColor, size: 340),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 80,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}
