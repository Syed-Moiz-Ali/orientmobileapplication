import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';

class AdvisorFab extends StatelessWidget {
  final VoidCallback onTap;
  const AdvisorFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navy, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.canvas, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.40),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
          SizedBox(height: 1),
          Text(
            'SCAN',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    ),
  );
}
