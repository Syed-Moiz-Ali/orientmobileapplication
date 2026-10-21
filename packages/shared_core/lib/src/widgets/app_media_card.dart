import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_shadows.dart';
import 'package:shared_core/src/theme/app_spacing.dart';

/// C16 content card (phase-1P).
///
/// Image-or-icon top slot, title, meta line, and a single status-pill slot.
/// Radius 20, generous padding, soft shadow, NO border in light mode — never
/// nested inside another card (put surface blocks inside instead, per C8).
///
/// ```dart
/// AppMediaCard(
///   media: ClipRRect(...Image...),
///   title: 'Downtown service center',
///   meta: '2.4 km away',
///   status: AppStatusChip(label: 'Open now', kind: AppStatusKind.success),
///   onTap: openDetail,
/// )
/// ```
///
/// - Tokens only, caller-supplied text/media/status. Light: [AppShadows.e1],
///   no border. Dark: 1 px border + surface lift, never a shadow (C5).
/// - Exactly one status slot: pass a single [AppStatusChip] (or equivalent);
///   the card lays it out once below the meta line.
/// - Tappable variant: ripple + button Semantics, >= 48 dp target.
/// - 1.3x-safe: title/meta/status wrap vertically; the media slot keeps the
///   caller's intrinsic height.
class AppMediaCard extends StatelessWidget {
  /// Top visual slot (typically an image sized by the caller). Clipped to
  /// the image radius. Takes precedence over [icon].
  final Widget? media;

  /// Icon fallback when [media] is null: a 28 px glyph on a subtle block.
  final IconData? icon;

  /// Card title (titleSmall, max 3 text levels per card per C16).
  final String title;

  /// Supporting line under the title (bodySmall, muted).
  final String? meta;

  /// Single status pill (e.g. [AppStatusChip]). One per card per C16.
  final Widget? status;

  /// Tappable variant. Null = static card.
  final VoidCallback? onTap;

  /// Accessibility label for the tappable variant (defaults to [title]).
  final String? semanticLabel;

  /// Card radius (spec C5: 20 for large/hero cards).
  final double radius;

  const AppMediaCard({
    super.key,
    this.media,
    this.icon,
    required this.title,
    this.meta,
    this.status,
    this.onTap,
    this.semanticLabel,
    this.radius = AppRadius.xl,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final borderRadius = BorderRadius.circular(radius);
    final decoration = BoxDecoration(
      color: scheme.surface,
      borderRadius: borderRadius,
      // C5: border OR shadow, never both. Media cards always take the
      // shadow path in light mode (no border); dark always takes border.
      border: dark ? Border.all(color: scheme.outline) : null,
      boxShadow: dark ? null : AppShadows.e1,
    );

    Widget? top;
    final pendingMedia = media;
    if (pendingMedia != null) {
      top = ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.image),
        child: pendingMedia,
      );
    } else if (icon != null) {
      top = Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.image),
        ),
        alignment: Alignment.center,
        child: ExcludeSemantics(
          child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
        ),
      );
    }

    final pendingMeta = meta;
    final pendingStatus = status;
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (top != null) ...[
          top,
          const SizedBox(height: AppSpacing.md),
        ],
        Text(title, style: textTheme.titleSmall),
        if (pendingMeta != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            pendingMeta,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (pendingStatus != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: pendingStatus,
          ),
        ],
      ],
    );

    body = Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: body,
    );

    if (onTap != null) {
      body = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: body,
      );
    }

    Widget card = Container(decoration: decoration, child: body);

    if (onTap != null) {
      card = Semantics(
        button: true,
        enabled: true,
        label: semanticLabel ?? title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: card,
          ),
        ),
      );
    }
    return card;
  }
}
