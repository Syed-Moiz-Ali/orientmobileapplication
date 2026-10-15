import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_auth/src/localization/shared_auth_l10n.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

/// Shared authentication shell used by every Orient app.
///
/// Composition (from scratch, Archetype 1 — focused identity access):
/// - compact: single focused column, max 480 wide, condensed brand lockup.
/// - medium: same column boxed on a surface card so extra width reads as
///   deliberate instead of stretched.
/// - expanded/large: split — reading-start navy identity panel (brand mark,
///   app identity, trust points, security badge) + reading-end focused form
///   (max 480), whole canvas capped at 1440 and centered.
///
/// Breakpoints come from the single authority ([AppAdaptiveSpec] via
/// [AppAdaptiveBuilder]); no width literals or `MediaQuery` reads live here.
/// Styling resolves through `ColorScheme.inverseSurface` / `onInverseSurface` /
/// `inversePrimary` only — tonal steps derive from `onInverseSurface`.
///
///
/// The shell is independent of Riverpod so it renders in isolation (tests,
/// previews) and is reused by [LoginView], [ForgotPasswordView] and
/// role-specific screens such as the supervisor console.
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
      // Justified Brightness use (theme guard allowlist): OS system-chrome
      // contrast only — never a widget palette decision.
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
            child: AppAdaptiveBuilder(
              builder: (context, adaptive) {
                final split = adaptive.isExpanded || adaptive.isLarge;
                final boxed = adaptive.isMedium;

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
                  boxed: boxed,
                  child: child,
                );

                if (!split) return form;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _AuthIdentityPanel(
                            appName: appName,
                            appPurpose: appPurpose,
                            intendedUsers: intendedUsers,
                            securityNotice: securityNotice,
                          ),
                        ),
                        Expanded(flex: 6, child: form),
                      ],
                    ),
                  ),
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

    return AppAdaptiveBuilder(
      builder: (context, adaptive) {
        final horizontal = boxed
            ? AppDimensions.s24
            : adaptive.pick(
                compact: AppDimensions.s20,
                medium: AppDimensions.s24,
                expanded: AppDimensions.s28,
                large: AppDimensions.s32,
              );
        final vertical = boxed ? AppDimensions.s32 : AppDimensions.s28;

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
          constraints: const BoxConstraints(maxWidth: 480),
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
          child: Align(
            alignment: adaptive.keyboardOpen
                ? adaptive.focusedFlowAlignment
                : Alignment.center,
            child: panel,
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
  final String? securityNotice;

  const _AuthIdentityPanel({
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
                const _AuthBrandLockup(onDark: true, size: 46),
                const SizedBox(height: AppDimensions.s32),
                Text(
                  t.authIdentityHeadline,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onInverseSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: AppTypography.tracking(context, -0.5),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                Text(
                  t.authIdentityBody,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _inverseMuted(colors),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.s28),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  decoration: BoxDecoration(
                    color: _inverseRaised(colors),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    border: Border.all(color: _inverseBorder(colors)),
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
                const SizedBox(height: AppDimensions.s32),
                _InverseSecurityNote(text: securityNotice),
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
    final accent = onDark ? colors.inversePrimary : colors.primary;
    final titleColor = onDark ? colors.onInverseSurface : colors.onSurface;
    final bodyColor = onDark
        ? _inverseMuted(colors)
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
            maxLines: 3,
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
          ),
          child: Icon(
            Icons.build_rounded,
            color: colors.onPrimary,
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
                  color: onDark ? colors.onInverseSurface : colors.onSurface,
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
                      ? _inverseMuted(colors)
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
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _inverseRaised(colors),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Icon(icon, size: 17, color: colors.inversePrimary),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _inverseMuted(colors),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Trust footnote pinned to the identity panel so the desktop split carries
/// the same legal line as the form column — one message, never duplicated.
class _InverseSecurityNote extends StatelessWidget {
  final String? text;

  const _InverseSecurityNote({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = SharedAuthL10n.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppDimensions.r2),
          child: Icon(
            Icons.lock_outline_rounded,
            size: AppDimensions.iconSm,
            color: _inverseMuted(colors),
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Expanded(
          child: Text(
            text ?? t.authSecurityBadge,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _inverseMuted(colors),
              height: 1.4,
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

// ---------------------------------------------------------------------------
// Inverse-brand tonal steps.
//
// The identity panel sits on `ColorScheme.inverseSurface` (the signature navy
// brand surface). Its passive raised fill, hairline and faded ink are derived
// from the single semantic `onInverseSurface` ink at reduced emphasis rather
// than introducing new palette tokens or dark/light branches.
// ---------------------------------------------------------------------------
Color _inverseRaised(ColorScheme c) =>
    c.onInverseSurface.withValues(alpha: 0.08);
Color _inverseBorder(ColorScheme c) =>
    c.onInverseSurface.withValues(alpha: 0.14);
Color _inverseMuted(ColorScheme c) =>
    c.onInverseSurface.withValues(alpha: 0.72);
