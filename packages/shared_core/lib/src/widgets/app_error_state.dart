import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// Spec-C8 error state (phase-1d-i).
///
/// Same centered layout as [AppEmptyState] with an error glyph, a friendly
/// message (what happened + what to do) and a "Try again" button. Announced
/// through a live region. NEVER pass raw exception text: log the exception
/// at the call site and pass a plain-language [message] instead.
///
/// Name verified free (no legacy `AppErrorState`); no rename needed.
///
/// ```dart
/// AppErrorState(
///   title: 'Could not load bookings',
///   message: 'Check your connection and try again.',
///   onRetry: reload,
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe. The retry is a
///   real >= 48 dp button target; wraps at text scale 1.3x and in RTL.
/// - Title and message are bidi-isolated (U+2066…U+2069) so edge
///   punctuation never flips in RTL paragraphs (1d-i review); paragraph
///   direction and alignment still follow the locale.
///
/// Bidi-isolates [text] (U+2066…U+2069); see [AppStatTile] for the rationale.
String _isolate(String text) => '\u2066$text\u2069';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;

  /// Retry handler (required — an error state always offers a next step).
  final VoidCallback? onRetry;

  /// Retry button label. Defaults to `'Try again'`.
  final String retryLabel;

  final String? semanticLabel;

  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Try again',
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      liveRegion: true,
      label: semanticLabel ?? '$title. $message',
      child: ExcludeSemantics(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.errorContainer,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 28,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _isolate(title),
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _isolate(message),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppPillButton.primary(
                    label: retryLabel,
                    onPressed: onRetry,
                    size: AppPillButtonSize.small,
                    isExpanded: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
