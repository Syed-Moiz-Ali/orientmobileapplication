import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// Trust accent tone. Only these two families exist — never random colors.
enum TrustTone {
  /// Verified workshop / identity (success family).
  verified,

  /// Top-rated / guest-favorite equivalent (amber family).
  topRated,
}

/// Trust badge (Airbnb addendum §3.4, customer layer): icon + label for
/// verified / top-rated claims. Labels come from the caller (localized);
/// tones resolve the semantic success/amber families in both themes.
class TrustPill extends StatelessWidget {
  final String label;
  final TrustTone tone;
  final IconData icon;

  const TrustPill({
    super.key,
    required this.label,
    this.tone = TrustTone.verified,
    this.icon = Icons.verified_rounded,
  });

  const TrustPill.verified(
    this.label, {
    super.key,
    this.icon = Icons.verified_rounded,
  }) : tone = TrustTone.verified;

  const TrustPill.topRated(
    this.label, {
    super.key,
    this.icon = Icons.star_rounded,
  }) : tone = TrustTone.topRated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final role = tone == TrustTone.verified
        ? semantic.success
        : semantic.warning;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: role.subtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: role.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconXs, color: role.ink),
          const SizedBox(width: AppDimensions.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: role.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
