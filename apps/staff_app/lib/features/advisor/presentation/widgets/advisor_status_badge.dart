import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Compact status badge (legacy companion to [StatusPill]).
class AdvisorStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const AdvisorStatusBadge(this.label, this.color, this.bg, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.s8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}
