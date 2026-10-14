import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Branded startup splash shown at `/` while the session is restored.
///
/// Renders on the signature navy surface with the Orient mark and a calm
/// progress indicator, so the first frame is intentional rather than a blank
/// flash before the login / workspace decision. Announced as a live region.
class AuthLoadingView extends StatelessWidget {
  const AuthLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);

    return Scaffold(
      backgroundColor: colors.inverseSurface,
      body: Semantics(
        liveRegion: true,
        label: t.authRestoringSessionSemantics,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPanel,
                  ),
                ),
                child: Icon(
                  Icons.build_rounded,
                  color: colors.onInverseSurface,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppDimensions.s20),
              Text(
                t.authBrandName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onInverseSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: AppTypography.tracking(context, 1.6),
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              Text(
                t.authBrandSub,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onInverseSurface.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.tracking(context, 1.1),
                ),
              ),
              const SizedBox(height: AppDimensions.s32),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onInverseSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              Text(
                t.authRestoringSession,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onInverseSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
