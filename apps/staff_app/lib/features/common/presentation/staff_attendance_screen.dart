import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

class StaffAttendanceScreen extends ConsumerWidget {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final state = ref.watch(staffAttendanceProvider);
    final notifier = ref.read(staffAttendanceProvider.notifier);
    final auth = ref.watch(authNotifierProvider);
    final profile = auth is AuthAuthenticated ? auth.profile : null;

    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientBanner(
                title: profile?.name.isNotEmpty == true
                    ? profile!.name
                    : 'Staff member',
                greeting:
                    '${profile?.designation.isNotEmpty == true ? profile!.designation : profile?.role ?? 'Staff'} · ${DateFormat('EEEE, d MMMM yyyy').format(DateTime.now())}',
                icon: Icons.badge_outlined,
                liveLabel: null,
              ),
              const SizedBox(height: AppDimensions.s16),
              if (state.isLoading)
                const Center(child: LoadingIndicator())
              else ...[
                if (state.error.isNotEmpty) ...[
                  ErrorView(message: state.error, onRetry: notifier.load),
                  const SizedBox(height: AppDimensions.s16),
                ],
                _StatusCard(state: state),
                const SizedBox(height: AppDimensions.s16),
                AppAdaptiveGrid(
                  minChildWidth: 145,
                  childAspectRatio: 2.1,
                  children: [
                    _TimeCard(
                      label: 'Punch in',
                      value: state.punchIn.isEmpty ? '--:--' : state.punchIn,
                      icon: Icons.login_rounded,
                    ),
                    _TimeCard(
                      label: 'Punch out',
                      value: state.punchOut.isEmpty ? '--:--' : state.punchOut,
                      icon: Icons.logout_rounded,
                    ),
                    _TimeCard(
                      label: 'Hours worked',
                      value: state.workHours.isEmpty ? '--' : state.workHours,
                      icon: Icons.schedule_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s24),
                if (state.status == StaffAttendanceStatus.notPunchedIn)
                  FilledButton.icon(
                    onPressed: state.isSaving
                        ? null
                        : () => _confirmPunchIn(context, ref, notifier),
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: Text(state.isSaving ? 'Punching in…' : 'Punch In'),
                  )
                else if (state.status == StaffAttendanceStatus.working ||
                    state.status == StaffAttendanceStatus.onBreak)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: colors.onError,
                    ),
                    onPressed: state.isSaving
                        ? null
                        : () => _confirmPunchOut(context, ref, notifier),
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(state.isSaving ? 'Punching out…' : 'Punch Out'),
                  )
                else
                  AppCard(
                    color: colors.primaryContainer,
                    child: Text(
                      'Today’s shift is complete. Your recorded hours are shown above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onPrimaryContainer),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPunchIn(
    BuildContext context,
    WidgetRef ref,
    StaffAttendanceNotifier notifier,
  ) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Punch in now?',
      message: 'Your arrival time will be recorded by the workshop server.',
      confirmLabel: 'Punch In',
    );
    if (!confirmed) return;
    final ok = await notifier.punchIn();
    if (ok) ref.invalidate(technicianDashboardProvider);
    if (context.mounted) _showResult(context, ok, 'You are punched in.');
  }

  Future<void> _confirmPunchOut(
    BuildContext context,
    WidgetRef ref,
    StaffAttendanceNotifier notifier,
  ) async {
    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Punch out now?',
      message: 'This completes today’s shift and records your work hours.',
      confirmLabel: 'Punch Out',
      destructive: true,
    );
    if (!confirmed) return;
    final ok = await notifier.punchOut();
    if (ok) ref.invalidate(technicianDashboardProvider);
    if (context.mounted) _showResult(context, ok, 'You are punched out.');
  }

  void _showResult(BuildContext context, bool ok, String success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? success : 'Attendance was not updated.')),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final StaffAttendanceState state;
  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (label, color) = switch (state.status) {
      StaffAttendanceStatus.notPunchedIn => ('Not punched in', colors.outline),
      StaffAttendanceStatus.working => ('Working', AppColors.success),
      StaffAttendanceStatus.onBreak => ('On break', AppColors.warning),
      StaffAttendanceStatus.punchedOut => ('Shift complete', colors.primary),
    };
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.access_time_filled_rounded, color: color, size: 30),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current status',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          StatusPill(
            label: label.toUpperCase(),
            bg: color.withValues(alpha: .12),
            fg: color,
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _TimeCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
