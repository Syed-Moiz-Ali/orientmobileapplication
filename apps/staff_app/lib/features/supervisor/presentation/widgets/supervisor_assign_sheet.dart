import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Opens the dispatch sheet through the shared responsive modal (bottom sheet
/// on compact, centred dialog ≥600).
Future<void> showSupervisorAssignSheet(BuildContext context) {
  return showAppModalSheet<void>(
    context: context,
    title: StaffLocalizations.of(context)!.svAssignTitle,
    builder: (_) => const SupervisorAssignSheet(),
  );
}

/// Technician dispatch: target job + selectable technician cards, one primary
/// dispatch. Reuses the frozen `saveAndAssign` contract (row update + enqueue +
/// sync); the payload shape is unchanged.
class SupervisorAssignSheet extends ConsumerStatefulWidget {
  const SupervisorAssignSheet({super.key});

  @override
  ConsumerState<SupervisorAssignSheet> createState() =>
      _SupervisorAssignSheetState();
}

class _SupervisorAssignSheetState extends ConsumerState<SupervisorAssignSheet> {
  final _briefCtrl = TextEditingController();
  String? _selectedTech;
  String? _department;

  @override
  void dispose() {
    _briefCtrl.dispose();
    super.dispose();
  }

  Future<void> _dispatch(String tech) async {
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final rows = ref.read(supervisorDashboardProvider).assignmentRows;
    final row = rows.isEmpty
        ? null
        : rows.first;
    if (row == null) {
      showSupervisorToast(context, t.svAssignFailed,
          icon: Icons.error_outline_rounded,
          color: context.semanticColors.danger.base);
      return;
    }
    HapticFeedback.mediumImpact();
    notifier.updateAssignmentRow(
      row.id,
      row.copyWith(
        technicianName: tech,
        description: _briefCtrl.text.trim().isNotEmpty
            ? _briefCtrl.text.trim()
            : row.description,
        department: _department ?? row.department,
      ),
    );
    await notifier.saveAndAssign();
    if (!mounted) return;
    final ok = ref.read(supervisorDashboardProvider).assignWorkSuccess.isNotEmpty;
    Navigator.of(context).maybePop();
    showSupervisorToast(
      context,
      ok ? t.svAssignDispatched(tech) : t.svAssignFailed,
      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
      color: ok ? context.semanticColors.success.base : context.semanticColors.danger.base,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final technicians = notifier.technicians;
    final departments = notifier.departments;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.svAssignSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        Text(
          t.svAssignTarget,
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.s6),
        AppSearchField(
          hintText: t.svAssignTargetHint,
          onChanged: notifier.updateJobCardSearch,
        ),
        if (state.jobCardSearch.trim().isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s6),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              state.jobCardSearch.trim(),
              style: supervisorMono(
                context,
                color: context.colors.primary,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
        if (departments.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.s16),
          AppDropdownButton(
            label: t.svAssignSkills,
            value: _department ?? departments.first,
            items: departments,
            onChanged: (v) => setState(() => _department = v),
          ),
        ],
        const SizedBox(height: AppDimensions.s16),
        Text(
          t.svAssignTechTitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        Flexible(
          child: technicians.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
                  child: EmptyState(
                    icon: Icons.badge_outlined,
                    title: t.svAssignEmpty,
                    message: t.svAssignEmptyMessage,
                  ),
                )
              : SingleChildScrollView(
                  child: Wrap(
                    spacing: AppDimensions.s10,
                    runSpacing: AppDimensions.s10,
                    children: [
                      for (final tech in technicians)
                        _TechCard(
                          name: tech,
                          role: t.svStaffRole,
                          selected: _selectedTech == tech,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTech = tech);
                          },
                        ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: AppDimensions.s16),
        TextField(
          controller: _briefCtrl,
          maxLines: 2,
          minLines: 1,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: t.svAssignBrief,
            hintText: t.svAssignBriefHint,
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        PrimaryButton(
          label: t.svAssignDispatch,
          icon: Icons.engineering_rounded,
          isLoading: state.isAssignWorkLoading,
          onPressed: _selectedTech == null || state.isAssignWorkLoading
              ? null
              : () => _dispatch(_selectedTech!),
        ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  final String name;
  final String role;
  final bool selected;
  final VoidCallback onTap;

  const _TechCard({
    required this.name,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name, $role, ${t.svStaffOnShift}',
      child: Material(
        color: selected
            ? context.semanticColors.selectedSurface
            : context.semanticColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(
            color: selected
                ? context.colors.primary
                : context.semanticColors.borderDefault,
            width: selected ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 168,
            padding: const EdgeInsets.all(AppDimensions.s12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.primary.withValues(alpha: 0.12),
                  child: Text(
                    initialsOf(name),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.onSurface,
                        ),
                      ),
                      Text(
                        role,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: AppDimensions.iconMd,
                    color: context.colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
