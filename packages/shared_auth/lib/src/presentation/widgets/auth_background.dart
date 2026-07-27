import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final BrandConfig brand;

  const AuthBackground({
    super.key,
    required this.child,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF090D16) : Colors.white,
      child: SafeArea(
        child: child,
      ),
    );
  }
}
