import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/common/presentation/owner_shimmer_skeletons.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';

class TeamView extends ConsumerStatefulWidget {
  const TeamView({super.key});

  @override
  ConsumerState<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends ConsumerState<TeamView> {
  final _searchCtrl = TextEditingController();
  String _selectedRole = 'all';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(teamProvider);
    final notifier = ref.read(teamProvider.notifier);

    final query = _searchCtrl.text.trim().toLowerCase();
    final filteredStaff = state.staff.where((m) {
      final matchesRole = _selectedRole == 'all' ||
          m.role.toLowerCase() == _selectedRole.toLowerCase();
      final matchesQuery = query.isEmpty ||
          m.name.toLowerCase().contains(query) ||
          m.empId.toLowerCase().contains(query) ||
          m.phone.toLowerCase().contains(query) ||
          m.branch.toLowerCase().contains(query) ||
          m.role.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();

    final activeCount = state.staff.where((m) => m.isActive).length;
    final advisorCount = state.staff.where((m) => m.role.toLowerCase() == 'advisor').length;
    final supervisorCount = state.staff.where((m) => m.role.toLowerCase() == 'supervisor').length;
    final techCount = state.staff.where((m) => m.role.toLowerCase() == 'technician').length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Team & Permissions',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: notifier.load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showAddStaffSheet(
          context,
          notifier,
          state.branches,
          colorScheme,
          textTheme,
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Add Member',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
      ),
      body: state.isLoading
          ? const OwnerDashboardSkeleton()
          : state.error.isNotEmpty && state.staff.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.error,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: notifier.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Executive Summary Header Card (Solid Surface, 0 Gradients)
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.badge_rounded,
                                      color: colorScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Workshop Staff Directory',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusPill(
                                    label: '$activeCount / ${state.staff.length} ACTIVE',
                                    bg: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    fg: const Color(0xFF10B981),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _SummaryPill(
                                    label: 'Advisors',
                                    count: advisorCount,
                                    colorScheme: colorScheme,
                                    textTheme: textTheme,
                                  ),
                                  const SizedBox(width: 8),
                                  _SummaryPill(
                                    label: 'Supervisors',
                                    count: supervisorCount,
                                    colorScheme: colorScheme,
                                    textTheme: textTheme,
                                  ),
                                  const SizedBox(width: 8),
                                  _SummaryPill(
                                    label: 'Technicians',
                                    count: techCount,
                                    colorScheme: colorScheme,
                                    textTheme: textTheme,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Search Bar
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorScheme.outlineVariant),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (_) => setState(() {}),
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Search by staff name, ID, phone, role or branch...',
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              suffixIcon: _searchCtrl.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Chips Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ('all', 'All Staff'),
                              ('advisor', 'Service Advisors'),
                              ('supervisor', 'Supervisors'),
                              ('technician', 'Technicians'),
                            ].map((item) {
                              final sel = _selectedRole == item.$1;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  selected: sel,
                                  showCheckmark: false,
                                  label: Text(
                                    item.$2,
                                    style: textTheme.labelMedium?.copyWith(
                                      color: sel ? colorScheme.onPrimary : colorScheme.onSurface,
                                      fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  selectedColor: colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  onSelected: (_) => setState(() => _selectedRole = item.$1),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (filteredStaff.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                          const SizedBox(height: 12),
                          Text(
                            'No staff members match filter criteria',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final m = filteredStaff[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StaffCard(
                              member: m,
                              notifier: notifier,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          );
                        },
                        childCount: filteredStaff.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void _showAddStaffSheet(
    BuildContext context,
    TeamNotifier notifier,
    List<BranchOption> branches,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final empIdCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();
    final shiftCtrl = TextEditingController();
    final designationCtrl = TextEditingController();
    final departmentCtrl = TextEditingController();
    var role = 'advisor';
    String? branchId;
    var isSubmitting = false;
    const roles = ['advisor', 'supervisor', 'technician'];

    InputDecoration fieldDecoration(String label, IconData icon) =>
        InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create Staff Login',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    'Create their Staff app access and add their workshop details.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Full name',
                      Icons.person_outline_rounded,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the staff member name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: empIdCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: fieldDecoration(
                      'Staff ID (e.g. ADV002)',
                      Icons.badge_outlined,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a unique staff ID'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: fieldDecoration(
                      'Staff app role',
                      Icons.admin_panel_settings_outlined,
                    ),
                    items: roles
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value[0].toUpperCase() + value.substring(1),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => role = value ?? 'advisor',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Login credentials',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: fieldDecoration(
                      'Mobile number with country code',
                      Icons.phone_outlined,
                    ),
                    validator: (value) {
                      final digits = (value ?? '').replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      return digits.length < 8
                          ? 'Enter a valid mobile number'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: fieldDecoration(
                      'Email address',
                      Icons.email_outlined,
                    ),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      return !email.contains('@') || !email.contains('.')
                          ? 'Enter a valid email address'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: fieldDecoration(
                      'Initial password (minimum 8 characters)',
                      Icons.lock_outline_rounded,
                    ),
                    validator: (value) => (value ?? '').length < 8
                        ? 'Password must be at least 8 characters'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: fieldDecoration(
                      'Confirm initial password',
                      Icons.lock_reset_rounded,
                    ),
                    validator: (value) => value != passwordCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'They can sign in with email or mobile + password, or use an OTP.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Work details',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: designationCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Designation',
                      Icons.work_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: departmentCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Department',
                      Icons.business_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: branchId,
                    decoration: fieldDecoration('Branch', Icons.store_outlined),
                    hint: Text(
                      branches.isEmpty
                          ? 'No branches configured'
                          : 'Select a branch',
                    ),
                    items: branches
                        .map(
                          (branch) => DropdownMenuItem(
                            value: branch.id,
                            child: Text(branch.name),
                          ),
                        )
                        .toList(),
                    onChanged: branches.isEmpty
                        ? null
                        : (value) => branchId = value,
                    validator: (_) => branches.isNotEmpty && branchId == null
                        ? 'Select the staff member branch'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: shiftCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: fieldDecoration(
                      'Shift',
                      Icons.schedule_outlined,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              setSheetState(() => isSubmitting = true);
                              final error = await notifier.addMember({
                                'name': nameCtrl.text.trim(),
                                'empId': empIdCtrl.text.trim().toUpperCase(),
                                'role': role,
                                'phone': phoneCtrl.text.trim(),
                                'email': emailCtrl.text.trim().toLowerCase(),
                                'password': passwordCtrl.text,
                                if (branchId != null)
                                  'branchId': int.parse(branchId!),
                                'branch':
                                    branches
                                        .where(
                                          (branch) => branch.id == branchId,
                                        )
                                        .map((branch) => branch.name)
                                        .firstOrNull ??
                                    '',
                                'shift': shiftCtrl.text.trim(),
                                'designation': designationCtrl.text.trim(),
                                'department': departmentCtrl.text.trim(),
                              });
                              if (!ctx.mounted) return;
                              setSheetState(() => isSubmitting = false);
                              if (error != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(error)));
                                return;
                              }
                              Navigator.pop(ctx);
                              if (context.mounted) {
                                _showLoginCreatedDialog(
                                  context,
                                  name: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim().toLowerCase(),
                                  phone: phoneCtrl.text.trim(),
                                  password: passwordCtrl.text,
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Create Staff Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginCreatedDialog(
    BuildContext context, {
    required String name,
    required String email,
    required String phone,
    required String password,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.verified_user_rounded, size: 38),
        title: const Text('Staff login created'),
        content: Text(
          '$name can now sign in to the Staff app with:\n\n'
          '• $email + the password you created\n'
          '• $phone + the password you created\n'
          '• Email or mobile OTP\n\n'
          'Initial password: $password\n\n'
          'Share this securely and ask them to change it after signing in.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SummaryPill({
    required this.label,
    required this.count,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffMember member;
  final TeamNotifier notifier;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _StaffCard({
    required this.member,
    required this.notifier,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = switch (member.role.toLowerCase()) {
      'supervisor' => const Color(0xFF8B5CF6),
      'technician' => const Color(0xFF06B6D4),
      _ => colorScheme.primary,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: member.isActive
              ? colorScheme.outlineVariant.withValues(alpha: 0.6)
              : colorScheme.error.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: member.isActive
                    ? roleColor.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerHighest,
                child: Text(
                  member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                  style: textTheme.titleSmall?.copyWith(
                    color: member.isActive ? roleColor : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusPill(
                          label: member.role.toUpperCase(),
                          bg: roleColor.withValues(alpha: 0.12),
                          fg: roleColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          member.empId,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: AppFontFamilies.mono,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: member.isActive ? 'ACTIVE' : 'DISABLED',
                showDot: true,
                bg: member.isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : const Color(0xFFEF4444).withValues(alpha: 0.12),
                fg: member.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Switch.adaptive(
                value: member.isActive,
                activeTrackColor: const Color(0xFF10B981),
                onChanged: (_) => notifier.toggleActive(member),
              ),
            ],
          ),
          if (member.phone.isNotEmpty || member.branch.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                if (member.branch.isNotEmpty) ...[
                  Icon(Icons.store_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    member.branch,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
                const Spacer(),
                if (member.phone.isNotEmpty) ...[
                  Icon(Icons.phone_outlined, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    member.phone,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
