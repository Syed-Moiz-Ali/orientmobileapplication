import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/technician/domain/entities/technician_entities.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the task find sheet: a full-screen search over the detail's loaded
/// tasks (no new routes, no logic changes). Result taps reuse the row-toggle
/// contract — tapping a result reveals the detail and starts/resumes/
/// completes through the same notifier methods the task rows call.
Future<void> showTechnicianTaskSearch(
  BuildContext context, {
  required List<WorkTaskEntity> tasks,
  required ValueChanged<WorkTaskEntity> onSelect,
}) {
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.techTaskSearch,
    builder: (_) => _TaskSearchSheet(tasks: tasks, onSelect: onSelect),
  );
}

/// Presentation-only task search: filters the loaded [WorkTaskEntity] list by
/// substring over the task title (case-insensitive). Mirrors the checklist
/// content so the sheet can never promise a task the detail does not show.
class _TaskSearchSheet extends StatefulWidget {
  final List<WorkTaskEntity> tasks;
  final ValueChanged<WorkTaskEntity> onSelect;

  const _TaskSearchSheet({required this.tasks, required this.onSelect});

  @override
  State<_TaskSearchSheet> createState() => _TaskSearchSheetState();
}

class _TaskSearchSheetState extends State<_TaskSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<WorkTaskEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.tasks;
    return widget.tasks
        .where((t) => t.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final coreT = SharedCoreL10n.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final results = _results();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: AppSearchField(
            controller: _ctrl,
            hintText: t.techTaskSearchHint,
            onChanged: (v) => setState(() => _query = v),
            onClear: () => setState(() {
              _ctrl.clear();
              _query = '';
            }),
          ),
        ),
        Flexible(
          child: results.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.techTaskNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        t.techTaskNoMatchHint,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      AppPillButton.secondary(
                        label: coreT.filterBarClear,
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final task = results[index];
                    return _TaskRow(
                      task: task,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop();
                        widget.onSelect(task);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// One task result row: status glyph + title + status label. Tapping reuses
/// the row-toggle contract (reveal + start/resume/complete via the detail's
/// existing callbacks).
class _TaskRow extends StatelessWidget {
  final WorkTaskEntity task;
  final VoidCallback onTap;

  const _TaskRow({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final done = task.status == TaskStatus.completed;
    final running = task.status == TaskStatus.inProgress;
    final held = task.status == TaskStatus.onHold;
    final icon = done
        ? Icons.check_circle_rounded
        : running
        ? Icons.timelapse_rounded
        : held
        ? Icons.pause_circle_rounded
        : Icons.radio_button_unchecked_rounded;
    final tone = done
        ? context.semanticColors.success.base
        : running
        ? colors.primary
        : held
        ? context.semanticColors.warning.base
        : colors.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 20, color: tone),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: done ? colors.onSurfaceVariant : colors.onSurface,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    task.status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tone,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
