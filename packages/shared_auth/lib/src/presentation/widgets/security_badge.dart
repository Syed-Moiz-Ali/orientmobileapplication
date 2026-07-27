import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      'By signing in, you agree to our Terms of Service & Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: isDark ? const Color(0xFF64748B) : AppColors.text4,
        height: 1.4,
      ),
    );
  }
}
