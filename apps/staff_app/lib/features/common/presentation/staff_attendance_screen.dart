import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/common/presentation/staff_shimmer_skeletons.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';

class StaffAttendanceScreen extends ConsumerWidget {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(staffAttendanceProvider);
    final notifier = ref.read(staffAttendanceProvider.notifier);
    final auth = ref.watch(authNotifierProvider);
    final profile = auth is AuthAuthenticated ? auth.profile : null;

    final canPop = Navigator.of(context).canPop();
    final staffName = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : (profile?.role.isNotEmpty == true ? profile!.role : 'Staff');
    final formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AppPageFrame(
          title: 'Attendance',
          subtitle: '$staffName · $formattedDate',
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
          child: RefreshIndicator(
            onRefresh: notifier.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: state.isLoading
                  ? const StaffAttendanceSkeleton()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 640;

                        final statusSection = _StatusCard(state: state);
                        final timeSummarySection = _TimeSummaryWorkspace(
                          state: state,
                        );
                        final actionSection = _ActionSection(
                          state: state,
                          onPunchIn: () =>
                              _confirmPunchIn(context, ref, notifier),
                          onPunchOut: () =>
                              _confirmPunchOut(context, ref, notifier),
                        );

                        if (isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.error.isNotEmpty) ...[
                                ErrorView(
                                  message: state.error,
                                  onRetry: notifier.load,
                                ),
                                const SizedBox(height: AppDimensions.s16),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        statusSection,
                                        const SizedBox(
                                          height: AppDimensions.s20,
                                        ),
                                        actionSection,
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.s24),
                                  Expanded(flex: 6, child: timeSummarySection),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.s32),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state.error.isNotEmpty) ...[
                              ErrorView(
                                message: state.error,
                                onRetry: notifier.load,
                              ),
                              const SizedBox(height: AppDimensions.s16),
                            ],
                            statusSection,
                            const SizedBox(height: AppDimensions.s16),
                            timeSummarySection,
                            const SizedBox(height: AppDimensions.s24),
                            actionSection,
                            const SizedBox(height: AppDimensions.s32),
                          ],
                        );
                      },
                    ),
            ),
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
      destructive: false,
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

/// Primary surface communicating the current attendance state with high visual hierarchy.
class _StatusCard extends StatelessWidget {
  final StaffAttendanceState state;

  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (label, icon, color, description) = switch (state.status) {
      StaffAttendanceStatus.notPunchedIn => (
        'Not punched in',
        Icons.schedule_outlined,
        colors.outline,
        'Your shift has not started yet. Punch in to begin recording today’s hours.',
      ),
      StaffAttendanceStatus.working => (
        'Working',
        Icons.check_circle_rounded,
        AppColors.success,
        'Active shift in progress. Your hours are being recorded.',
      ),
      StaffAttendanceStatus.onBreak => (
        'On break',
        Icons.pause_circle_rounded,
        AppColors.warning,
        'Shift is temporarily paused on break.',
      ),
      StaffAttendanceStatus.punchedOut => (
        'Shift complete',
        Icons.task_alt_rounded,
        colors.primary,
        'Today’s shift is finished. Recorded hours have been submitted.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppDimensions.s20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        boxShadow: AppDimensions.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT STATUS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: label.toUpperCase(),
                bg: color.withValues(alpha: 0.12),
                fg: color,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s14),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppDimensions.s12),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Grouped time summary containing Punch in, Punch out, Hours worked, and Break time if available.
class _TimeSummaryWorkspace extends StatelessWidget {
  final StaffAttendanceState state;

  const _TimeSummaryWorkspace({required this.state});

  @override
  Widget build(BuildContext context) {
    final showBreak =
        state.breakTime.trim().isNotEmpty && state.breakTime != '0';

    final tiles = <_TimeMetric>[
      _TimeMetric(
        label: 'Punch in',
        value: state.punchIn.trim().isEmpty ? '--:--' : state.punchIn.trim(),
        icon: Icons.login_rounded,
      ),
      _TimeMetric(
        label: 'Punch out',
        value: state.punchOut.trim().isEmpty ? '--:--' : state.punchOut.trim(),
        icon: Icons.logout_rounded,
      ),
      _TimeMetric(
        label: 'Hours worked',
        value: state.workHours.trim().isEmpty ? '--' : state.workHours.trim(),
        icon: Icons.timelapse_rounded,
      ),
      if (showBreak)
        _TimeMetric(
          label: 'Break time',
          value: state.breakTime.trim(),
          icon: Icons.coffee_rounded,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Today’s Recorded Time'),
        const SizedBox(height: AppDimensions.s8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmall ? 1 : 2,
                crossAxisSpacing: AppDimensions.s10,
                mainAxisSpacing: AppDimensions.s10,
                mainAxisExtent: 78,
              ),
              itemBuilder: (context, index) => _TimeCard(metric: tiles[index]),
            );
          },
        ),
      ],
    );
  }
}

class _TimeMetric {
  final String label;
  final String value;
  final IconData icon;

  const _TimeMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _TimeCard extends StatelessWidget {
  final _TimeMetric metric;

  const _TimeCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: AppDimensions.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(
              metric.icon,
              size: AppDimensions.iconSm,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFontFamilies.mono,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action section handling Punch In, Punch Out, and Shift Complete states safely.
class _ActionSection extends StatelessWidget {
  final StaffAttendanceState state;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  const _ActionSection({
    required this.state,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (state.status == StaffAttendanceStatus.notPunchedIn) {
      return FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
        ),
        onPressed: state.isSaving ? null : onPunchIn,
        icon: state.isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.fingerprint_rounded, size: 20),
        label: Text(
          state.isSaving ? 'Punching in…' : 'Punch In',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    if (state.status == StaffAttendanceStatus.working ||
        state.status == StaffAttendanceStatus.onBreak) {
      return FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          backgroundColor: colors.surfaceContainerHighest,
          foregroundColor: colors.onSurface,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            side: BorderSide(color: colors.outlineVariant),
          ),
        ),
        onPressed: state.isSaving ? null : onPunchOut,
        icon: state.isSaving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onSurface,
                ),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          state.isSaving ? 'Punching out…' : 'Punch Out',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    // Shift complete state: calm completion panel
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s14,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: colors.primary,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              'Today’s shift is complete. Your recorded hours are shown above.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
