import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorDetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdvisorDetailLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      children: [
        Icon(icon, size: 14, color: AppColors.text3),
        const SizedBox(width: 9),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.text2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    ),
  );
}
