import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/features/technician/presentation/widgets/parts_request_sheet.dart';
import 'package:staff_app/features/technician/presentation/widgets/escalation_sheet.dart';

class JobDetailSheet extends ConsumerStatefulWidget {
  final TechnicianJobEntity job;

  const JobDetailSheet({super.key, required this.job});

  @override
  ConsumerState<JobDetailSheet> createState() => _JobDetailSheetState();
}

class _JobDetailSheetState extends ConsumerState<JobDetailSheet> {
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.job.notes);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(technicianDashboardProvider);
        final notifier = ref.read(technicianDashboardProvider.notifier);

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.97,
          builder: (_, ctrl) => Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r28),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppDimensions.s10,
                    bottom: AppDimensions.s4,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppDimensions.r2),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.navy, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.r28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              job.jobCardNo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.displaySmall(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.s8,
                                vertical: AppDimensions.s4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.r20,
                                ),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: AppDimensions.s4),
                                  Flexible(
                                    child: Text(
                                      job.status.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${job.vehicleBrand} ${job.vehicleModel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.s8,
                                vertical: AppDimensions.s4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.r7,
                                ),
                              ),
                              child: Text(
                                job.plateNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Job progress',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              '${job.completedTasks}/${job.tasks.length} tasks â€¢ ${(job.progressPercent * 100).toInt()}%',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodySmall(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.r6),
                        child: LinearProgressIndicator(
                          value: job.progressPercent,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                          minHeight: 7,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: ctrl,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r2,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Text(
                            'Work Tasks',
                            style: AppTextStyles.title(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s4),
                      Text(
                        'Track and update task progress',
                        style: AppTextStyles.bodySmall(color: AppColors.text3),
                      ),
                      SizedBox(height: AppDimensions.s12),
                      ...job.tasks.asMap().entries.map((e) {
                        final task = e.value;
                        return _MobileTaskCard(
                          index: e.key + 1,
                          task: task,
                          onStart: () => notifier.startTask(job, task),
                          onComplete: () => notifier.completeTask(job, task),
                          onStatusChanged: (s) =>
                              notifier.updateTaskStatus(job, task, s),
                        );
                      }),
                      SizedBox(height: AppDimensions.s8),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r2,
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: AppColors.text3,
                          ),
                          SizedBox(width: AppDimensions.s6),
                          Text(
                            'Technician Notes',
                            style: AppTextStyles.subtitle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s8),
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 4,
                        onChanged: (v) => notifier.updateNotes(job, v),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Add any notes or observations about this job...',
                          hintStyle: AppTextStyles.bodySmall(
                            color: AppColors.text3,
                          ),
                          filled: true,
                          fillColor: AppColors.bg,
                          contentPadding: EdgeInsets.all(AppDimensions.s14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r12,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.s24),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: const Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => PartsRequestSheet(
                                      jobCardRef: job.jobCardNo,
                                      technicianEmpId: notifier.profile.empId,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  side: const BorderSide(
                                    color: AppColors.warning,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.r12,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.build_rounded, size: 16),
                                label: const Text(
                                  'Request Part',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => EscalationSheet(
                                      jobCardRef: job.jobCardNo,
                                      technicianEmpId: notifier.profile.empId,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(
                                    color: AppColors.danger,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.r12,
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.warning_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Flag Issue',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: state.isSaving
                                  ? null
                                  : () => notifier.saveChanges(
                                      // FE-FIX (audit P1): the captured
                                      // widget.job was saved — typed notes
                                      // reverted on Save. Persist the LIVE
                                      // entity from state instead.
                                      state.selectedJob ?? job,
                                    ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.accent,
                                side: BorderSide(
                                  color: AppColors.accent,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.s14,
                                  vertical: AppDimensions.s14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.r12,
                                  ),
                                ),
                              ),
                              icon: state.isSaving
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.accent,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded, size: 16),
                              label: Text(
                                'Save',
                                style: AppTextStyles.bodySmall(),
                              ),
                            ),
                            GestureDetector(
                              onTap: state.isSaving
                                  ? null
                                  : () async {
                                      // FE-FIX (audit P1): completing a job
                                      // closes it for invoicing — never without
                                      // confirmation, and always with the LIVE
                                      // entity.
                                      final live = state.selectedJob ?? job;
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          backgroundColor: AppColors.surface,
                                          title: const Text(
                                            'Complete Job?',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          content: Text(
                                            'Complete ${live.jobCardNo}? All remaining tasks will be marked done and the job moves to supervisor review.',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.text2,
                                              height: 1.5,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.success,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Complete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true) return;
                                      await notifier.completeJob(live);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.s14,
                                  vertical: AppDimensions.s14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.navy, AppColors.accent],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.r12,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withValues(
                                        alpha: 0.30,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: AppDimensions.s6),
                                    Text(
                                      'Complete Job',
                                      style: AppTextStyles.bodySmall(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MobileTaskCard extends StatelessWidget {
  final int index;
  final WorkTaskEntity task;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final void Function(TaskStatus) onStatusChanged;

  const _MobileTaskCard({
    required this.index,
    required this.task,
    required this.onStart,
    required this.onComplete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isComplete = task.status == TaskStatus.completed;
    final accent = isComplete
        ? AppColors.success
        : task.status == TaskStatus.inProgress
        ? AppColors.accent
        : colors.outline;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TimePill(
                icon: Icons.play_circle_outline_rounded,
                label: task.startTime ?? 'Not started',
              ),
              if (task.endTime != null)
                _TimePill(
                  icon: Icons.stop_circle_outlined,
                  label: task.endTime!,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TaskStatusDropdown(
                  status: task.status,
                  onChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 92,
                child: _TaskActionButton(
                  task: task,
                  onStart: onStart,
                  onComplete: onComplete,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TimePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TaskStatusDropdown extends StatelessWidget {
  final TaskStatus status;
  final void Function(TaskStatus) onChanged;

  const _TaskStatusDropdown({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color border, bg;
    switch (status) {
      case TaskStatus.completed:
        border = AppColors.success;
        bg = AppColors.successBg;
        break;
      case TaskStatus.inProgress:
        border = AppColors.accent;
        bg = AppColors.accent.withValues(alpha: 0.12);
        break;
      default:
        border = AppColors.border;
        bg = AppColors.bg;
    }
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.s6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskStatus>(
          value: status,
          isDense: true,
          dropdownColor: AppColors.surface,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 12,
            color: AppColors.text3,
          ),
          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: TaskStatus.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label, style: AppTextStyles.bodySmall()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  final WorkTaskEntity task;
  final VoidCallback onStart;
  final VoidCallback onComplete;

  const _TaskActionButton({
    required this.task,
    required this.onStart,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (task.status == TaskStatus.completed) {
      return const SizedBox.shrink();
    }
    final inProg = task.status == TaskStatus.inProgress;
    return GestureDetector(
      onTap: inProg ? onComplete : onStart,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.s8,
          vertical: AppDimensions.s4,
        ),
        decoration: BoxDecoration(
          color: inProg
              ? AppColors.successBg
              : AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.r8),
          border: Border.all(
            color: inProg ? AppColors.success : AppColors.accent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              inProg
                  ? Icons.check_circle_outline_rounded
                  : Icons.play_arrow_rounded,
              color: inProg ? AppColors.success : AppColors.accent,
              size: 12,
            ),
            SizedBox(width: AppDimensions.s4),
            Expanded(
              child: Text(
                inProg ? 'Done' : 'Start',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(
                  color: inProg ? AppColors.success : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
