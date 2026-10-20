import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Outcome kind shared by [AppSnackBar] and [AppToast] (phase-1e-ii).
///
/// Success/error variants use an icon plus a soft tint + matching ink —
/// never a full saturated fill — so meaning is carried by icon + label,
/// never color alone.
enum AppSnackBarKind { neutral, success, error }

/// Spec-C8 floating snackbar (phase-1e-ii).
///
/// Radius 12, icon + message, auto-dismiss (default 4s, injectable via
/// [displayDuration]), optional action, live-region announcement.
///
/// Spec name `AppSnackBar` verified free in `packages/` (only the legacy
/// `showAppSnackBar` function + `AppSnackBarTone` enum exist, untouched);
/// no rename needed. Prefer this over the legacy helper for new work.
///
/// ```dart
/// AppSnackBar.show(
///   context,
///   message: 'Booking saved.',
///   kind: AppSnackBarKind.success,
///   actionLabel: 'Undo',
///   onAction: undo,
/// )
/// ```
///
/// Positioning contract (must not cover the bottom nav or sticky bar): the
/// card is bottom-floating with [SnackBarBehavior.floating]. Pass the
/// stacked height of any bottom nav / sticky action bar as [bottomMargin]
/// (default 16 = bare Scaffold); the card floats above it and is
/// swipe-dismissible, so the bar stays reachable. Toasts never cover the
/// bar by construction (centered, non-blocking, auto-dismiss).
class AppSnackBar extends StatelessWidget {
  final String message;
  final AppSnackBarKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  const AppSnackBar({
    super.key,
    required this.message,
    this.kind = AppSnackBarKind.neutral,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  /// Shows [AppSnackBar] bottom-floating (see the positioning contract).
  /// [displayDuration] is injectable so tests use milliseconds.
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    AppSnackBarKind kind = AppSnackBarKind.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration displayDuration = const Duration(seconds: 4),
    double bottomMargin = AppSpacing.lg,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        duration: displayDuration,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsetsDirectional.only(
          start: AppSpacing.lg,
          end: AppSpacing.lg,
          bottom: bottomMargin,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        content: AppSnackBar(
          message: message,
          kind: kind,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      message: message,
      kind: kind,
      actionLabel: actionLabel,
      onAction: onAction,
      semanticLabel: semanticLabel,
    );
  }
}

/// Spec-C8 centered toast (phase-1e-ii): icon + message, no action,
/// auto-dismiss (default 4s, injectable), live-region announcement.
///
/// Non-blocking ([IgnorePointer]) and centered, so it can never cover the
/// bottom nav or sticky bar. Shown through the app [Overlay]; needs no
/// Scaffold. Spec name `AppToast` verified free; no rename needed.
///
/// ```dart
/// AppToast.show(context, message: 'Synced.', kind: AppSnackBarKind.success)
/// ```
class AppToast extends StatelessWidget {
  final String message;
  final AppSnackBarKind kind;
  final String? semanticLabel;

  const AppToast({
    super.key,
    required this.message,
    this.kind = AppSnackBarKind.neutral,
    this.semanticLabel,
  });

  /// Shows [AppToast] centered over everything for [displayDuration].
  /// [displayDuration] is injectable so tests use milliseconds.
  static Future<void> show(
    BuildContext context, {
    required String message,
    AppSnackBarKind kind = AppSnackBarKind.neutral,
    Duration displayDuration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    var active = true;
    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                color: Colors.transparent,
                child: IgnorePointer(
                  child: AppToast(message: message, kind: kind),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    return Future.delayed(displayDuration, () {
      if (active && overlay.mounted) {
        active = false;
        entry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _OverlayCard(
      message: message,
      kind: kind,
      semanticLabel: semanticLabel,
    );
  }
}

/// Shared floating card (radius 12, icon + message + optional >= 48 dp
/// action). Meaning rides on icon + label + ink; the action uses the card
/// ink at label weight so it stays AA on every fill without an accent.
class _OverlayCard extends StatelessWidget {
  final String message;
  final AppSnackBarKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? semanticLabel;

  const _OverlayCard({
    required this.message,
    required this.kind,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = _fillFor(kind, scheme, dark);
    final ink = _inkFor(kind, context, scheme, dark);
    final hasAction = actionLabel != null && onAction != null;
    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? message,
      container: true,
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: dark && kind == AppSnackBarKind.neutral
                ? Border.all(color: scheme.outline)
                : null,
          ),
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.lg,
            end: AppSpacing.sm,
            top: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(kind), size: 20, color: ink),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '\u2066$message\u2069',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: ink, fontWeight: FontWeight.w600),
                ),
              ),
              if (hasAction)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.sm,
                  ),
                  child: TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: ink,
                      minimumSize: const Size(48, 48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _fillFor(AppSnackBarKind kind, ColorScheme scheme, bool dark) {
  switch (kind) {
    case AppSnackBarKind.neutral:
      return scheme.inverseSurface;
    case AppSnackBarKind.success:
      return dark
          ? AppDarkColors.successStrongSoft
          : AppColors.successStrongSoft;
    case AppSnackBarKind.error:
      return dark ? AppDarkColors.dangerSubtle : AppColors.dangerSubtle;
  }
}

Color _inkFor(
  AppSnackBarKind kind,
  BuildContext context,
  ColorScheme scheme,
  bool dark,
) {
  switch (kind) {
    case AppSnackBarKind.neutral:
      return scheme.onInverseSurface;
    case AppSnackBarKind.success:
      return dark
          ? AppDarkColors.successStrongInk
          : AppColors.successStrongInk;
    case AppSnackBarKind.error:
      return context.semanticColors.danger.ink;
  }
}

IconData _iconFor(AppSnackBarKind kind) {
  switch (kind) {
    case AppSnackBarKind.neutral:
      return Icons.info_outline_rounded;
    case AppSnackBarKind.success:
      return Icons.check_circle_outline_rounded;
    case AppSnackBarKind.error:
      return Icons.error_outline_rounded;
  }
}
