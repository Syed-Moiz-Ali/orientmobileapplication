import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_avatar.dart';

/// C16 profile header (phase-1P).
///
/// Large avatar ([AppAvatar], 56) + name + optional subtitle + optional
/// trailing action. Sits directly on the page surface (never inside a
/// card); the account rows below live in an [AppListGroup].
///
/// ```dart
/// AppProfileHeader(
///   name: 'Layla Haddad',
///   subtitle: 'layla@example.com',
///   trailing: AppTextButton(label: 'Edit', onPressed: editProfile),
/// )
/// ```
///
/// - Tokens only, caller-supplied text. Name is titleLarge with header
///   Semantics; subtitle is bodyMedium muted.
/// - Trailing action keeps its own tap target/Semantics (caller widget).
/// - 1.3x-safe: the text column is Expanded and wraps; the avatar and the
///   trailing action keep their width.
class AppProfileHeader extends StatelessWidget {
  /// Display name (titleLarge, header Semantics).
  final String name;

  /// Supporting line under the name, e.g. email (bodyMedium, muted).
  final String? subtitle;

  /// Avatar image. Initials fall back to [name].
  final ImageProvider? image;

  /// Optional trailing action (e.g. an Edit button).
  final Widget? trailing;

  /// Optional avatar tap (makes the avatar a >= 48 dp button).
  final VoidCallback? onAvatarTap;

  /// Overrides the header's Semantics label (defaults to [name]).
  final String? semanticLabel;

  const AppProfileHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.image,
    this.trailing,
    this.onAvatarTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel ?? name,
      container: true,
      child: Row(
        children: [
          AppAvatar(
            name: name,
            size: AppAvatarSize.large,
            image: image,
            onTap: onAvatarTap,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    '\u2066$name\u2069',
                    style: textTheme.titleLarge,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '\u2066$subtitle\u2069',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(child: trailing!),
          ],
        ],
      ),
    );
  }
}
