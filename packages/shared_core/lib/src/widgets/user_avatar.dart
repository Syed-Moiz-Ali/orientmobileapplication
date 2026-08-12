import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 34,
    this.borderWidth = 1.5,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.20),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.5),
          width: borderWidth,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: foregroundColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.44,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
}
