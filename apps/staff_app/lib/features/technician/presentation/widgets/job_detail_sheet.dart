import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(technicianDashboardProvider);
    final notifier = ref.read(technicianDashboardProvider.notifier);

    // Always resolve the live reactive job from state / notifier
    final liveJob = notifier.allJobs.firstWhere(
      (j) => j.jobCardNo == widget.job.jobCardNo,
      orElse: () => state.selectedJob?.jobCardNo == widget.job.jobCardNo ? state.selectedJob! : widget.job,
    );
    final isActionable =
        liveJob.status != TechJobStatus.qcReview &&
        liveJob.status != TechJobStatus.completed;

    // Keep notes controller in sync if remote/live changes
    if (_notesCtrl.text != liveJob.notes && !_notesCtrl.selection.isValid) {
      _notesCtrl.text = liveJob.notes;
    }

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Job details'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'More job actions',
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Use the actions below to update this repair.'),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Drag Handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6),
              child: Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: colors.outlineVariant, borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            // Header Card
            _SheetHeader(
              job: liveJob,
              isActionable: isActionable,
              onClose: () => Navigator.pop(context),
              onStatusChanged: (newStatus) {
                if (!isActionable) return;
                HapticFeedback.selectionClick();
                notifier.updateJobStatus(liveJob, newStatus);
              },
            ),

            // Main Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title: Work Tasks
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 6,
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Work Tasks',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${liveJob.completedTasks}/${liveJob.tasks.length} Done',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and update live task execution',
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),

                    if (isActionable &&
                        liveJob.tasks.any((task) => task.status == TaskStatus.pending))
                      TextButton.icon(
                        onPressed: () {
                          final nextTask = liveJob.tasks.firstWhere((task) => task.status == TaskStatus.pending);
                          HapticFeedback.mediumImpact();
                          notifier.startTask(liveJob, nextTask);
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: const Text('Start'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    // Task Cards List
                    if (liveJob.tasks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Center(
                          child: Text(
                            'No specific work tasks defined for this job card.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ...liveJob.tasks.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final task = entry.value;
                        return _InteractiveTaskCard(
                          index: index,
                          task: task,
                          isActionable: isActionable,
                          onStart: () {
                            if (!isActionable) return;
                            HapticFeedback.mediumImpact();
                            notifier.startTask(liveJob, task);
                          },
                          onComplete: () {
                            if (!isActionable) return;
                            HapticFeedback.mediumImpact();
                            notifier.completeTask(liveJob, task);
                          },
                          onStatusChanged: (status) {
                            if (!isActionable) return;
                            HapticFeedback.selectionClick();
                            notifier.updateTaskStatus(liveJob, task, status);
                          },
                        );
                      }),

                    const SizedBox(height: 20),

                    // Section Title: Technician Notes
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(color: colors.secondary, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_note_rounded, size: 20, color: colors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'Technician Observations & Notes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 4,
                      readOnly: !isActionable,
                      onChanged: isActionable
                          ? (val) => notifier.updateNotes(liveJob, val)
                          : null,
                      style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Add any diagnosis notes, part numbers or observations...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                        filled: true,
                        fillColor: colors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Footer
            _SheetFooter(
              job: liveJob,
              isActionable: isActionable,
              isSaving: state.isSaving,
              empId: notifier.profile.empId,
              onSave: () async {
                HapticFeedback.selectionClick();
                await notifier.saveChanges(liveJob);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job progress saved successfully'), behavior: SnackBarBehavior.floating),
                );
              },
              onCompleteJob: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Complete Job Card?'),
                    content: Text(
                      'Are you sure you want to mark ${liveJob.jobCardNo} as complete?\n\n'
                      'All remaining tasks will be recorded as completed and sent for Supervisor QC verification.',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F9D73)),
                        child: const Text('Confirm Complete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  HapticFeedback.heavyImpact();
                  await notifier.completeJob(liveJob);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${liveJob.jobCardNo} completed and submitted for QC review'),
                      backgroundColor: const Color(0xFF0F9D73),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER COMPONENT WITH OVERALL JOB STATUS SELECTOR
// ─────────────────────────────────────────────────────────────────────────────
class _SheetHeader extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isActionable;
  final VoidCallback onClose;
  final ValueChanged<TechJobStatus> onStatusChanged;

  const _SheetHeader({
    required this.job,
    required this.isActionable,
    required this.onClose,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Job Card #, Status Badge Button & Close
          Row(
            children: [
              Expanded(
                child: Text(
                  job.jobCardNo,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Job status dropdown menu
              PopupMenuButton<TechJobStatus>(
                tooltip: 'Change job status',
                enabled: isActionable,
                onSelected: onStatusChanged,
                color: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => TechJobStatus.values.map((s) {
                  return PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: s.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          s.label,
                          style: TextStyle(fontWeight: s == job.status ? FontWeight.w800 : FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: job.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: job.status.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        job.status.label,
                        style: TextStyle(color: job.status.color, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      if (isActionable)
                        Icon(Icons.arrow_drop_down_rounded, color: job.status.color, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Close button
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Icon(Icons.close_rounded, color: colors.onSurface, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Vehicle name & Plate badge
          Row(
            children: [
              Expanded(
                child: Text(
                  '${job.vehicleBrand} ${job.vehicleModel}'.trim(),
                  style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (job.plateNumber.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Text(
                    job.plateNumber,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Progress Bar and Progress percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: job.progressPercent,
                    backgroundColor: colors.outlineVariant,
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(job.progressPercent * 100).toInt()}%',
                style: TextStyle(color: colors.primary, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE TASK CARD
// ─────────────────────────────────────────────────────────────────────────────
class _InteractiveTaskCard extends StatelessWidget {
  final int index;
  final WorkTaskEntity task;
  final bool isActionable;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final ValueChanged<TaskStatus> onStatusChanged;

  const _InteractiveTaskCard({
    required this.index,
    required this.task,
    required this.isActionable,
    required this.onStart,
    required this.onComplete,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDone = task.status == TaskStatus.completed;
    final isInProgress = task.status == TaskStatus.inProgress;

    final statusColor = isDone
        ? const Color(0xFF0F9D73)
        : isInProgress
        ? colors.primary
        : colors.outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isInProgress ? colors.primary.withValues(alpha: 0.5) : colors.outlineVariant,
          width: isInProgress ? 1.5 : 1,
        ),
        boxShadow: isInProgress
            ? [BoxShadow(color: colors.primary.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step number & Task Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 18, color: Color(0xFF0F9D73))
                    : Text(
                        '$index',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Timestamps row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TimeChip(
                icon: Icons.play_arrow_rounded,
                label: task.startTime != null ? 'Started: ${task.startTime}' : 'Not started',
                active: task.startTime != null,
              ),
              if (task.endTime != null)
                _TimeChip(icon: Icons.check_circle_outline_rounded, label: 'Ended: ${task.endTime}', active: true),
            ],
          ),

          const SizedBox(height: 12),

          if (isActionable)
          Column(
            children: [
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TaskStatus>(
                    value: task.status,
                    isDense: true,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(14),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    onChanged: (val) {
                      if (val != null) onStatusChanged(val);
                    },
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status.label,
                          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Fast Action Button
              if (isDone)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F9D73).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0F9D73).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: Color(0xFF0F9D73)),
                        SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: TextStyle(color: Color(0xFF0F9D73), fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else if (isInProgress)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Mark Done'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D73),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: const Text('Start'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      minimumSize: const Size(120, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          )
          else
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? Icons.verified_rounded : Icons.lock_outline_rounded,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      task.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _TimeChip({required this.icon, required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: active ? colors.primary : colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM ACTION FOOTER
// ─────────────────────────────────────────────────────────────────────────────
class _SheetFooter extends StatelessWidget {
  final TechnicianJobEntity job;
  final bool isActionable;
  final bool isSaving;
  final String empId;
  final VoidCallback onSave;
  final VoidCallback onCompleteJob;

  const _SheetFooter({
    required this.job,
    required this.isActionable,
    required this.isSaving,
    required this.empId,
    required this.onSave,
    required this.onCompleteJob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: isActionable
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Quick Action Sheets (Parts Request & Flag Issue)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => PartsRequestSheet(jobCardRef: job.jobCardNo, technicianEmpId: empId),
                      );
                    },
                    icon: const Icon(Icons.build_circle_outlined, size: 16),
                    label: const Text('Request Parts'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 42),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EscalationSheet(jobCardRef: job.jobCardNo, technicianEmpId: empId),
                      );
                    },
                    icon: const Icon(Icons.warning_amber_rounded, size: 16),
                    label: const Text('Flag Issue'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.error,
                      side: BorderSide(color: colors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(0, 42),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: Save and Complete
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : onSave,
                    icon: isSaving
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                          )
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Notes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : onCompleteJob,
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Complete Repair'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D73),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
            : Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: job.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      job.status == TechJobStatus.qcReview
                          ? Icons.fact_check_rounded
                          : Icons.verified_rounded,
                      color: job.status.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job.status == TechJobStatus.qcReview
                          ? 'Submitted for supervisor QC. Technician edits are locked.'
                          : 'This repair is completed. Technician edits are locked.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
      ),
    );
  }
}
