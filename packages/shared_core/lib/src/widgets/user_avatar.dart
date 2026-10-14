import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Circular identity avatar with Concept A chamfered-ring treatment.
///
/// Supports an optional presence dot (bottom-trailing) and a role-coloured
/// border ring. Falls back to initials when no image is supplied.
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final double borderWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  /// Renders a small presence indicator at the bottom-trailing corner.
  final bool showOnlineDot;

  /// Colour of the presence dot. Defaults to Precision Emerald.
  final Color? onlineDotColor;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.borderWidth = 1,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.onTap,
    this.showOnlineDot = false,
    this.onlineDotColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final dotColor = onlineDotColor ?? semantic.success.base;
    final dotSize = (size * 0.28).clamp(10.0, 16.0);

    Widget avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? semantic.primarySubtle,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? semantic.borderStrong,
          width: borderWidth,
        ),
      ),
      child: Text(
        initials,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor ?? colors.primary,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );

    if (showOnlineDot) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: semantic.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final result = SizedBox(
      width: size,
      height: size,
      child: avatar,
    );

    if (onTap == null) return result;
    return Semantics(
      button: true,
      label: SharedCoreL10n.of(context).userAvatarOpenProfile,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: result),
      ),
    );
  }
}
