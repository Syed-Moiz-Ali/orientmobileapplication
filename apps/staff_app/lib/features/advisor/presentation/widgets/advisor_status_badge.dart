import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const AdvisorStatusBadge(this.label, this.color, this.bg, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimensions.r7),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.3,
      ),
    ),
  );
}

