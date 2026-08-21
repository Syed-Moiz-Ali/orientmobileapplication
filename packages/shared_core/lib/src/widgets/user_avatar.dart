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
    this.size = 40,
    this.borderWidth = 1,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? colors.outline,
          width: borderWidth,
        ),
      ),
      child: Text(
        initials,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor ?? colors.onPrimaryContainer,
          fontSize: size * 0.36,
        ),
      ),
    );

    if (onTap == null) return avatar;
    return Semantics(
      button: true,
      label: 'Open profile',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: avatar),
      ),
    );
  }
}
