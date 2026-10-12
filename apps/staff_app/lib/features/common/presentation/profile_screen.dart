import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';

/// Signed-in staff account surface shared by Technicians, Advisors and
/// Supervisors: who am I, what work/contact details does the app actually
/// know, the real account actions, and sign out.
///
/// Only values that can be sourced from the session profile are shown. There
/// is no profile editing, no photo upload, no notification preferences and no
/// performance content because no API or local contract exists for them.
class StaffProfileScreen extends ConsumerWidget {
  final ProfileData? data;

  const StaffProfileScreen({super.key, this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final me = auth is AuthAuthenticated ? auth.profile : null;
    final profile = _StaffProfile.from(profile: me, data: data);

    final canPop = Navigator.of(context).canPop();
    final workFields = _workFields(profile);
    final contactFields = _contactFields(profile);

    return Scaffold(
      body: SafeArea(
        child: AppPageFrame(
          title: 'Profile',
          subtitle: profile.role.isNotEmpty ? '${profile.role} account' : null,
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                  },
                )
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;

              if (isWide) {
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300,
                          child: _IdentityCard(profile: profile),
                        ),
                        const SizedBox(width: AppDimensions.s24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (workFields.isNotEmpty) ...[
                                _FieldGroupSection(
                                  title: 'Work Information',
                                  fields: workFields,
                                ),
                                const SizedBox(height: AppDimensions.s24),
                              ],
                              if (contactFields.isNotEmpty) ...[
                                _FieldGroupSection(
                                  title: 'Contact Details',
                                  fields: contactFields,
                                ),
                                const SizedBox(height: AppDimensions.s24),
                              ],
                              const _AccountPanel(),
                              const SizedBox(height: AppDimensions.s32),
                              _SignOutSection(ref: ref),
                              const SizedBox(height: AppDimensions.s24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IdentityCard(profile: profile),
                  if (workFields.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s24),
                    _FieldGroupSection(
                      title: 'Work Information',
                      fields: workFields,
                    ),
                  ],
                  if (contactFields.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.s24),
                    _FieldGroupSection(
                      title: 'Contact Details',
                      fields: contactFields,
                    ),
                  ],
                  const SizedBox(height: AppDimensions.s28),
                  const _AccountPanel(),
                  const SizedBox(height: AppDimensions.s32),
                  _SignOutSection(ref: ref),
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

List<_ProfileField> _workFields(_StaffProfile profile) {
  final showDesignation =
      profile.designation.isNotEmpty &&
      profile.designation.toLowerCase() != profile.role.toLowerCase();

  return <_ProfileField>[
    if (showDesignation)
      _ProfileField(
        icon: Icons.assignment_ind_outlined,
        label: 'Designation',
        value: profile.designation,
      ),
    if (profile.department.isNotEmpty)
      _ProfileField(
        icon: Icons.groups_2_outlined,
        label: 'Department',
        value: profile.department,
      ),
    if (profile.branch.isNotEmpty)
      _ProfileField(
        icon: Icons.business_outlined,
        label: 'Branch',
        value: profile.branch,
      ),
    if (profile.shift.isNotEmpty)
      _ProfileField(
        icon: Icons.schedule_outlined,
        label: 'Shift',
        value: profile.shift,
      ),
  ];
}

List<_ProfileField> _contactFields(_StaffProfile profile) {
  return <_ProfileField>[
    if (profile.email.isNotEmpty)
      _ProfileField(
        icon: Icons.email_outlined,
        label: 'Email',
        value: profile.email,
      ),
    if (profile.phone.isNotEmpty)
      _ProfileField(
        icon: Icons.phone_outlined,
        label: 'Phone',
        value: profile.phone,
        isMono: true,
      ),
  ];
}

/// Compact, professional identity surface without giant circular avatars or
/// fake chips. Values wrap instead of truncating so long names, emails and
/// identifiers stay readable at 320px and at 1.6x text scaling.
class _IdentityCard extends StatelessWidget {
  final _StaffProfile profile;

  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasEmpId = profile.empId.isNotEmpty;

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
                width: 56,
                height: 56,
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
                  style: theme.textTheme.titleLarge?.copyWith(
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
                  ],
                ),
              ),
            ],
          ),
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
                    child: Text(
                      profile.empId,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFontFamilies.mono,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: 'Account')),
        const SizedBox(height: AppDimensions.s8),
        _AccountSurface(
          children: [
            _AccountActionRow(
              icon: Icons.lock_reset_rounded,
              title: 'Reset password',
              subtitle: 'Uses the secure password reset flow',
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
              title: 'Open source licences',
              subtitle: 'Legal notices for the software in this app',
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
                Icon(
                  Icons.chevron_right_rounded,
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

/// Sign out action with a truthful confirmation.
///
/// Sign-out clears the device cache and any queued operations, so when work is
/// still waiting to sync the technician is warned before signing out instead
/// of silently losing changes saved on this device.
class _SignOutSection extends StatelessWidget {
  final WidgetRef ref;

  const _SignOutSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
      label: const Text(
        'Sign out',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      onPressed: () async {
        HapticFeedback.heavyImpact();
        final pending = HiveCleaner.hasPendingSync();
        final confirmed = await showAppConfirmationDialog(
          context,
          title: pending ? 'Sign out with unsynced work?' : 'Sign out?',
          message: pending
              ? 'Some work is still waiting to sync. Signing out will remove '
                    'the changes saved on this device.'
              : 'You will need to sign in again to continue.',
          confirmLabel: 'Sign out',
          cancelLabel: 'Stay signed in',
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
