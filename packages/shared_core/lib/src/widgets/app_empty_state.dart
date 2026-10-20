import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_pill_button.dart';

/// Spec-C8 empty state (phase-1d-i).
///
/// 64 px circle (accentSoft or surfaceAlt) with a 28 px icon, title, message
/// (max 2 lines) and an optional [AppPillButton] action. Centered, max width
/// 320. Friendly line + what appears here + how to start (C10/C11).
///
/// Name verified free (no legacy `AppEmptyState`); no rename needed.
///
/// ```dart
/// AppEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No bookings yet',
///   message: 'New bookings will appear here.',
///   actionLabel: 'New booking',
///   onAction: createBooking,
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe. Display-only
///   apart from the optional action (a real >= 48 dp button target).
/// - Wraps at text scale 1.3x and in RTL; merged into one Semantics node.
/// - Title and message are bidi-isolated (U+2066…U+2069) so edge
///   punctuation never flips in RTL paragraphs (1d-i review); paragraph
///   direction and alignment still follow the locale.
///
/// Bidi-isolates [text] (U+2066…U+2069); see [AppStatTile] for the rationale.
String _isolate(String text) => '\u2066$text\u2069';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  /// Set [tinted] to false to use the neutral surfaceAlt circle.
  final bool tinted;

  /// Optional action: both [actionLabel] and [onAction] must be set.
  final String? actionLabel;
  final VoidCallback? onAction;

  final String? semanticLabel;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tinted = true,
    this.actionLabel,
    this.onAction,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final circleFill =
        tinted ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final iconInk = tinted
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    final hasAction = actionLabel != null && onAction != null;

    return Semantics(
      label: semanticLabel,
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
                    color: circleFill,
                  ),
                  child: Icon(icon, size: 28, color: iconInk),
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
                if (hasAction) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppPillButton.primary(
                    label: actionLabel!,
                    onPressed: onAction,
                    size: AppPillButtonSize.small,
                    isExpanded: false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
