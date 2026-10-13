import 'package:flutter/widgets.dart';

/// Motion tokens of the ORIENT design system.
///
/// Only these durations and curves may be used by shared widgets and feature
/// screens (spec §11): `instant 100` (state snaps), `fast 160` (hover, chip,
/// badge), `standard 220` (sheets, page transitions, list insert),
/// `emphasized 280` (hero/step transitions). Nothing animates longer than
/// 280 ms. Loading shimmer is exempt but must pause under reduced motion.
abstract final class AppMotion {
  AppMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 280);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standardCurve = Curves.easeInOutCubic;

  /// True when the platform asks for reduced motion
  /// (`MediaQuery.disableAnimations`, which reflects the OS accessibility
  /// setting). Shared widgets must collapse every transition to instant when
  /// this is true (spec §8.6).
  static bool reducedMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Resolves a token [duration] against the platform reduced-motion
  /// preference: returns [duration] normally, or [Duration.zero] when the
  /// user asked for reduced motion.
  ///
  /// Usage: `duration: AppMotion.resolve(context, AppMotion.fast)`.
  static Duration resolve(BuildContext context, Duration duration) =>
      reducedMotion(context) ? Duration.zero : duration;
}
