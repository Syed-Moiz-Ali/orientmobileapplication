import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// C16 sticky bottom action bar (phase-1P).
///
/// Detail/checkout grammar: summary/status widget on the `start` side (price,
/// status, [AppSummaryRow]), ONE primary CTA on the `end` side. The row
/// mirrors in RTL automatically.
///
/// ```dart
/// AppStickyActionBar(
///   summary: AppSummaryRow(label: 'Total', value: 'AED 240.00'),
///   ctaLabel: 'Continue',
///   onCta: checkout,
/// )
/// ```
///
/// - SINGLE-CTA RULE (C9/C16): this bar owns exactly one primary button —
///   the screen's single primary focus. Secondary or destructive actions
///   belong in the content, a bottom sheet, or an overflow menu, never as a
///   second button here. There is deliberately no `secondaryLabel` slot
///   (unlike the legacy frame bar); if a design asks for one, that is a
///   spec violation to raise in review, not a parameter to add.
/// - Tokens only, caller-supplied text, Directional-safe.
/// - Keyboard-safe: pads for `viewInsets.bottom` so the CTA stays above the
///   keyboard; safe-area aware (`SafeArea(top: false)`).
/// - Surface fill with a top hairline (`outline`); no shadow, no border
///   around the whole bar.
/// - The CTA is [AppPillButtonSize.medium] intrinsic width (min 88, >= 48 dp
///   hit); [isLoading] keeps its width (spinner overlays the label).
/// - Wraps at text scale 1.3x: [summary] flexes, the CTA keeps its size;
///   callers keep both strings short (one line each).
class AppStickyActionBar extends StatelessWidget {
  /// Summary/status content on the `start` side (e.g. [AppSummaryRow]).
  final Widget summary;

  /// Primary CTA label (caller-supplied, l10n).
  final String ctaLabel;

  /// Primary CTA callback. Null disables the CTA (40 % opacity, no tap).
  final VoidCallback? onCta;

  /// Pass-through to the CTA loading state (width preserved, taps ignored).
  final bool isLoading;

  const AppStickyActionBar({
    super.key,
    required this.summary,
    required this.ctaLabel,
    required this.onCta,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg) +
              EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
          child: Row(
            children: [
              Expanded(child: summary),
              const SizedBox(width: AppSpacing.md),
              Flexible(
                child: AppPillButton.primary(
                  label: ctaLabel,
                  onPressed: onCta,
                  size: AppPillButtonSize.medium,
                  isExpanded: false,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
