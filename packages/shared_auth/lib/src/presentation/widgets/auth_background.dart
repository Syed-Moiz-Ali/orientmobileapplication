import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const AuthBackground({
    super.key,
    required this.child,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: accentColor.withValues(alpha: 0.28),
                width: 3,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
