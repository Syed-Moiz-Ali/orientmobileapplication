import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

/// Shared authentication shell used by every Orient app (spec §14 T8).
///
/// Layout strategy:
/// - compact (< 600): a single focused column with a condensed identity block
///   so the authentication task owns the whole screen.
/// - medium (600 - 899): the same column boxed on a surface card so the extra
///   width reads as deliberate instead of stretched.
/// - expanded (>= 900): a split layout. The reading-start pane is the navy
///   [AppColors.navy] identity panel (brand mark, app identity, trust points);
///   the reading-end pane stays focused on the authentication task.
///
/// The shell is intentionally independent of Riverpod so it can be rendered in
/// isolation (tests, previews) and reused by [LoginView], [ForgotPasswordView]
/// and role-specific screens such as the supervisor console.
class AuthShell extends StatelessWidget {
  final Widget? top;
  final String title;
  final String subtitle;
  final String appName;
  final String appPurpose;
  final String intendedUsers;
  final Widget child;
  final Widget? footer;

  /// App-aware legal notice passed to [SecurityBadge]. When null the shared
  /// generic wording is used.
  final String? securityNotice;

  const AuthShell({
    super.key,
    this.top,
    required this.title,
    required this.subtitle,
    this.appName = 'Orient Workshop',
    this.appPurpose =
        'Manage workshop bookings, job cards, approvals, and service updates.',
    this.intendedUsers = 'Workshop users',
    required this.child,
    this.footer,
    this.securityNotice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final split = width >= 900;
                final compact = width < 600;

                final form = _AuthFormPane(
                  title: title,
                  subtitle: subtitle,
                  appName: appName,
                  appPurpose: appPurpose,
                  intendedUsers: intendedUsers,
                  top: top,
                  footer: footer ?? SecurityBadge(text: securityNotice),
                  showBrand: !split,
                  showContext: !split,
                  boxed: !split && !compact,
                  child: child,
                );

                if (!split) return form;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _AuthIdentityPanel(
                        appName: appName,
                        appPurpose: appPurpose,
                        intendedUsers: intendedUsers,
                      ),
                    ),
                    Expanded(flex: 6, child: form),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFormPane extends StatelessWidget {
  final String title;
  final String subtitle;
  final String appName;
  final String appPurpose;
  final String intendedUsers;
  final Widget? top;
  final Widget child;
  final Widget footer;
  final bool showBrand;
  final bool showContext;
  final bool boxed;

  const _AuthFormPane({
    required this.title,
    required this.subtitle,
    required this.appName,
    required this.appPurpose,
    required this.intendedUsers,
    required this.top,
    required this.child,
    required this.footer,
    required this.showBrand,
    required this.showContext,
    required this.boxed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, viewport) {
        final adaptive = AppResponsive.specFor(context, constraints: viewport);
        final width = viewport.maxWidth;
        final horizontal = boxed
            ? AppDimensions.s24
            : width < 360
            ? AppDimensions.s16
            : width < 430
            ? AppDimensions.s20
            : AppDimensions.s24;
        final vertical = boxed ? AppDimensions.s32 : AppDimensions.s28;
        final minHeight = (viewport.maxHeight - vertical * 2).clamp(
          0.0,
          double.infinity,
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBrand) ...[
              const _AuthBrandLockup(),
              const SizedBox(height: AppDimensions.s24),
            ],
            if (top != null) ...[
              top!,
              const SizedBox(height: AppDimensions.s20),
            ],
            if (showContext) ...[
              _AuthContextBlock(
                appName: appName,
                appPurpose: appPurpose,
                intendedUsers: intendedUsers,
                onDark: false,
              ),
              const SizedBox(height: AppDimensions.s28),
            ],
            Semantics(
              header: true,
              child: Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppTypography.tracking(context, -0.5),
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.s20),
            child,
            const SizedBox(height: AppDimensions.s28),
            footer,
          ],
        );

        Widget panel = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: content,
        );

        if (boxed) {
          panel = Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: AppDimensions.shadowCard,
            ),
            padding: const EdgeInsets.all(AppDimensions.s28),
            child: panel,
          );
        }

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: vertical,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Align(
              alignment: adaptive.keyboardOpen
                  ? adaptive.focusedFlowAlignment
                  : Alignment.center,
              child: panel,
            ),
          ),
        );
      },
    );
  }
}

class _AuthIdentityPanel extends StatelessWidget {
  final String appName;
  final String appPurpose;
  final String intendedUsers;

  const _AuthIdentityPanel({
    required this.appName,
    required this.appPurpose,
    required this.intendedUsers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = SharedAuthL10n.of(context);

    return ColoredBox(
      color: AppColors.navy,
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
                const _AuthBrandLockup(onDark: true, size: 46),
                const SizedBox(height: AppDimensions.s32),
                Text(
                  t.authIdentityHeadline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w800,
                    letterSpacing: AppTypography.tracking(context, -0.5),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                Text(
                  t.authIdentityBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onNavySecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.s28),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  decoration: BoxDecoration(
                    color: AppColors.navySurfaceRaised,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: _AuthContextBlock(
                    appName: appName,
                    appPurpose: appPurpose,
                    intendedUsers: intendedUsers,
                    onDark: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.s28),
                _AuthTrustPoint(
                  icon: Icons.verified_user_outlined,
                  label: t.authTrustRoles,
                ),
                const SizedBox(height: AppDimensions.s12),
                _AuthTrustPoint(
                  icon: Icons.sync_rounded,
                  label: t.authTrustSync,
                ),
                const SizedBox(height: AppDimensions.s12),
                _AuthTrustPoint(
                  icon: Icons.speed_rounded,
                  label: t.authTrustBays,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContextBlock extends StatelessWidget {
  final String appName;
  final String appPurpose;
  final String intendedUsers;
  final bool onDark;

  const _AuthContextBlock({
    required this.appName,
    required this.appPurpose,
    required this.intendedUsers,
    required this.onDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final roles = _roleTokens(intendedUsers);
    final accent = onDark ? AppDarkColors.primary : colors.primary;
    final titleColor = onDark ? AppColors.textInverse : colors.onSurface;
    final bodyColor = onDark
        ? AppColors.onNavySecondary
        : colors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(AppDimensions.rPill),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        roles.join(' \u2022 '),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: AppTypography.tracking(context, 0.2),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (appPurpose.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s10),
          Text(
            appPurpose,
            maxLines: MediaQuery.sizeOf(context).width < 600 ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: bodyColor,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact Orient lockup. Uses a programmatic mark rather than the bundled
/// image asset, which belongs to the technology vendor and not the brand.
class _AuthBrandLockup extends StatelessWidget {
  final double size;
  final bool onDark;

  const _AuthBrandLockup({this.size = 38, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: onDark
                ? null
                : [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Icon(
            Icons.build_rounded,
            color: AppColors.textInverse,
            size: size * 0.5,
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.authBrandName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: onDark ? AppColors.textInverse : colors.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: AppTypography.tracking(context, 1.6),
                  height: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                t.authBrandSub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: onDark
                      ? AppColors.onNavySecondary
                      : colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypography.tracking(context, 1.1),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthTrustPoint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AuthTrustPoint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.navySurfaceRaised,
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Icon(icon, size: 17, color: AppDarkColors.primary),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onNavySecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Turns a free-form helpers string such as
/// `For advisors, technicians, and supervisors` into compact role tokens.
List<String> _roleTokens(String intendedUsers) {
  var text = intendedUsers.trim();
  if (text.isEmpty) return const [];
  text = text.replaceFirst(RegExp(r'^for\s+', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'\s+and\s+', caseSensitive: false), ',');
  return text
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty && part.toLowerCase() != 'and')
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .toList();
}
