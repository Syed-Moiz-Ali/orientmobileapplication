import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

/// Shared authentication shell used by every Orient app.
///
/// Layout strategy:
/// - compact (< 600): a single focused column. No decorative panel, so the
///   authentication task owns the whole screen.
/// - medium (600 - 899): the same column boxed on a surface card so the extra
///   width reads as deliberate instead of stretched.
/// - expanded (>= 900): a split layout. The left pane carries the Orient
///   identity and application context; the right pane stays focused on the
///   authentication task.
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: colors.surfaceContainerLow,
      ),
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLow,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final compact = constraints.maxWidth < 600;

              final form = _AuthFormPane(
                title: title,
                subtitle: subtitle,
                appName: appName,
                appPurpose: appPurpose,
                intendedUsers: intendedUsers,
                top: top,
                footer: footer,
                showBrand: !desktop,
                showContext: !desktop,
                boxed: !compact,
                child: child,
              );

              if (!desktop) return form;

              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _AuthIdentityPanel(
                      appName: appName,
                      appPurpose: appPurpose,
                      intendedUsers: intendedUsers,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                  Expanded(flex: 6, child: form),
                ],
              );
            },
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
  final Widget? footer;
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
        final width = viewport.maxWidth;
        final horizontal = boxed
            ? AppDimensions.s24
            : width < 360
            ? AppDimensions.s16
            : width < 430
            ? AppDimensions.s20
            : AppDimensions.s24;
        final vertical = boxed ? AppDimensions.s32 : AppDimensions.s28;
        final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
        final minHeight = (viewport.maxHeight - vertical * 2).clamp(
          0.0,
          double.infinity,
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBrand) ...[
              const _AuthBrandMark(),
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
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppDimensions.s24),
            child,
            const SizedBox(height: AppDimensions.s28),
            footer ?? const SecurityBadge(),
          ],
        );

        Widget panel = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: boxed ? 440 : 480),
          child: content,
        );

        if (boxed) {
          panel = Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.36 : 0.05,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
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
              alignment: keyboardOpen ? Alignment.topCenter : Alignment.center,
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
    final colors = theme.colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s40),
        child: Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AuthBrandMark(size: 44),
                const SizedBox(height: AppDimensions.s40),
                Text(
                  'Workshop operations, end to end.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                Text(
                  'Bookings, job cards, inspections, approvals, and customer '
                  'updates in one secure workspace for every workshop role.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: AppDimensions.s28),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusCard,
                    ),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: _AuthContextBlock(
                    appName: appName,
                    appPurpose: appPurpose,
                    intendedUsers: intendedUsers,
                  ),
                ),
                const SizedBox(height: AppDimensions.s28),
                const _AuthTrustPoint(
                  icon: Icons.verified_user_outlined,
                  label: 'Role-aware access',
                ),
                const SizedBox(height: AppDimensions.s12),
                const _AuthTrustPoint(
                  icon: Icons.sync_rounded,
                  label: 'Protected session continuity',
                ),
                const SizedBox(height: AppDimensions.s12),
                const _AuthTrustPoint(
                  icon: Icons.support_agent_rounded,
                  label: 'Workshop support when you need it',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact application context: the product name, the roles it serves, and a
/// de-emphasised purpose line. Reacts to the values supplied by each app, so a
/// single shared screen can present four different application identities.
class _AuthContextBlock extends StatelessWidget {
  final String appName;
  final String appPurpose;
  final String intendedUsers;

  const _AuthContextBlock({
    required this.appName,
    required this.appPurpose,
    required this.intendedUsers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final roles = _roleTokens(intendedUsers);

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
                  color: colors.primary,
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
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (roles.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        roles.join(' \u2022 '),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact Orient lockup. Uses a programmatic mark rather than the bundled
/// image asset, which belongs to the technology vendor and not the brand.
class _AuthBrandMark extends StatelessWidget {
  final double size;

  const _AuthBrandMark({this.size = 38});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                'ORIENT',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                'WORKSHOP SUITE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
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
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          ),
          child: Icon(icon, size: 17, color: colors.primary),
        ),
        const SizedBox(width: AppDimensions.s12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
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
