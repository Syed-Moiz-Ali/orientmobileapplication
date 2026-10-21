import 'package:flutter/material.dart';

/// An [Icon] that mirrors horizontally in right-to-left layouts.
///
/// Use for direction-sensitive glyphs only: back/forward arrows, chevrons,
/// undo/redo, send, and timeline progression. Non-directional icons (clock,
/// person, document, search, bell) must keep using a plain [Icon] — they never
/// flip.
///
/// The flip is implemented with [Transform.flip] so it works regardless of
/// whether the underlying glyph declares `matchTextDirection`. The inner
/// [Icon] is pinned to [TextDirection.ltr] so glyphs that DO declare
/// `matchTextDirection` (arrow_forward_rounded, arrow_back_rounded,
/// send_rounded, chevrons, …) don't self-mirror underneath the manual flip —
/// without the pin the two mirrors cancel out and the glyph renders
/// unmirrored in RTL (phase-2 F-6).
class DirectionalIcon extends StatelessWidget {
  /// Glyphs whose meaning is tied to reading direction. Used by the button
  /// system to flip only direction-sensitive icons automatically.
  static final Set<IconData> directionalGlyphs = <IconData>{
    Icons.arrow_back,
    Icons.arrow_back_rounded,
    Icons.arrow_back_ios,
    Icons.arrow_back_ios_rounded,
    Icons.arrow_forward,
    Icons.arrow_forward_rounded,
    Icons.arrow_forward_ios,
    Icons.arrow_forward_ios_rounded,
    Icons.arrow_outward_rounded,
    Icons.chevron_left,
    Icons.chevron_left_rounded,
    Icons.chevron_right,
    Icons.chevron_right_rounded,
    Icons.undo_rounded,
    Icons.redo_rounded,
    Icons.send_rounded,
    Icons.login_rounded,
    Icons.logout_rounded,
    Icons.subdirectory_arrow_right_rounded,
    Icons.trending_flat_rounded,
  };

  /// True when [icon] is a direction-sensitive glyph that should mirror in RTL.
  static bool isDirectional(IconData icon) => directionalGlyphs.contains(icon);

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  /// When false the icon never mirrors (used by the documented damage-map
  /// exception where physical orientation is canonical).
  final bool mirrorInRtl;

  const DirectionalIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.mirrorInRtl = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final Widget child = Icon(
      icon,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      // Pin the glyph to LTR: self-mirroring glyphs must not pre-flip, or
      // the Transform below would un-mirror them in RTL. Non-directional
      // icons keep mirrorInRtl: false and so never flip either way.
      textDirection: TextDirection.ltr,
    );
    if (!mirrorInRtl || !rtl) return child;
    return Transform.flip(flipX: true, child: child);
  }
}
