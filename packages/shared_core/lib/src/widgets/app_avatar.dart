import 'package:flutter/material.dart';

/// Spec-C8 avatar (phase-1c-ii).
///
/// Circle in 24 / 32 / 40 / 56 with initials on a pale brand tint, optional
/// image with initials fallback. Name verified free in `src/widgets/` (no
/// legacy `AppAvatar`); no rename needed.
///
/// ```dart
/// AppAvatar(name: 'Layla Haddad', size: AppAvatarSize.medium)
/// AppAvatar(name: 'Omar', image: NetworkImage(url), onTap: openProfile)
/// ```
///
/// - Tokens only: fill `ColorScheme.primaryContainer`, ink
///   `ColorScheme.onPrimaryContainer` (the theme's pale-brand pair; measured
///   7.1+:1 light / 10.5+:1 dark in the identity tests). Caller text only.
/// - Display-only by default; with [onTap] the avatar is a >= 48 dp circular
///   button with a Semantics label. Initials wrap safe at text scale 1.3x.
enum AppAvatarSize {
  extraSmall(24),
  small(32),
  medium(40),
  large(56);

  final double diameter;
  const AppAvatarSize(this.diameter);
}

class AppAvatar extends StatelessWidget {
  final String name;
  final AppAvatarSize size;
  final ImageProvider? image;
  final String? initials;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = AppAvatarSize.medium,
    this.image,
    this.initials,
    this.onTap,
    this.semanticLabel,
  });

  static String _mono(String word) => String.fromCharCode(word.runes.first);

  static String deriveInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return _mono(parts.first).toUpperCase();
    return (_mono(parts[0]) + _mono(parts[1])).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = initials ?? deriveInitials(name);
    final d = size.diameter;

    Widget face = Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        // Fixed circle: ellipsis (not wrap) keeps long custom initials
        // inside the diameter at 1.3x instead of overflowing.
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontSize: d * 0.36,
              fontWeight: FontWeight.w600,
            ),
      ),
    );

    if (image != null) {
      face = ClipOval(
        child: Image(
          image: image!,
          width: d,
          height: d,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => face,
        ),
      );
    }

    if (onTap == null) {
      return Semantics(
        label: semanticLabel ?? name,
        image: image != null,
        child: face,
      );
    }
    // 48 dp target via symmetric padding (never Center/Align: those expand
    // to the full line inside a Wrap and pushed the avatar full-width).
    final pad = d < 48 ? (48.0 - d) / 2 : 0.0;
    return Semantics(
      button: true,
      label: semanticLabel ?? name,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(padding: EdgeInsets.all(pad), child: face),
      ),
    );
  }
}
