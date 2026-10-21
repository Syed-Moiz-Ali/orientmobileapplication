import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_motion.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// C16 step-flow shell (phase-1P).
///
/// One task per screen: thin progress bar on top, back arrow (auto-mirrors
/// RTL via [AppIconButton]), big start-aligned question headline
/// (`headlineLarge`, bold, exposed as a Semantics header), one supporting
/// subtitle line, caller content, and a STICKY bottom bar with ONE
/// full-width [AppPillButton.primary] (52, label/onPressed/isLoading passed
/// through).
///
/// ```dart
/// AppStepScaffold(
///   step: 1,
///   totalSteps: 3,
///   backLabel: 'Back',
///   onBack: back,
///   title: "What's your phone number?",
///   subtitle: 'We will send a confirmation code.',
///   ctaLabel: 'Continue',
///   onCta: next,
///   isLoading: false,
///   child: AppInputField(label: 'Phone number'),
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (headline aligns to
///   `start`, the step slide enters from the `end` side, so RTL mirrors).
/// - Progress is EITHER [progress] (0.0–1.0, clamped) OR [step]/[totalSteps]
///   (1-based; `step / totalSteps`), never both — the assert enforces it.
/// - Step changes animate with a subtle horizontal slide + fade over
///   [AppMotion.standard] (220 ms, inside the 200–300 ms C16 window) on the
///   [AppMotion.enter] ease-out curve; under reduced motion the switch is
///   static ([Duration.zero] via [AppMotion.resolve]). The transition key
///   defaults to the step/progress value; pass [stepKey] to override.
/// - Keyboard-safe (`resizeToAvoidBottomInset` + the sticky bar pads for
///   `viewInsets.bottom`) and safe-area aware. The headline scrolls with
///   the content (progress + back stay pinned), so short viewports
///   (keyboard up, landscape) shrink the scroll area instead of
///   overflowing a fixed header.
/// - Single-CTA rule (C16): this bar owns the screen's ONE primary action.
///   Secondary paths ("Use password instead", "Resend") live in the content
///   or a sheet, never next to this button.
/// - [onBack] null hides the back arrow (first step); otherwise the arrow is
///   a >= 48 dp target with a screen-reader label ([backLabel]).
/// - Text scale 1.3x: headline/subtitle wrap, header + content scroll as
///   one, CTA keeps width when busy.
class AppStepScaffold extends StatelessWidget {
  /// Direct progress value, 0.0–1.0 (clamped). Mutually exclusive with
  /// [step]/[totalSteps].
  final double? progress;

  /// 1-based current step. Requires [totalSteps].
  final int? step;

  /// Total step count. Requires [step].
  final int? totalSteps;

  /// Screen-reader label for the back arrow (caller-supplied, l10n).
  final String backLabel;

  /// Back navigation. Null hides the back arrow (first step).
  final VoidCallback? onBack;

  /// Question headline, e.g. "What's your phone number?".
  final String title;

  /// One supporting line under the headline.
  final String? subtitle;

  /// Step content (input, code field, one field group, ...).
  final Widget child;

  /// Sticky CTA label, e.g. "Continue".
  final String ctaLabel;

  /// Sticky CTA callback. Null disables the CTA (40 % opacity, no tap).
  final VoidCallback? onCta;

  /// Pass-through to the sticky CTA loading state (width preserved).
  final bool isLoading;

  /// Transition key override for the animated content switch.
  final Key? stepKey;

  /// Optional accessible name for the progress meter.
  final String? progressSemanticLabel;

  const AppStepScaffold({
    super.key,
    this.progress,
    this.step,
    this.totalSteps,
    required this.backLabel,
    this.onBack,
    required this.title,
    this.subtitle,
    required this.child,
    required this.ctaLabel,
    required this.onCta,
    this.isLoading = false,
    this.stepKey,
    this.progressSemanticLabel,
  }) : assert(
          (progress != null) != (step != null && totalSteps != null),
          'AppStepScaffold: pass either progress (0..1) or step + totalSteps.',
        );

  double _effectiveProgress() {
    if (progress != null) return progress!.clamp(0.0, 1.0);
    assert(totalSteps! > 0, 'AppStepScaffold: totalSteps must be > 0.');
    return (step! / totalSteps!).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final effective = _effectiveProgress();
    final percent = (effective * 100).round();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              label: progressSemanticLabel,
              value: '$percent percent',
              child: ExcludeSemantics(
                child: Container(
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: effective,
                      child: Container(color: scheme.primary),
                    ),
                  ),
                ),
              ),
            ),
            if (onBack != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.sm,
                  top: AppSpacing.sm,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppIconButton(
                    icon: Icons.arrow_back,
                    onPressed: onBack,
                    tooltip: backLabel,
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration:
                    AppMotion.resolve(context, AppMotion.standard),
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                transitionBuilder: (Widget kid, Animation<double> animation) {
                  final begin = rtl
                      ? const Offset(-0.08, 0)
                      : const Offset(0.08, 0);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: begin,
                        end: Offset.zero,
                      ).animate(animation),
                      child: kid,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: stepKey ??
                      ValueKey<String>(
                        'step=$step/$totalSteps progress=$progress',
                      ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.xl,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: AppSpacing.screenPaddingPhone,
                        end: AppSpacing.screenPaddingPhone,
                        top: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              textAlign: TextAlign.start,
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle!,
                              style: textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          child,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.all(AppSpacing.lg) +
                    EdgeInsets.only(
                      bottom: MediaQuery.viewInsetsOf(context).bottom,
                    ),
            child: AppPillButton.primary(
              label: ctaLabel,
              onPressed: onCta,
              isLoading: isLoading,
            ),
          ),
        ),
      ),
    );
  }
}
