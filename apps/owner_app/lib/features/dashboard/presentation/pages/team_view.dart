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
        onPressed: () => _showAddStaffSheet(context, notifier, colorScheme, textTheme),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : state.error.isNotEmpty && state.staff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : state.staff.isEmpty
                  ? Center(
                      child: Text(
                        'No staff members found. Add your first team member.',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
                          borderColor: m.isActive ? colorScheme.outlineVariant : const Color(0xFFEF4444).withValues(alpha: 0.3),
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
                                    color: m.isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
                                fg: m.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  m.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                                  size: 28,
                                  color: m.isActive ? const Color(0xFF10B981) : colorScheme.onSurfaceVariant,
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

  void _showAddStaffSheet(BuildContext context, TeamNotifier notifier, ColorScheme colorScheme, TextTheme textTheme) {
    final nameCtrl = TextEditingController();
    final empIdCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'advisor');
    const roles = ['advisor', 'supervisor', 'technician', 'sales'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Team Member',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: empIdCtrl,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Staff ID / Employee Code (e.g. ADV002)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Mobile Phone (for OTP auth)',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: roleCtrl.text,
                decoration: InputDecoration(
                  labelText: 'Designated Role',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (v) => roleCtrl.text = v ?? 'advisor',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    final err = await notifier.addMember({
                      'name': nameCtrl.text.trim(),
                      'empId': empIdCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'role': roleCtrl.text,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  child: const Text('Add Staff Member', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
