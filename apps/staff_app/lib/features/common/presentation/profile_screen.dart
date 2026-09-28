import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';

class StaffProfileScreen extends ConsumerWidget {
  final ProfileData? data;

  const StaffProfileScreen({super.key, this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final auth = ref.watch(authNotifierProvider);
    final me = auth is AuthAuthenticated ? auth.profile : null;
    final profile = _StaffProfile.from(profile: me, data: data);

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: _IdentityCard(profile: profile),
                    ),
                    const SizedBox(width: AppDimensions.s24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _WorkContextPanel(profile: profile),
                          const SizedBox(height: AppDimensions.s20),
                          _ContactInfoPanel(profile: profile),
                          const SizedBox(height: AppDimensions.s28),
                          _SignOutSection(ref: ref),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IdentityCard(profile: profile),
                  const SizedBox(height: AppDimensions.s20),
                  _WorkContextPanel(profile: profile),
                  const SizedBox(height: AppDimensions.s20),
                  _ContactInfoPanel(profile: profile),
                  const SizedBox(height: AppDimensions.s28),
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
      initials: _firstNonEmpty([
        data?.avatarInitials,
        profile?.avatarInitials,
        profile?.initials,
        _initials(name),
      ]),
      empId: _firstNonEmpty([
        data?.id,
        profile?.empId,
        profile?.staffId?.toString(),
      ]),
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

/// Compact, professional identity surface without giant circular avatars or fake chips.
class _IdentityCard extends StatelessWidget {
  final _StaffProfile profile;

  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasEmpId = profile.empId.isNotEmpty;
    final hasBranch = profile.branch.isNotEmpty;

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
                    Text(
                      profile.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasEmpId || hasBranch) ...[
            const SizedBox(height: AppDimensions.s16),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasEmpId)
                  Container(
                    margin: EdgeInsets.only(
                      bottom: hasBranch ? AppDimensions.s8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s8,
                      vertical: AppDimensions.s4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXs,
                      ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hasBranch)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.s8,
                      vertical: AppDimensions.s4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXs,
                      ),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppDimensions.s4),
                        Flexible(
                          child: Text(
                            profile.branch,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Work context section grouping role, designation, branch, shift, and department.
class _WorkContextPanel extends StatelessWidget {
  final _StaffProfile profile;

  const _WorkContextPanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final showDesignation =
        profile.designation.isNotEmpty &&
        profile.designation.toLowerCase() != profile.role.toLowerCase();

    final items = <_ProfileField>[
      if (profile.role.isNotEmpty)
        _ProfileField(
          icon: Icons.work_outline_rounded,
          label: 'Role',
          value: profile.role,
        ),
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

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Work Information'),
        const SizedBox(height: AppDimensions.s8),
        _FieldGroupCard(fields: items),
      ],
    );
  }
}

/// Contact information section grouping email and phone.
class _ContactInfoPanel extends StatelessWidget {
  final _StaffProfile profile;

  const _ContactInfoPanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = <_ProfileField>[
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

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Contact Details'),
        const SizedBox(height: AppDimensions.s8),
        _FieldGroupCard(fields: items),
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
              child: Row(
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

/// Sign out action with standard dialog confirmation.
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
        minimumSize: const Size.fromHeight(48),
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
        await showLogoutDialog(
          context,
          onLogout: () => ref.read(authNotifierProvider.notifier).logout(),
        );
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

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return 'S';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
