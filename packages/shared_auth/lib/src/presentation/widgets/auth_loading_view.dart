import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthLoadingView extends StatelessWidget {
  const AuthLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = BrandConfig.orient;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: brand.accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: brand.accentColor.withValues(alpha: 0.28),
                ),
              ),
              child: Icon(brand.icon, color: brand.accentColor, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              brand.appName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: brand.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
