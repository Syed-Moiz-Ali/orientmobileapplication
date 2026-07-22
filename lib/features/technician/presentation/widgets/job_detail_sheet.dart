import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/core/local/sync/sync_providers.dart';
import 'package:orientmobileapplication/features/technician/domain/entities/technician_entities.dart';
import 'package:orientmobileapplication/features/technician/providers/technician_providers.dart';

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
                          Text(
                            job.jobCardNo,
                            style: AppTextStyles.orbitronDisplaySmall(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Container(
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
                                Text(
                                  job.status.label,
                                  style: AppTextStyles.rajdhaniBodySmall(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
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
                          Text(
                            '${job.vehicleBrand} ${job.vehicleModel}',
                            style: AppTextStyles.rajdhaniBodySmall(
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(width: AppDimensions.s10),
                          Container(
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
                              style: AppTextStyles.rajdhaniBodySmall(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s14),
                      Row(
                        children: [
                          Text(
                            'Job Progress',
                            style: AppTextStyles.rajdhaniBodySmall(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${job.completedTasks}/${job.tasks.length} tasks (${(job.progressPercent * 100).toInt()}%)',
                            style: AppTextStyles.rajdhaniBodySmall(
                              color: Colors.white,
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
                            style: AppTextStyles.rajdhaniTitle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.s4),
                      Text(
                        'Track and update task progress',
                        style: AppTextStyles.rajdhaniBodySmall(
                          color: AppColors.text3,
                        ),
                      ),
                      SizedBox(height: AppDimensions.s12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.s10,
                          vertical: AppDimensions.s8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.r10),
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(width: 28, child: _ColHead('S.No')),
                            Expanded(flex: 4, child: _ColHead('Description')),
                            SizedBox(width: 46, child: _ColHead('Start')),
                            SizedBox(width: 38, child: _ColHead('End')),
                            SizedBox(width: 88, child: _ColHead('Status')),
                            SizedBox(width: 64, child: _ColHead('Action')),
                          ],
                        ),
                      ),
                      ...job.tasks.asMap().entries.map((e) {
                        final task = e.value;
                        return _TaskRow(
                          index: e.key + 1,
                          task: task,
                          isEven: e.key % 2 == 0,
                          onStart: () => notifier.startTask(job, task),
                          onComplete: () => notifier.completeTask(job, task),
                          onStatusChanged: (s) =>
                              notifier.updateTaskStatus(job, task, s),
                        );
                      }),
                      Container(
                        height: 1,
                        margin: EdgeInsets.only(bottom: AppDimensions.s20),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppColors.border),
                            right: BorderSide(color: AppColors.border),
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
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
                            style: AppTextStyles.rajdhaniLabel(
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
                          hintStyle: AppTextStyles.rajdhaniBodySmall(
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
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text2,
                            side: BorderSide(color: AppColors.border),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.s20,
                              vertical: AppDimensions.s14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.r12,
                              ),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: AppTextStyles.rajdhaniBodySmall(
                              color: AppColors.text2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: state.isSaving
                              ? null
                              : () => notifier.saveChanges(job),
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
                            style: AppTextStyles.rajdhaniBodySmall(),
                          ),
                        ),
                        SizedBox(width: AppDimensions.s8),
                        GestureDetector(
                          onTap: state.isSaving
                              ? null
                              : () async {
                                  await notifier.completeJob(job);
                                  ref.read(syncEngineProvider).syncAll();
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
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: AppDimensions.s6),
                                Text(
                                  'Complete Job',
                                  style: AppTextStyles.rajdhaniBodySmall(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class _ColHead extends StatelessWidget {
  final String text;
  const _ColHead(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTextStyles.rajdhaniBodySmall(color: AppColors.accent),
  );
}

class _TaskRow extends StatelessWidget {
  final int index;
  final WorkTaskEntity task;
  final bool isEven;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final void Function(TaskStatus) onStatusChanged;

  const _TaskRow({
    required this.index,
    required this.task,
    required this.isEven,
    required this.onStart,
    required this.onComplete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.s10,
        vertical: AppDimensions.s10,
      ),
      decoration: BoxDecoration(
        color: isEven ? AppColors.surface : AppColors.surfaceAlt,
        border: const Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: AppTextStyles.rajdhaniBodySmall(color: AppColors.text3),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              task.description,
              style: TextStyle(color: AppColors.text2, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 46,
            child: Text(
              task.startTime ?? '\u2013',
              style: TextStyle(color: AppColors.text3, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              task.endTime ?? '\u2013',
              style: TextStyle(color: AppColors.text3, fontSize: 11),
            ),
          ),
          SizedBox(
            width: 88,
            child: _TaskStatusDropdown(
              status: task.status,
              onChanged: onStatusChanged,
            ),
          ),
          SizedBox(
            width: 64,
            child: _TaskActionButton(
              task: task,
              onStart: onStart,
              onComplete: onComplete,
            ),
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
          style: AppTextStyles.rajdhaniBodySmall(color: AppColors.textPrimary),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          items: TaskStatus.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s.label,
                    style: AppTextStyles.rajdhaniBodySmall(),
                  ),
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
            Text(
              inProg ? 'Done' : 'Start',
              style: AppTextStyles.rajdhaniBodySmall(
                color: inProg ? AppColors.success : AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
