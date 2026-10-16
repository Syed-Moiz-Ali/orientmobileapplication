import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Signed-in staff account surface shared by Technicians, Advisors and
/// Supervisors: identity dossier, real preferences, the account actions that
/// exist, and a guarded danger zone.
///
/// Phase 12 dossier-mini recomposition (home-grammar sibling of the advisor
/// job dossier): identity card (64 avatar + name + role badge + branch·shift
/// + attendance dot) owns the top; preference rows, work/contact groups and
/// the danger zone follow. Only values sourced from the session profile are
/// shown. Notification preferences, theme switching and photo upload stay
/// out: no API or local contract exists for them (asserted by tests).
class StaffProfileScreen extends ConsumerWidget {
  final ProfileData? data;

  const StaffProfileScreen({super.key, this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final me = auth is AuthAuthenticated ? auth.profile : null;
    final profile = _StaffProfile.from(profile: me, data: data);

    final canPop = Navigator.of(context).canPop();
    final workFields = _workFields(t, profile);
    final contactFields = _contactFields(t, profile);

    final header = AppPageHeader(
      title: t.staffProfileTitle,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                HapticFeedback.selectionClick();
                context.pop();
              },
            )
          : null,
    );

    final identity = _IdentityCard(profile: profile);
    final prefs = const _PrefsSection();
    final work = workFields.isNotEmpty
        ? _FieldGroupSection(title: t.staffProfileWork, fields: workFields)
        : null;
    final contact = contactFields.isNotEmpty
        ? _FieldGroupSection(title: t.staffProfileContact, fields: contactFields)
        : null;
    const account = _AccountPanel();
    final danger = _DangerSection(ref: ref);

    // Identity left + preferences and facts right on wide viewports; a
    // single dossier stream below that. Never a stretched phone column.
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AppPageFrame(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final headerGap = SizedBox(
                height: context.adaptive.sectionSpacing * 0.75,
              );

              if (wide) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        headerGap,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 340,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  identity,
                                  const SizedBox(height: AppDimensions.s24),
                                  prefs,
                                ],
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (work != null) ...[
                                    work,
                                    const SizedBox(height: AppDimensions.s24),
                                  ],
                                  if (contact != null) ...[
                                    contact,
                                    const SizedBox(height: AppDimensions.s24),
                                  ],
                                  account,
                                  const SizedBox(height: AppDimensions.s24),
                                  danger,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s24),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  headerGap,
                  identity,
                  const SizedBox(height: AppDimensions.s24),
                  prefs,
                  if (work != null) ...[
                    const SizedBox(height: AppDimensions.s24),
                    work,
                  ],
                  if (contact != null) ...[
                    const SizedBox(height: AppDimensions.s24),
                    contact,
                  ],
                  const SizedBox(height: AppDimensions.s28),
                  account,
                  const SizedBox(height: AppDimensions.s24),
                  danger,
                  const SizedBox(height: AppDimensions.s24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StaffProfile {
  final String name;
  final String initials;
  final String empId;
  final String role;
  final String branch;
  final String shift;
  final String department;
  final String designation;
  final String email;
  final String phone;

  const _StaffProfile({
    required this.name,
    required this.initials,
    required this.empId,
    required this.role,
    required this.branch,
    required this.shift,
    required this.department,
    required this.designation,
    required this.email,
    required this.phone,
  });

  factory _StaffProfile.from({MeResponse? profile, ProfileData? data}) {
    final name = _firstNonEmpty([data?.name, profile?.name, 'Staff Member']);
    final role = _firstNonEmpty([
      data?.role,
      profile?.designation,
      profile?.role,
      'Staff',
    ]);

    return _StaffProfile(
      name: name,
      initials: _normalizeInitials(
        _firstNonEmpty([
          data?.avatarInitials,
          profile?.avatarInitials,
          profile?.initials,
          _initials(name),
        ]),
      ),
      // Only the workshop-facing employee id is shown. The database primary
      // key (staffId) is deliberately never displayed as an employee id.
      empId: _firstNonEmpty([data?.id, profile?.empId]),
      role: role,
      branch: _firstNonEmpty([data?.branch, profile?.branchName]),
      shift: _firstNonEmpty([data?.shift, profile?.shift]),
      department: _firstNonEmpty([profile?.department]),
      designation: _firstNonEmpty([profile?.designation, role]),
      email: _firstNonEmpty([data?.email, profile?.email]),
      phone: _firstNonEmpty([data?.phone, profile?.phone]),
    );
  }
}

List<_ProfileField> _workFields(StaffLocalizations t, _StaffProfile profile) {
  final showDesignation =
      profile.designation.isNotEmpty &&
      profile.designation.toLowerCase() != profile.role.toLowerCase();

  return <_ProfileField>[
    if (showDesignation)
      _ProfileField(
        icon: Icons.assignment_ind_outlined,
        label: t.staffProfileDesignation,
        value: profile.designation,
      ),
    if (profile.department.isNotEmpty)
      _ProfileField(
        icon: Icons.groups_2_outlined,
        label: t.staffProfileDepartment,
        value: profile.department,
      ),
    if (profile.branch.isNotEmpty)
      _ProfileField(
        icon: Icons.business_outlined,
        label: t.staffProfileBranch,
        value: profile.branch,
      ),
    if (profile.shift.isNotEmpty)
      _ProfileField(
        icon: Icons.schedule_outlined,
        label: t.staffProfileShift,
        value: profile.shift,
      ),
  ];
}

List<_ProfileField> _contactFields(
  StaffLocalizations t,
  _StaffProfile profile,
) {
  return <_ProfileField>[
    if (profile.email.isNotEmpty)
      _ProfileField(
        icon: Icons.email_outlined,
        label: t.staffProfileEmail,
        value: profile.email,
      ),
    if (profile.phone.isNotEmpty)
      _ProfileField(
        icon: Icons.phone_outlined,
        label: t.staffProfilePhone,
        value: profile.phone,
        isMono: true,
      ),
  ];
}

/// Identity dossier card: 64 avatar (once), name, role badge, branch·shift
/// context and the live attendance dot. Long values wrap instead of
/// truncating so names and emails stay readable at 320px and 1.6x.
class _IdentityCard extends ConsumerWidget {
  final _StaffProfile profile;

  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasEmpId = profile.empId.isNotEmpty;
    final contextLine = [
      profile.branch,
      profile.shift,
    ].where((s) => s.trim().isNotEmpty).join(' · ');
    final attendance = ref.watch(staffAttendanceProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: AppDimensions.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        profile.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.designation.isNotEmpty
                          ? profile.designation
                          : profile.role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s6),
                    StatusPill.neutral(profile.role),
                  ],
                ),
              ),
            ],
          ),
          if (contextLine.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s10),
            Text(
              contextLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s8),
          _AttendanceDot(state: attendance),
          if (hasEmpId) ...[
            const SizedBox(height: AppDimensions.s16),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.s12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s8,
                vertical: AppDimensions.s4,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 13,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s4),
                  Flexible(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        profile.empId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: AppFontFamilies.mono,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Live attendance dot sourced from the shared attendance provider (neutral
/// while loading or on error — never a fabricated state).
class _AttendanceDot extends StatelessWidget {
  final StaffAttendanceState state;
  const _AttendanceDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final known =
        !state.isLoading && state.error.isEmpty;
    final dot = !known
        ? semantic.neutral.base
        : switch (state.status) {
            StaffAttendanceStatus.working => semantic.success.base,
            StaffAttendanceStatus.onBreak => semantic.warning.base,
            StaffAttendanceStatus.notPunchedIn => semantic.neutral.base,
            StaffAttendanceStatus.punchedOut => semantic.neutral.base,
          };
    final label = switch (state.status) {
      StaffAttendanceStatus.working => t.staffAttWorking,
      StaffAttendanceStatus.onBreak => t.staffAttOnBreak,
      StaffAttendanceStatus.notPunchedIn => t.staffAttNotPunched,
      StaffAttendanceStatus.punchedOut => t.staffAttShiftComplete,
    };
    return Semantics(
      container: true,
      label: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.s6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Real preferences only: the shared language switcher (persisted locale),
/// a change-password sheet over the real OTP recovery flow, and navigation
/// to the sync diagnostics. Theme switching, notification preferences and
/// photo upload stay out: no contract exists for them.
class _PrefsSection extends StatelessWidget {
  const _PrefsSection();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: t.staffProfilePrefs)),
        const SizedBox(height: AppDimensions.s8),
        const LanguageSwitcher(),
        const SizedBox(height: AppDimensions.s8),
        _PrefsRow(
          icon: Icons.lock_reset_rounded,
          title: t.staffProfileChangePassword,
          onTap: () => _openChangePassword(context),
        ),
        const SizedBox(height: AppDimensions.s8),
        _PrefsRow(
          icon: Icons.sync_rounded,
          title: t.staffProfileStorage,
          subtitle: t.staffProfileStorageSubtitle,
          onTap: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  void _openChangePassword(BuildContext context) {
    HapticFeedback.selectionClick();
    final t = StaffLocalizations.of(context)!;
    showAppModalSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.staffProfileChangePasswordTitle,
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            Text(
              t.staffProfileChangePasswordBody,
              style: Theme.of(
                sheetContext,
              ).textTheme.bodySmall?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppDimensions.s16),
            PrimaryButton(
              label: t.staffProfileContinue,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                Navigator.pop(sheetContext);
                sheetContext.push(AppRoutes.forgotPassword);
              },
            ),
            const SizedBox(height: AppDimensions.s8),
            SecondaryButton(
              label: t.staffProfileCancel,
              onPressed: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrefsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _PrefsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
            child: Row(
              children: [
                Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                DirectionalIcon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled group of work/contact fields on a single grouped surface with
/// subtle dividers.
class _FieldGroupSection extends StatelessWidget {
  final String title;
  final List<_ProfileField> fields;

  const _FieldGroupSection({required this.title, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: title)),
        const SizedBox(height: AppDimensions.s8),
        _FieldGroupCard(fields: fields),
      ],
    );
  }
}

class _ProfileField {
  final IconData icon;
  final String label;
  final String value;
  final bool isMono;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.value,
    this.isMono = false,
  });
}

class _FieldGroupCard extends StatelessWidget {
  final List<_ProfileField> fields;

  const _FieldGroupCard({required this.fields});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: AppDimensions.shadowCard,
      ),
      child: Column(
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s16,
                vertical: AppDimensions.s12,
              ),
              child: MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        fields[i].icon,
                        size: AppDimensions.iconSm,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fields[i].label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fields[i].value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontFamily: fields[i].isMono
                                  ? AppFontFamilies.mono
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < fields.length - 1)
              Divider(
                height: 1,
                indent: 60,
                color: colors.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

/// Real account actions only: the shared OTP password-reset flow and the
/// Flutter open-source licence page. Nothing else is offered because nothing
/// else exists.
class _AccountPanel extends StatelessWidget {
  const _AccountPanel();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: t.staffProfileAccount)),
        const SizedBox(height: AppDimensions.s8),
        _AccountSurface(
          children: [
            _AccountActionRow(
              icon: Icons.lock_reset_rounded,
              title: t.staffProfileResetPassword,
              subtitle: t.staffProfileResetSubtitle,
              onTap: () {
                HapticFeedback.selectionClick();
                context.push(AppRoutes.forgotPassword);
              },
            ),
            Divider(
              height: 1,
              indent: 64,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            _AccountActionRow(
              icon: Icons.article_outlined,
              title: t.staffProfileLicences,
              subtitle: t.staffProfileLicencesSubtitle,
              onTap: () {
                HapticFeedback.selectionClick();
                showLicensePage(
                  context: context,
                  applicationName: 'Orient Staff App',
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountSurface extends StatelessWidget {
  final List<Widget> children;

  const _AccountSurface({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: AppDimensions.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _AccountActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return MergeSemantics(
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDimensions.touchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
            child: Row(
              children: [
                Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
                const SizedBox(width: AppDimensions.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                DirectionalIcon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Danger zone: the session sign-out behind its truthful confirmation. Cache
/// management lives one tap away in Settings (single home, no duplication).
class _DangerSection extends StatelessWidget {
  final WidgetRef ref;

  const _DangerSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: t.staffProfileDanger)),
        const SizedBox(height: AppDimensions.s8),
        _PrefsRow(
          icon: Icons.sync_rounded,
          title: t.staffProfileStorage,
          subtitle: t.staffProfileStorageSubtitle,
          onTap: () => context.push(AppRoutes.settings),
        ),
        const SizedBox(height: AppDimensions.s8),
        _SignOutButton(ref: ref),
      ],
    );
  }
}

/// Sign out action with a truthful confirmation.
///
/// Sign-out clears the device cache and any queued operations, so when work is
/// still waiting to sync the technician is warned before signing out instead
/// of silently losing changes saved on this device.
class _SignOutButton extends StatelessWidget {
  final WidgetRef ref;

  const _SignOutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final t = StaffLocalizations.of(context)!;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error.withValues(alpha: 0.35)),
        minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),
      icon: const Icon(Icons.logout_rounded, size: AppDimensions.iconSm),
      label: Text(
        t.staffProfileSignOut,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: () async {
        HapticFeedback.heavyImpact();
        final pending = HiveCleaner.hasPendingSync();
        final confirmed = await showAppConfirmationDialog(
          context,
          title: pending
              ? t.staffProfileSignOutUnsyncedTitle
              : t.staffProfileSignOutTitle,
          message: pending
              ? t.staffProfileSignOutUnsyncedMessage
              : t.staffProfileSignOutMessage,
          confirmLabel: t.staffProfileSignOut,
          cancelLabel: t.staffProfileStaySignedIn,
          icon: Icons.logout_rounded,
          destructive: true,
        );
        if (!confirmed) return;
        await ref.read(authNotifierProvider.notifier).logout();
      },
    );
  }
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _normalizeInitials(String value) {
  if (value.length <= 2) return value;
  return value.substring(0, 2).toUpperCase();
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'S';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
