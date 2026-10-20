import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/app_icon_button.dart';
import 'package:shared_core/src/widgets/app_text_button.dart';

/// Banner variant for [AppBanner] (phase-1d-i).
enum AppBannerKind { info, warning, error, success }

/// Spec-C8 inline banner (phase-1d-i).
///
/// Full-width notice: icon + text on a `*Soft` fill with matching ink, plus
/// an optional text action and an optional dismiss button. Used for
/// offline / delayed-data / maintenance notices (C10). Announced through a
/// live region. Success uses `successStrongSoft` + `successStrongInk`
/// (never white on the success green — see phase-1a `successStrong`).
///
/// Name verified free (no legacy `AppBanner`); no rename needed.
///
/// ```dart
/// AppBanner(
///   kind: AppBannerKind.warning,
///   message: 'Data is delayed. Showing the last update from 2 min ago.',
///   actionLabel: 'Retry',
///   onAction: reload,
///   onDismiss: hide,
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (icon/action swap
///   sides in RTL). Icon and text both use the family *ink* (>= 4.5:1 on the
///   fill, exceeding the 3:1 non-text bar), so meaning is carried by icon +
///   label + ink, never color alone.
/// - Action is a real >= 48 dp text button; dismiss is a 48 dp icon button
///   (compact 20 px glyph, transparent fill). Wraps at text scale 1.3x.
/// - The message is bidi-isolated (U+2066…U+2069) so edge punctuation never
///   flips in RTL paragraphs (1d-i review); paragraph direction and
///   alignment still follow the locale.
///
/// Bidi-isolates [text] (U+2066…U+2069); see [AppStatTile] for the rationale.
String _isolate(String text) => '\u2066$text\u2069';

class AppBanner extends StatelessWidget {
  final AppBannerKind kind;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final String? dismissTooltip;
  final String? semanticLabel;

  const AppBanner({
    super.key,
    required this.kind,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissTooltip = 'Dismiss',
    this.semanticLabel,
  });

  Color _fill(BuildContext context) {
    final sem = context.semanticColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (kind) {
      case AppBannerKind.info:
        return sem.info.subtle;
      case AppBannerKind.warning:
        return sem.warning.subtle;
      case AppBannerKind.error:
        return sem.danger.subtle;
      case AppBannerKind.success:
        return dark
            ? AppDarkColors.successStrongSoft
            : AppColors.successStrongSoft;
    }
  }

  Color _border(BuildContext context) {
    final sem = context.semanticColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (kind) {
      case AppBannerKind.info:
        return sem.info.border;
      case AppBannerKind.warning:
        return sem.warning.border;
      case AppBannerKind.error:
        return sem.danger.border;
      case AppBannerKind.success:
        return dark
            ? AppDarkColors.successBorder
            : AppColors.successBorder;
    }
  }

  Color _ink(BuildContext context) {
    final sem = context.semanticColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (kind) {
      case AppBannerKind.info:
        return sem.info.ink;
      case AppBannerKind.warning:
        return sem.warning.ink;
      case AppBannerKind.error:
        return sem.danger.ink;
      case AppBannerKind.success:
        return dark
            ? AppDarkColors.successStrongInk
            : AppColors.successStrongInk;
    }
  }

  IconData _icon() {
    switch (kind) {
      case AppBannerKind.info:
        return Icons.info_outline_rounded;
      case AppBannerKind.warning:
        return Icons.warning_amber_rounded;
      case AppBannerKind.error:
        return Icons.error_outline_rounded;
      case AppBannerKind.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _kindWord() {
    switch (kind) {
      case AppBannerKind.info:
        return 'Information';
      case AppBannerKind.warning:
        return 'Warning';
      case AppBannerKind.error:
        return 'Error';
      case AppBannerKind.success:
        return 'Success';
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fill = _fill(context);
    final border = _border(context);
    final ink = _ink(context);
    final hasAction = actionLabel != null && onAction != null;

    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? '${_kindWord()}: $message',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.md,
            end: AppSpacing.sm,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(_icon(), size: 20, color: ink),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isolate(message),
                      style: textTheme.bodyMedium?.copyWith(color: ink),
                    ),
                    if (hasAction)
                      // No Align wrapper: AppTextButton's Container carries an
                      // alignment, so it already expands to the column width
                      // (full-width action, centered label). Keeps the
                      // >= 48 dp target with no dead wrapper.
                      AppTextButton(
                        label: actionLabel!,
                        onPressed: onAction,
                      ),
                  ],
                ),
              ),
              if (onDismiss != null)
                AppIconButton(
                  icon: Icons.close_rounded,
                  onPressed: onDismiss,
                  tooltip: dismissTooltip,
                  color: ink,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
