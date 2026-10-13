import 'package:flutter/widgets.dart';

/// A value that exists in both review locales (credible Gulf-workshop data,
/// never "Lorem ipsum" / "John Doe" - Phase 00 §B fixture rule).
class LocalizedText {
  final String en;
  final String ar;

  const LocalizedText(this.en, this.ar);

  String of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}
