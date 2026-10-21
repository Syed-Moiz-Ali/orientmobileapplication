import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_radius.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/directional_icon.dart';

/// Outlined full-width alternative-auth row (phase-1P, C16 auth grammar).
///
/// One row per alternative path ("Continue with Google", "Use password
/// instead"): leading icon, label, optional trailing (defaults to a
/// chevron that auto-mirrors in RTL).
///
/// ```dart
/// AppAltAuthRow(
///   label: 'Continue with Google',
///   icon: Icons.g_mobiledata_rounded,
///   onTap: signInWithGoogle,
/// )
/// ```
///
/// - Sheet-row grammar, NOT a card: `surface` fill, radius 20
///   ([AppRadius.xl]), ONE 1 px hairline border (`outline`) — no shadow, no
///   double border, never nested inside a bordered card.
/// - Tokens only, caller-supplied text, Directional-safe.
/// - Whole row is a >= 48 dp tap target ([AppDimensions.touchTarget]) with
///   an ink ripple clipped to the rounded shape; disabled (`onTap == null`)
///   renders at 40 % opacity with no response.
/// - Screen-reader role is `button` with [label]; the chevron is decorative.
/// - Wraps at text scale 1.3x (label flexes, icon + trailing keep size).
class AppAltAuthRow extends StatelessWidget {
  /// Row label, e.g. "Continue with Google" (caller-supplied, l10n).
  final String label;

  /// Leading icon (brand/provider glyph or [DirectionalIcon]-safe icon).
  final IconData icon;

  /// Row activation. Null renders the disabled treatment.
  final VoidCallback? onTap;

  /// Trailing widget. Defaults to an auto-mirroring chevron.
  final Widget? trailing;

  const AppAltAuthRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      side: BorderSide(color: scheme.outline),
    );

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          child: Material(
            color: scheme.surface,
            shape: shape,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: AppDimensions.iconMd,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        label,
                        style: textTheme.titleSmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    trailing ??
                        DirectionalIcon(
                          Icons.chevron_right,
                          size: AppDimensions.iconMd,
                          color: scheme.onSurfaceVariant,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
