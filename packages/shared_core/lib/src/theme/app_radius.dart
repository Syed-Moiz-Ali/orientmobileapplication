import 'package:flutter/widgets.dart';

/// Spec-C5 radius scale (phase-0b, additive).
///
/// [AppDimensions] keeps its existing radius constants untouched; new work
/// uses these spec names. Cards 16–20, inputs 12, buttons pill, chips pill,
/// dialogs 20, bottom sheets top 28, images 12–16, avatars circle.
abstract final class AppRadius {
  AppRadius._();

  /// 6px extra-small controls, badges.
  static const double xs = 6;

  /// 8px small tags, filter chips.
  static const double sm = 8;

  /// 12px inputs, images.
  static const double md = 12;

  /// 16px cards.
  static const double lg = 16;

  /// 20px large cards, dialogs.
  static const double xl = 20;

  /// 28px bottom sheets (top), extra-large.
  static const double xxl = 28;

  /// Fully rounded pills, status badges, avatars.
  static const double pill = 999;

  // -- Semantic aliases (spec C5 component mapping) --------------------------

  static const double card = 16;
  static const double cardLarge = 20;
  static const double input = 12;
  static const double button = pill;
  static const double chip = pill;
  static const double dialog = 20;
  static const double sheetTop = 28;
  static const double image = 12;

  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get dialogRadius => BorderRadius.circular(dialog);
}
