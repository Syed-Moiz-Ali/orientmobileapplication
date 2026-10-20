import 'package:flutter/widgets.dart';

/// Spec-C7 motion durations (phase-0b, additive).
///
/// [AppMotion] stays authoritative for existing widgets (100/160/220/280ms);
/// new spec work uses these three steps. Page transitions: fade-through or
/// shared-axis at 250ms. Skeleton shimmer loops at 1200ms. Number changes
/// crossfade over 300ms. Press feedback: scale 0.98 + ripple/opacity.
/// Always respect reduced motion via `AppMotion.resolve`.
abstract final class AppDurations {
  AppDurations._();

  /// 150ms press feedback, micro state changes.
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms enter/exit, default transition.
  static const Duration normal = Duration(milliseconds: 200);

  /// 300ms number crossfades, emphasis.
  static const Duration slow = Duration(milliseconds: 300);

  /// Page transitions (fade-through / shared-axis).
  static const Duration pageTransition = Duration(milliseconds: 250);

  /// Skeleton shimmer loop.
  static const Duration shimmerLoop = Duration(milliseconds: 1200);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}
