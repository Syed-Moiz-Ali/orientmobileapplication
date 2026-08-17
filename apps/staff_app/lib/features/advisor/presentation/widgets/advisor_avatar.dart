import 'package:flutter/material.dart';

class AdvisorAvatar extends StatelessWidget {
  final String initials;
  final double size;
  const AdvisorAvatar({super.key, required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.30),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: colors.primary,
            fontWeight: FontWeight.w900,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
