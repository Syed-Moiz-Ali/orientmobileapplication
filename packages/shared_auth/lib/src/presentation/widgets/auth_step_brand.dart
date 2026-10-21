import 'package:flutter/material.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_core/shared_core.dart';

/// Split-layout brand panel for the auth step flows (expanded/large only).
///
/// Shown ONLY beside the step column on split widths — never stacked in the
/// form column. Copy reuses the caller's per-app props ([appName],
/// [appPurpose], [intendedUsers]) plus the passed-through per-app
/// [securityNotice] with the shared generic fallback; no new claims are
/// introduced here.
class AuthStepBrandPanel extends StatelessWidget {
  final String appName;
  final String appPurpose;
  final String intendedUsers;
  final String? securityNotice;

  const AuthStepBrandPanel({
    super.key,
    required this.appName,
    required this.appPurpose,
    required this.intendedUsers,
    required this.securityNotice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);

    return ColoredBox(
      color: colors.inverseSurface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s48,
            vertical: AppDimensions.s40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                if (appPurpose.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s12),
                  Text(
                    appPurpose,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onInverseSurface.withValues(alpha: 0.72),
                      height: 1.6,
                    ),
                  ),
                ],
                if (intendedUsers.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.s12),
                  Text(
                    intendedUsers,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.inversePrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.s28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.r2),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: AppDimensions.iconSm,
                        color: colors.onInverseSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s8),
                    Expanded(
                      child: Text(
                        securityNotice ?? t.authSecurityBadge,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onInverseSurface.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
