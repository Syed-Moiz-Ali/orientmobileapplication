import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';

class TeamView extends ConsumerWidget {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(teamProvider);
    final notifier = ref.read(teamProvider.notifier);

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
        elevation: 4,
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
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
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
          : state.staff.isEmpty
          ? Center(
              child: Text(
                'No staff members found. Add your first team member.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: state.staff.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = state.staff[i];
                return AppCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppDimensions.r20,
                  color: colorScheme.surface,
                  borderColor: m.isActive
                      ? colorScheme.outlineVariant
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: m.isActive
                            ? colorScheme.primary.withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerHighest,
                        child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                          style: textTheme.titleSmall?.copyWith(
                            color: m.isActive
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
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
                              m.name,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusPill(
                                  label: m.role.toUpperCase(),
                                  bg: colorScheme.surfaceContainerHighest,
                                  fg: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  m.empId,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: AppFontFamilies.mono,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: m.isActive ? 'ACTIVE' : 'DISABLED',
                        showDot: true,
                        bg: m.isActive
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFEF4444).withValues(alpha: 0.12),
                        fg: m.isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          m.isActive
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          size: 28,
                          color: m.isActive
                              ? const Color(0xFF10B981)
                              : colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => notifier.toggleActive(m),
                      ),
                    ],
                  ),
                );
              },
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
