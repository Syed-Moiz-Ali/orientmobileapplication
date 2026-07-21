import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

class AdvisorMetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const AdvisorMetaPill({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r20)),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.55), size: 11),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}
