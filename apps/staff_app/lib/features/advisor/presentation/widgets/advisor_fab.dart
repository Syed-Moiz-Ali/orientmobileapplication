import 'package:flutter/material.dart';

class AdvisorFab extends StatelessWidget {
  final VoidCallback onTap;
  const AdvisorFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.surface, width: 3),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              color: colors.onPrimary,
              size: 22,
            ),
            SizedBox(height: 1),
            Text(
              'SCAN',
              style: TextStyle(
                color: colors.onPrimary.withValues(alpha: 0.75),
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
}
