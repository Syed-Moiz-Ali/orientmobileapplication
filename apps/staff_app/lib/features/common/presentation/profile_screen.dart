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

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  context.pop();
                },
              )
            : null,
        centerTitle: true,
        title: Text(
          profile.role.isEmpty ? 'Staff Profile' : '${profile.role} Profile',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHero(profile: profile),
              const SizedBox(height: 16),
              _MetricGrid(profile: profile),
              const SizedBox(height: 24),
              _SectionTitle('Account Details'),
              const SizedBox(height: 12),
              _InfoGroup(
                rows: [
                  _InfoRow(Icons.badge_outlined, 'Staff ID', profile.empId),
                  _InfoRow(Icons.work_outline_rounded, 'Role', profile.role),
                  _InfoRow(Icons.business_outlined, 'Branch', profile.branch),
                  _InfoRow(Icons.schedule_outlined, 'Shift', profile.shift),
                  _InfoRow(Icons.email_outlined, 'Email', profile.email),
                  _InfoRow(Icons.phone_outlined, 'Phone', profile.phone),
                  _InfoRow(
                    Icons.groups_2_outlined,
                    'Department',
                    profile.department,
                  ),
                  _InfoRow(
                    Icons.assignment_ind_outlined,
                    'Designation',
                    profile.designation,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle('Security & Access'),
              const SizedBox(height: 12),
              _InfoGroup(
                rows: const [
                  _InfoRow(
                    Icons.fingerprint_rounded,
                    'Biometric Login',
                    'Managed by device settings',
                  ),
                  _InfoRow(
                    Icons.lock_outline_rounded,
                    'Account Credentials',
                    'Use sign-in or OTP flow',
                  ),
                  _InfoRow(
                    Icons.notifications_active_outlined,
                    'Notifications',
                    'Firebase push enabled after login',
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Sign out',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  await showLogoutDialog(
                    context,
                    onLogout: () =>
                        ref.read(authNotifierProvider.notifier).logout(),
                  );
                },
              ),
            ],
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

class _ProfileHero extends StatelessWidget {
  final _StaffProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: colors.primaryContainer,
            child: Text(
              profile.initials,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.designation.isEmpty ? profile.role : profile.designation,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: profile.empId.isEmpty ? 'STAFF ACCOUNT' : profile.empId,
              ),
              _Chip(label: profile.branch.isEmpty ? 'ACTIVE' : profile.branch),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final _StaffProfile profile;

  const _MetricGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.schedule_rounded,
            label: 'Shift',
            value: profile.shift,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            icon: Icons.business_rounded,
            label: 'Branch',
            value: profile.branch,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MetricTile(
            icon: Icons.badge_rounded,
            label: 'Dept',
            value: profile.department,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? 'Not set' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  final List<_InfoRow> rows;

  const _InfoGroup({required this.rows});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              Divider(height: 1, color: colors.outlineVariant, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not available' : value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w900,
      ),
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
