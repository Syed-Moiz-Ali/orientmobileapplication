// List-scoped tasks search (CRM tasks list).
//
// Presentation only: filters the already-loaded tasks by title or assignee
// substring (case-insensitive). No new routes, no server queries, no
// invented entries. Result taps close the sheet and reveal the card;
// card actions stay on the card itself.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';

Future<void> showCrmTasksSearchSheet(
  BuildContext context, {
  required List<CrmTaskEntity> tasks,
  required ValueChanged<CrmTaskEntity> onSelect,
}) {
  final t = context.cx;
  return showAppModalSheet<void>(
    context: context,
    title: t.tasksSearchTitle,
    builder: (_) => _TasksSearchSheet(tasks: tasks, onSelect: onSelect),
  );
}

class _TasksSearchSheet extends StatefulWidget {
  final List<CrmTaskEntity> tasks;
  final ValueChanged<CrmTaskEntity> onSelect;

  const _TasksSearchSheet({required this.tasks, required this.onSelect});

  @override
  State<_TasksSearchSheet> createState() => _TasksSearchSheetState();
}

class _TasksSearchSheetState extends State<_TasksSearchSheet> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<CrmTaskEntity> _results() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.tasks;
    return widget.tasks.where((task) {
      return task.title.toLowerCase().contains(q) ||
          task.assignedTo.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
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
            hintText: t.tasksSearchHint,
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
                        t.tasksSearchNoMatch,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () => setState(() {
                          _ctrl.clear();
                          _query = '';
                        }),
                        child: Text(t.leadsFilterClear),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: results.length,
                  itemBuilder: (rowContext, index) {
                    final task = results[index];
                    return InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(rowContext).pop();
                        widget.onSelect(task);
                      },
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppDimensions.s20,
                          AppDimensions.s8,
                          AppDimensions.s20,
                          AppDimensions.s8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (task.assignedTo.isNotEmpty) ...[
                              const SizedBox(width: AppDimensions.s10),
                              Text(
                                task.assignedTo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
