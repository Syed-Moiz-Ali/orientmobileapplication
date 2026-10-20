import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_shadows.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_surface_card_header.dart';

/// Spec-C8 card surface (phase-1c-i).
///
/// Named `AppSurfaceCard` (not spec `AppCard`) because the legacy `AppCard`
/// in `app_card.dart` owns that name and is off-limits in phase 1. Rename
/// path: once the legacy card is removed in the polish phase, rename
/// `AppSurfaceCard` -> `AppCard` in one codemod.
///
/// ```dart
/// AppSurfaceCard(
///   headerTitle: 'Recent activity',
///   headerTrailing: AppTextButton(label: 'See all', onPressed: showAll),
///   onTap: openDetails, // tappable variant: ripple + chevron, >= 48 dp
///   child: Text('Body'),
/// )
/// ```
///
/// Tokens only (surface, `borderDefault`, [AppShadows.e1]); caller text.
/// Border OR shadow, never both: light + [outlined] = 1 px border, no
/// shadow; light + elevated = [AppShadows.e1], no border. Dark always uses
/// a 1 px border + surface lift and never a shadow. Header row lives in
/// [AppSurfaceCardHeader]. Never nest a bordered card inside a bordered
/// card; put a surfaceAlt block inside cards instead (see gallery demo).
class AppSurfaceCard extends StatelessWidget {
  final Widget child;

  /// Card inner padding (default 20, compact 16, hero 24 — spec C4).
  final EdgeInsetsGeometry padding;

  /// Optional header row: small title + trailing action.
  final String? headerTitle;
  final Widget? headerTrailing;

  /// Optional footer block below the body.
  final Widget? footer;

  /// Tappable variant. Null = static card.
  final VoidCallback? onTap;

  /// Accessibility label for the tappable variant (defaults to headerTitle).
  final String? semanticLabel;

  /// Trailing chevron on the tappable variant (mirrors in RTL).
  final bool showChevron;

  /// True = 1 px border (light); false = e1 shadow (light). Dark always
  /// uses a border and never a shadow.
  final bool outlined;

  /// Card radius: 16 default, 20 for large/hero cards (spec C5).
  final double radius;

  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.headerTitle,
    this.headerTrailing,
    this.footer,
    this.onTap,
    this.semanticLabel,
    this.showChevron = false,
    this.outlined = true,
    this.radius = AppRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final borderRadius = BorderRadius.circular(radius);
    final decoration = BoxDecoration(
      color: scheme.surface,
      borderRadius: borderRadius,
      border: outlined || dark
          // scheme.outline IS borderDefault: AppTheme wires
          // outline: AppColors/AppDarkColors.borderDefault (both themes).
          ? Border.all(color: scheme.outline)
          : null,
      boxShadow: !outlined && !dark ? AppShadows.e1 : null,
    );

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (headerTitle != null || headerTrailing != null)
          AppSurfaceCardHeader(
            title: headerTitle,
            trailing: headerTrailing,
            showChevron: showChevron && onTap != null,
          ),
        child,
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.md),
          footer!,
        ],
      ],
    );

    body = Padding(padding: padding, child: body);

    // Tappable cards guarantee a >= 48 dp target even with tiny bodies.
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
        label: semanticLabel ?? headerTitle,
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
