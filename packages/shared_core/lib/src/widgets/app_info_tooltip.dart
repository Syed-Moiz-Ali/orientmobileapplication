import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_shadows.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

// 1c-ii: popover max width.
const double _kPopoverMaxWidth = 280;

/// Spec-C8 info tooltip (phase-1c-ii).
///
/// A 16 px "i" icon with a >= 48 dp hit area that opens a small popover
/// (radius 12, shadow e2 in light, 1 px border in dark, max width 280).
/// Tap opens; barrier tap dismisses (while open the barrier covers the
/// icon, so a second tap lands on the barrier via onDismiss).
///
/// ```dart
/// Row(children: [Text('Watching'), AppInfoTooltip(message: 'Why text.')])
/// ```
///
/// - Keyboard-focusable via optional [focusNode] (tap does not request
///   focus); screen-reader label ([semanticLabel], default `More info`)
///   plus a live-region announcement of [message]. Caller text only.
/// - Centered-below anchor for LTR and RTL (tests + RTL captures).
///   Text scale 1.3x wraps, never clips.
class AppInfoTooltip extends StatefulWidget {
  final String message;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final IconData icon;

  const AppInfoTooltip({
    super.key,
    required this.message,
    this.semanticLabel,
    this.focusNode,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  State<AppInfoTooltip> createState() => _AppInfoTooltipState();
}

class _AppInfoTooltipState extends State<AppInfoTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  late final FocusNode _node;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _remove();
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  bool get _open => _entry != null;

  void _toggle() {
    if (_open) {
      _remove();
    } else {
      _entry = OverlayEntry(
        builder: (ctx) => Stack(
          children: [
            ModalBarrier(color: Colors.transparent, onDismiss: _remove),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomCenter,
              followerAnchor: Alignment.topCenter,
              offset: const Offset(0, AppSpacing.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kPopoverMaxWidth),
                child: _popover(ctx),
              ),
            ),
          ],
        ),
      );
      Overlay.of(context).insert(_entry!);
    }
  }

  void _remove() {
    _entry?.remove();
    _entry = null;
  }

  Widget _popover(BuildContext ctx) {
    final scheme = Theme.of(ctx).colorScheme;
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: dark ? Border.all(color: scheme.outline) : null,
          boxShadow: dark ? null : AppShadows.e2,
        ),
        child: Semantics(
          liveRegion: true,
          label: widget.message,
          child: ExcludeSemantics(
            child: Text(
              // Bidi-isolated (U+2066…U+2069) so edge punctuation
              // (e.g. the trailing period) never migrates in RTL.
              '\u2066${widget.message}\u2069',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: widget.semanticLabel ?? 'More information',
      child: CompositedTransformTarget(
        link: _link,
        child: InkWell(
          onTap: _toggle,
          focusNode: _node,
          customBorder: const CircleBorder(),
          // Exact 48 x 48 via padding (16 + 16 glyph + 16), no Center.
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ExcludeSemantics(
              child: Icon(
                widget.icon,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
