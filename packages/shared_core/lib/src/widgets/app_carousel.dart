import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_text_button.dart';

/// C16 collection carousel (phase-1P).
///
/// Section header (bold title + optional subtitle + "Show all" action) above
/// a horizontal list that peeks the next card (~2.2 visible): each child is
/// laid out at [cardExtent] wide so the following card stays partially
/// visible, signalling scrollability.
///
/// ```dart
/// AppCarousel(
///   title: 'Recent bookings',
///   seeAllLabel: 'Show all',
///   onSeeAll: openList,
///   cardExtent: 280,
///   children: bookings.map((b) => AppMediaCard(...)).toList(),
/// )
/// ```
///
/// - Tokens only (screen padding, list gap); caller-supplied text/cards.
/// - Header title is a Semantics header; "Show all" is a real 48 dp button.
/// - Each item gets an "Item i of n" Semantics node; the horizontal scroll
///   view keeps the platform scroll actions.
/// - 1.3x-safe: header row shares a Flexible row (title wraps, action keeps
///   its width); card heights stay intrinsic (no fixed list height), so tall
///   text scales grow vertically instead of overflowing.
class AppCarousel extends StatelessWidget {
  /// Bold section heading (titleMedium).
  final String title;

  /// Optional supporting line under the heading.
  final String? subtitle;

  /// "Show all" action label. Shown only with [onSeeAll].
  final String? seeAllLabel;

  /// Opens the full collection. Null hides the action.
  final VoidCallback? onSeeAll;

  /// Cards in the carousel. Each is laid out [cardExtent] wide.
  final List<Widget> children;

  /// Width of each card. Pick so ~2.2 cards fit the compact viewport
  /// (e.g. 280 on a 390 wide phone with 20 px screen padding).
  final double cardExtent;

  /// Overrides the carousel's Semantics label.
  final String? semanticLabel;

  const AppCarousel({
    super.key,
    required this.title,
    this.subtitle,
    this.seeAllLabel,
    this.onSeeAll,
    required this.children,
    this.cardExtent = 280,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: semanticLabel,
      container: semanticLabel != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: textTheme.titleMedium),
                ),
              ),
              if (seeAllLabel != null && onSeeAll != null)
                AppTextButton(label: seeAllLabel!, onPressed: onSeeAll),
            ],
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(
              start: AppSpacing.screenPaddingPhone,
              end: AppSpacing.screenPaddingPhone,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  Semantics(
                    container: true,
                    label: 'Item ${i + 1} of ${children.length}',
                    child: SizedBox(
                      width: cardExtent,
                      child: children[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
