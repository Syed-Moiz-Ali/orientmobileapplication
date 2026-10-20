import 'package:flutter/material.dart';

/// Focusable whole-row toggle wrapper (spec C8 rows + C12 keyboard, 1c-i).
///
/// Exactly one Semantics toggle node per row: [excludeSemantics] hides the
/// decorative inner switch, the row itself is the control. Whole-row tap via
/// [InkWell] (ripple + theme [focusColor] ring when keyboard-focused), and
/// keyboard activation (Enter/Space) fires [onTap] through the InkWell's
/// built-in [ActivateIntent] handler — no pointer needed.
class AppToggleRow extends StatelessWidget {
  final bool enabled;
  final bool toggled;
  final String label;
  final VoidCallback onTap;
  final Widget child;

  const AppToggleRow({
    super.key,
    required this.enabled,
    required this.toggled,
    required this.label,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: toggled,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          // Token focus ring (AppTheme sets focusColor from focusRing).
          focusColor: Theme.of(context).focusColor,
          child: child,
        ),
      ),
    );
  }
}
