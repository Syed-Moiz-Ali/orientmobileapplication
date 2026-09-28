import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppDimensions.r9),
        ),
        child: Icon(icon, color: c, size: 17),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: 0.2,
        ),
      ),
      trailing: showChevron
          ? Icon(Icons.chevron_right_rounded, color: colors.outlineVariant, size: 18)
          : null,
      onTap: onTap,
    );
  }
}
