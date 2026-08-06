import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/team_providers.dart';

/// P3 (audit): staff/role management screen for the owner.
class TeamView extends ConsumerWidget {
  const TeamView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamProvider);
    final notifier = ref.read(teamProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Team & Roles',
          style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gray700),
            onPressed: notifier.load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showAddStaffDialog(context, notifier),
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.error.isNotEmpty && state.staff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: const TextStyle(color: AppColors.gray500)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : state.staff.isEmpty
                  ? const Center(
                      child: Text('No staff yet — add your first team member',
                          style: TextStyle(color: AppColors.gray400)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: state.staff.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final m = state.staff[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: m.isActive ? AppColors.gray200 : const Color(0xFFFCA5A5),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: m.isActive
                                    ? AppColors.primaryBg
                                    : const Color(0xFFFEE2E2),
                                child: Text(
                                  m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: m.isActive ? AppColors.primary : AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: AppColors.gray900)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${m.role.toUpperCase()} \u00b7 ${m.empId}'
                                      '${m.branch.isNotEmpty ? ' \u00b7 ${m.branch}' : ''}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                m.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: m.isActive ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  m.isActive
                                      ? Icons.person_off_outlined
                                      : Icons.person_outlined,
                                  size: 20,
                                  color: m.isActive ? AppColors.danger : AppColors.success,
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

  void _showAddStaffDialog(BuildContext context, TeamNotifier notifier) {
    final nameCtrl = TextEditingController();
    final empIdCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'advisor');
    const roles = ['advisor', 'supervisor', 'technician', 'sales'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Staff Member',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
              TextField(controller: empIdCtrl, decoration: const InputDecoration(labelText: 'Employee ID (e.g. ADV002)')),
              TextField(controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone (for OTP login, e.g. 0501234567)'),
                  keyboardType: TextInputType.phone),
              DropdownButtonFormField<String>(
                initialValue: roleCtrl.text,
                decoration: const InputDecoration(labelText: 'Role'),
                items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => roleCtrl.text = v ?? 'advisor',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
