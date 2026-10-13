import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// A menu row for advisor sheets, built on the shared record-row grammar.
class AdvisorMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  final bool showChevron;
  const AdvisorMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final c = color ?? colors.onSurface;
    return AppRecordRow(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
        ),
        child: Icon(icon, color: c, size: 17),
      ),
      title: label,
      onTap: onTap,
      trailing: showChevron
          ? DirectionalIcon(
              Icons.chevron_right_rounded,
              color: colors.outlineVariant,
              size: 18,
            )
          : const SizedBox.shrink(),
    );
  }
}
