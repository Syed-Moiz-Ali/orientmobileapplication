import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Branded startup splash shown at `/` while the session is restored.
///
/// Renders on the signature navy surface ([ColorScheme.inverseSurface]) with
/// the Orient mark, a calm progress indicator and restore messaging, so the
/// first frame is intentional rather than a blank flash before the login /
/// workspace decision. Announced as a live region; motion collapses under
/// `MediaQuery.disableAnimations` via [AppMotion].
class AuthLoadingView extends StatelessWidget {
  const AuthLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final muted = colors.onInverseSurface.withValues(alpha: 0.72);

    return Scaffold(
      backgroundColor: colors.inverseSurface,
      body: Semantics(
        liveRegion: true,
        label: t.authRestoringSessionSemantics,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusPanel,
                    ),
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    color: colors.onPrimary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: AppDimensions.s20),
                Text(
                  t.authBrandName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: AppTypography.tracking(context, 1.6),
                  ),
                ),
                const SizedBox(height: AppDimensions.s6),
                Text(
                  t.authBrandSub,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppTypography.tracking(context, 1.1),
                  ),
                ),
                const SizedBox(height: AppDimensions.s32),
                // Linear progress reads as loading at a glance (the ring
                // rendered as a static circle in stills and at small sizes).
                // Fill is the authorized lighter-cobalt on-navy accent;
                // reduced motion keeps the static hourglass mark.
                SizedBox(
                  width: 160,
                  child: reduceMotion
                      ? Icon(
                          Icons.hourglass_top_rounded,
                          size: 22,
                          color: colors.onInverseSurface,
                          semanticLabel: t.authRestoringSession,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.rPill,
                          ),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            color: colors.inversePrimary,
                            backgroundColor: colors.onInverseSurface.withValues(
                              alpha: 0.16,
                            ),
                            semanticsLabel: t.authRestoringSession,
                          ),
                        ),
                ),
                const SizedBox(height: AppDimensions.s16),
                Text(
                  t.authRestoringSession,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
