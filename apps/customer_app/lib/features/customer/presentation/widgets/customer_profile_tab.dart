import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_notice_panel.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_skeleton.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_status_notices.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_surface_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

part 'customer_profile_rows.dart';

/// Profile — the account surface, built from real account data only.
///
/// It answers three questions: who is signed in, which account-level actions
/// genuinely exist, and how to sign out.
///
/// The customer profile contract (`GET /customers/profile`) returns exactly a
/// name, derived initials and a member reference, so this screen shows exactly
/// those. No tier, balance, campaign, badge, preference or biometric lock is
/// rendered, because none of them exist in that contract, in the backend or in
/// the client.
///
/// On phones everything stacks and stays compact. On wide screens the same real
/// content is composed as an account workspace: one full-height identity panel
/// carrying the account's own details and contact, beside the account actions
/// with the session control anchored to the same baseline. The workspace takes
/// a viewport-proportional minimum height, so the surface is deliberately
/// composed rather than content floating at the top of a blank canvas.
class CustomerProfileTab extends ConsumerWidget {
  const CustomerProfileTab({super.key});

  /// Profile is a two-column account workspace, so it uses more of a desktop
  /// width than a single-column list would.
  static const double _wideContentWidth = 1180;
  static const double _stackedContentWidth = 860;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(customerDashboardProvider);
    final profile = dash.profile;
    final auth = ref.watch(authNotifierProvider);

    // Contact details live on the authenticated session (`GET /auth/me`); the
    // customer profile contract has no contact fields, so this is the only
    // real source for them and it is only used when the session has them.
    final session = auth is AuthAuthenticated ? auth.profile : null;
    final email = session?.email.trim() ?? '';
    final phone = session?.phone.trim() ?? '';

    // Two columns only where there is genuinely room for them: the expanded and
    // large window classes, and not when enlarged text needs the width.
    final wide = _useWideComposition(context);

    // A viewport-proportional floor makes the account surface occupy the
    // canvas on tall screens. It is a minimum, never a fixed height: real
    // content (long names, enlarged text) grows it.
    final floor = wide
        ? (MediaQuery.sizeOf(context).height * 0.78).clamp(520.0, 720.0)
        : 0.0;

    Future<void> refresh() =>
        ref.read(customerDashboardProvider.notifier).refresh();

    Widget signOut() => _SignOutButton(
      onPressed: () async {
        await showLogoutDialog(
          context,
          onLogout: () {
            ref.read(authNotifierProvider.notifier).logout();
          },
        );
      },
    );

    Widget? notice() => profile != null
        ? null
        : CustomerNoticePanel(
            message: "We couldn't load your account.",
            actionLabel: 'Retry',
            onAction: refresh,
          );

    Widget? identityBlock({required bool prominent}) => profile == null
        ? null
        : _IdentityBlock(
            name: _displayName(profile),
            reference: profile.memberId.trim(),
            initials: _initials(profile),
            summary: _summary(dash),
            prominent: prominent,
          );

    // Inside the wide account panel the panel supplies the horizontal inset.
    List<Widget> contactRows({required bool insidePanel}) => [
      if (email.isNotEmpty)
        _InfoRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: email,
          padding: insidePanel ? _panelRowPadding : null,
        ),
      if (phone.isNotEmpty)
        _InfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: phone,
          padding: insidePanel ? _panelRowPadding : null,
        ),
    ];

    return SizedBox.expand(
      child: RefreshIndicator(
        onRefresh: refresh,
        color: Theme.of(context).colorScheme.primary,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          maxContentWidth: wide ? _wideContentWidth : _stackedContentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (dash.isLoading && profile == null)
                _ProfileSkeleton(wide: wide, floor: floor)
              else ...[
                const _PageTitle(),
                const SizedBox(height: AppDimensions.s16),
                if (dash.loadError.isNotEmpty && profile != null) ...[
                  CustomerRefreshNotice(onRetry: refresh),
                  const SizedBox(height: AppDimensions.s16),
                ],
                if (wide)
                  _WideWorkspace(
                    key: const ValueKey('profile-account-workspace'),
                    floor: profile == null ? 0 : floor,
                    identity: identityBlock(prominent: true),
                    notice: notice(),
                    contact: contactRows(insidePanel: true),
                    groups: _groups(context, ref),
                    session: _session(signOut()),
                  )
                else ...[
                  if (notice() case final notice?) ...[
                    notice,
                    const SizedBox(height: AppDimensions.s20),
                  ],
                  if (identityBlock(prominent: false) case final identity?) ...[
                    _IdentityPanel(child: identity),
                    if (contactRows(insidePanel: false) case final contact
                        when contact.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s20),
                      const _SectionLabel('Contact'),
                      const SizedBox(height: AppDimensions.s8),
                      _Group(children: contact),
                    ],
                    const SizedBox(height: AppDimensions.s20),
                  ],
                  _groups(context, ref),
                  const SizedBox(height: AppDimensions.s28),
                  signOut(),
                ],
                const SizedBox(height: AppDimensions.s32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The account actions and about group, using only routes that already exist.
  Widget _groups(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(customerDashboardProvider).vehicles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Account'),
        const SizedBox(height: AppDimensions.s8),
        _Group(
          children: [
            _ActionRow(
              icon: Icons.directions_car_outlined,
              title: 'Vehicles',
              subtitle: 'Cars registered to your account',
              trailingText: vehicles == 0 ? 'None' : '$vehicles',
              onTap: () => ref
                  .read(customerDashboardProvider.notifier)
                  .selectDestination(CustomerDestination.vehicles),
            ),
            _ActionRow(
              icon: Icons.car_crash_outlined,
              title: 'Roadside assistance',
              subtitle: 'Request help when your vehicle breaks down',
              onTap: () => context.push(AppRoutes.customerBreakdownHelp),
            ),
            _ActionRow(
              icon: Icons.lock_outline_rounded,
              title: 'Reset password',
              subtitle: 'Verify with a one-time code, then set a new password',
              onTap: () => context.push(AppRoutes.forgotPassword),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.s20),
        const _SectionLabel('About'),
        const SizedBox(height: AppDimensions.s8),
        _Group(
          children: [
            _ActionRow(
              icon: Icons.article_outlined,
              title: 'Open source licences',
              subtitle: 'Software used by this app',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Orient Customer App',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _session(Widget signOut) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionLabel('Session'),
      const SizedBox(height: AppDimensions.s8),
      signOut,
    ],
  );
}

/// Contact rows inside the wide account panel: the panel owns the inset.
const EdgeInsetsGeometry _panelRowPadding = EdgeInsets.symmetric(
  vertical: AppDimensions.s10,
);

/// True when Profile should compose two columns beside each other.
///
/// Gated on the expanded/large window classes and on normal text scale: at
/// 1.6x the identity and action columns would be too narrow for a long name and
/// a long email, so the page stacks and stays readable instead.
bool _useWideComposition(BuildContext context) {
  final adaptive = context.adaptive;
  final textScale = MediaQuery.textScalerOf(context).scale(1);
  return (adaptive.isExpanded || adaptive.isLarge) && textScale <= 1.3;
}

/// The account's own name, or a neutral label when the server returned none.
///
/// A missing name is never replaced by a plausible-looking account value.
String _displayName(CustomerEntity profile) {
  final name = profile.name.trim();
  if (name.isNotEmpty) return name;
  final first = profile.firstName.trim();
  if (first.isNotEmpty) return first;
  return 'Your account';
}

/// Initials the server derived, or derived locally from a real name.
///
/// Deriving an avatar mark from a real name is a presentation step; inventing
/// one when there is no name is not, so this returns an empty string and the
/// avatar falls back to a neutral icon.
String _initials(CustomerEntity profile) {
  final given = profile.avatarInitials.trim();
  if (given.isNotEmpty) return given;
  final name = profile.name.trim().isNotEmpty
      ? profile.name.trim()
      : profile.firstName.trim();
  if (name.isEmpty) return '';
  final parts = name
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// A compact, real account summary: registered vehicles and live service.
String _summary(CustomerDashboardState dash) {
  final count = dash.vehicles.length;
  final vehicles = switch (count) {
    0 => 'No vehicles yet',
    1 => '1 vehicle',
    _ => '$count vehicles',
  };
  if (!CustomerServiceTracking.isLiveService(dash.activeService)) {
    return vehicles;
  }
  return '$vehicles  •  Service in progress';
}

/// The wide composition: one full-height account panel beside the account
/// actions, both sharing a bottom edge.
///
/// [IntrinsicHeight] plus a non-zero floor makes the row exactly
/// `max(floor, content)` tall, which is legal inside the page's scroll view and
/// never clips enlarged text. Every child stays compact; only the surfaces
/// around them take the height.
class _WideWorkspace extends StatelessWidget {
  final double floor;
  final Widget? identity;
  final Widget? notice;
  final List<Widget> contact;
  final Widget groups;
  final Widget session;

  const _WideWorkspace({
    super.key,
    required this.floor,
    required this.identity,
    required this.notice,
    required this.contact,
    required this.groups,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final account = identity;

    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: floor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: account == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [if (notice != null) notice!],
                    )
                  : CustomerSurfacePanel(
                      accent: colors.primary,
                      emphasised: true,
                      padding: const EdgeInsets.all(AppDimensions.s20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: contact.isEmpty
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.spaceBetween,
                        children: [
                          account,
                          if (contact.isNotEmpty) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Divider(
                                  height: 1,
                                  color: colors.primary.withValues(alpha: 0.18),
                                ),
                                const SizedBox(height: AppDimensions.s12),
                                const _SectionLabel('Contact'),
                                const SizedBox(height: AppDimensions.s6),
                                for (final row in contact) row,
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: AppDimensions.s24),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [groups, session],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      header: true,
      child: Text(
        'Profile',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

/// The one place that says who is signed in.
class _IdentityBlock extends StatelessWidget {
  final String name;
  final String reference;
  final String initials;
  final String summary;

  /// Wide screens give the account itself more presence.
  final bool prominent;

  const _IdentityBlock({
    required this.name,
    required this.reference,
    required this.initials,
    required this.summary,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatar = prominent ? 72.0 : 56.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: Container(
            width: avatar,
            height: avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
              border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
            ),
            child: initials.isEmpty
                ? Icon(
                    Icons.person_outline_rounded,
                    size: prominent
                        ? AppDimensions.iconXl
                        : AppDimensions.iconLg,
                    color: colors.primary,
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.s4),
                      child: Text(
                        initials,
                        style:
                            (prominent
                                    ? theme.textTheme.headlineSmall
                                    : theme.textTheme.titleLarge)
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                  ),
          ),
        ),
        SizedBox(width: prominent ? AppDimensions.s16 : AppDimensions.s14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (prominent
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
              ),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  reference,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
              if (summary.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.s4),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The compact identity surface — the account's own details on a phone.
class _IdentityPanel extends StatelessWidget {
  final Widget child;

  const _IdentityPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomerSurfacePanel(
      accent: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: child,
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  final bool wide;
  final double floor;

  const _ProfileSkeleton({required this.wide, required this.floor});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton(
      builder: (context, block) {
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerSkeletonBox(width: 110, height: 26, color: block),
              const SizedBox(height: AppDimensions.s16),
              CustomerSkeletonBox(
                height: 88,
                color: block,
                radius: AppDimensions.radiusCard,
              ),
              const SizedBox(height: AppDimensions.s20),
              CustomerSkeletonBox(
                height: 186,
                color: block,
                radius: AppDimensions.radiusCard,
              ),
            ],
          );
        }

        return SizedBox(
          height: floor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CustomerSkeletonBox(
                  height: floor,
                  color: block,
                  radius: AppDimensions.radiusPanel,
                ),
              ),
              const SizedBox(width: AppDimensions.s24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomerSkeletonBox(
                      height: 330,
                      color: block,
                      radius: AppDimensions.radiusCard,
                    ),
                    CustomerSkeletonBox(
                      height: 80,
                      color: block,
                      radius: AppDimensions.radiusCard,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
