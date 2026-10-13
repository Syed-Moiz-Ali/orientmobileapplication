import 'package:flutter/material.dart';

/// Central interaction-state grammar for the ORIENT control catalog.
///
/// Phase 03A accessibility correction: Material's default state layer is tinted
/// with the control's *ink*, which for white-ink fills *lightens* the fill on
/// hover/press and therefore *lowers* label contrast. That pushed the light
/// danger button's pressed state to ≈4.21:1 (below WCAG AA 4.5:1).
///
/// This helper instead derives every enabled interaction overlay from the
/// **opposite of the ink** — dark overlays for light-ink controls, light
/// overlays for dark-ink controls — so composited contrast always *increases*
/// in hover/pressed/focus states. It also matches the frozen `primaryHover`
/// (`#2848B8`) / `primaryPressed` (`#203B9E`) tokens, which darken the cobalt
/// fill on interaction.
///
/// Every button/control in `shared_core` (and the Material button themes)
/// resolves its overlays and focus ring through this class so the behavior is
/// consistent and provable in one place (`app_interaction_states_test.dart`).
abstract final class AppInteractionStates {
  AppInteractionStates._();

  /// Alpha applied for the hovered state (spec §10 desktop hover tint).
  static const double hoverAlpha = 0.08;

  /// Alpha applied for the focused state.
  static const double focusAlpha = 0.10;

  /// Alpha applied for the pressed state.
  static const double pressedAlpha = 0.12;

  /// Width of the visible focus indicator (spec §8.4).
  static const double focusRingWidth = 2;

  /// The overlay tone that always increases label contrast for [ink]: black on
  /// light inks, white on dark inks.
  static Color contrastOverlayTone(Color ink) =>
      ink.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  /// State-layer overlays composited over the control [fill] and resolving
  /// against the control [ink] so label contrast never drops below its rest
  /// value. Only enabled interaction states receive an overlay; disabled is
  /// handled by the control's disabled colors.
  static WidgetStateProperty<Color?> overlays(Color fill, Color ink) {
    final tone = contrastOverlayTone(ink);
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return tone.withValues(alpha: pressedAlpha);
      }
      if (states.contains(WidgetState.focused)) {
        return tone.withValues(alpha: focusAlpha);
      }
      if (states.contains(WidgetState.hovered)) {
        return tone.withValues(alpha: hoverAlpha);
      }
      return null;
    });
  }

  /// 2 px focus indicator ring resolved only for the focused state (spec §8.4).
  static WidgetStateProperty<BorderSide?> focusRing(Color ring) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(color: ring, width: focusRingWidth);
      }
      return null;
    });
  }
}
