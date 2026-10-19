import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';

/// Imagery-first listing card (Airbnb addendum §3.1, customer layer).
///
/// A 16:10 art header (caller-supplied: vehicle silhouette, photo), an
/// optional overlay badge at top-start, an optional favorite heart at
/// top-end, then title + meta + footer rows. The heart renders ONLY when
/// [onFavorite] is non-null — without a persistence contract there is no
/// decorative heart. The art is never claimed to be a photo of anything:
/// callers pass illustrative art and label it honestly.
///
/// Consumer spacing uses the airy rhythm where composed (28/20/20); the
/// card itself resolves all color/type through the active theme, EN/AR,
/// 48dp targets, LTR-safe slots.
class AirbnbImageCard extends StatelessWidget {
  /// 16:10 header art. Fills the band; clipped to the card radius.
  final Widget image;

  /// Overlay badge pinned to the top-start corner (e.g. service context).
  final Widget? badge;

  /// Favorite state. Rendered only with [onFavorite].
  final bool favorited;

  /// Favorite toggle. Null hides the heart entirely (no fake affordance).
  final VoidCallback? onFavorite;

  /// Favorite tooltip/semantics label. Required with [onFavorite].
  final String? favoriteLabel;

  /// Card title (vehicle name, listing title).
  final String title;

  /// Supporting line under the title (specs, schedule).
  final String? meta;

  /// Bottom row (price, plate, mileage chips).
  final Widget? footer;

  final VoidCallback? onTap;

  const AirbnbImageCard({
    super.key,
    required this.image,
    this.badge,
    this.favorited = false,
    this.onFavorite,
    this.favoriteLabel,
    required this.title,
    this.meta,
    this.footer,
    this.onTap,
  }) : assert(
          onFavorite == null || favoriteLabel != null,
          'A favorite toggle needs an accessible label.',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onFav = onFavorite;

    final card = Container(
      decoration: BoxDecoration(
        color: colors.surface,
        // Addendum §2: customer cards resolve 16px via radiusPanel.
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: AppDimensions.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                image,
                if (badge != null)
                  PositionedDirectional(
                    top: AppDimensions.s12,
                    start: AppDimensions.s12,
                    child: badge!,
                  ),
                if (onFav != null)
                  PositionedDirectional(
                    top: AppDimensions.s8,
                    end: AppDimensions.s8,
                    child: Semantics(
                      button: true,
                      label: favoriteLabel,
                      checked: favorited,
                      child: Material(
                        color: colors.surface.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onFav,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimensions.s10),
                            child: Icon(
                              favorited
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              size: AppDimensions.iconMd,
                              color: favorited
                                  ? colors.error
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                if (meta != null && meta!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s4),
                  Text(
                    meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: AppDimensions.s10),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        splashColor: colors.primary.withValues(alpha: 0.08),
        highlightColor: colors.primary.withValues(alpha: 0.04),
        child: card,
      ),
    );
  }
}

/// Vehicle silhouette art for listing headers that have no photography.
///
/// An illustrative gradient band with a car glyph — never a stock photo of
/// a car the customer does not own, and never presented as one. Decorative
/// (excluded from semantics); the card title carries meaning.
class VehicleSilhouetteArt extends StatelessWidget {
  final IconData icon;

  const VehicleSilhouetteArt({
    super.key,
    this.icon = Icons.directions_car_filled_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              colors.primary.withValues(alpha: 0.16),
              colors.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 72,
            color: colors.primary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
