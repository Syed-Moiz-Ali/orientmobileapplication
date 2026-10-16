// Phase 09 — Visual Bay Dispatch (Archetype 4).
//
// Sibling of the home radar: greeting-style compact header (no app-bar
// bulk), technician cards in home tile grammar (avatar + name + skill
// chips + load bar + availability), one-tap assign with haptic + toast,
// and a single contextual dispatch dock.
//
// UI-ONLY CONTRACT: assignment payloads, routes, Hive and providers are
// frozen. Technician load/skills/availability decorations are display-only
// projections in `repair_estimate_math.dart` (never persisted or sent).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/data/datasources/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/widgets/repair_estimate_math.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

class TaskDraft {
  int taskId;
  String description;
  bool selected;
  double estimatedHours;
  TaskDraft({
    this.taskId = 0,
    required this.description,
    this.selected = true,
    this.estimatedHours = 0,
  });
}

class AdvisorAssignTasksView extends ConsumerStatefulWidget {
  final String jobCardRef;

  const AdvisorAssignTasksView({super.key, required this.jobCardRef});

  @override
  ConsumerState<AdvisorAssignTasksView> createState() =>
      _AdvisorAssignTasksViewState();
}

class _AdvisorAssignTasksViewState
    extends ConsumerState<AdvisorAssignTasksView> {
  final List<TaskDraft> _tasks = [];
  String? _selectedTechnicianId;
  bool _isLoading = false;
  bool _isLoadingItems = true;
  bool _itemsError = false;

  @override
  void initState() {
    super.initState();
    _loadGeneratedItems();
  }

  Future<void> _loadGeneratedItems() async {
    setState(() {
      _isLoadingItems = true;
      _itemsError = false;
    });
    try {
      final items = await ref
          .read(advisorRemoteDataSourceProvider)
          .getWorkItems(widget.jobCardRef);
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(
            items
                .where((item) => item.description.trim().isNotEmpty)
                .map(
                  (item) => TaskDraft(
                    taskId: item.id,
                    description: item.description,
                    selected: item.empId.isEmpty,
                    estimatedHours: item.estimatedHours,
                  ),
                ),
          );
        _isLoadingItems = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..add(TaskDraft(description: '', selected: true));
        _isLoadingItems = false;
        _itemsError = true;
      });
    }
  }

  void _toast(String msg, {IconData? icon, Color? color}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: ink, size: AppDimensions.iconSm),
              const SizedBox(width: AppDimensions.s8),
            ],
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectTechnician(String empId, String name) {
    HapticFeedback.selectionClick();
    setState(() => _selectedTechnicianId = empId);
    _toast(
      StaffLocalizations.of(context)!.advisorDispatchSelected(name),
      icon: Icons.check_circle_outline_rounded,
      color: context.semanticColors.success.base,
    );
  }

  Future<void> _assignTasks() async {
    final t = StaffLocalizations.of(context)!;
    final selectedTasks = _tasks
        .where((task) => task.selected && task.description.trim().isNotEmpty)
        .toList();
    if (_selectedTechnicianId == null) {
      HapticFeedback.selectionClick();
      _toast(t.advisorDispatchNeedTech, icon: Icons.person_outline_rounded);
      return;
    }
    if (selectedTasks.isEmpty) {
      HapticFeedback.selectionClick();
      _toast(t.advisorDispatchNeedTask, icon: Icons.info_outline_rounded);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final remote = ref.read(advisorRemoteDataSourceProvider);
      final ok = await remote.assignTasks(widget.jobCardRef, {
        'jobCardId': widget.jobCardRef,
        'items': selectedTasks
            .map(
              (task) => {
                if (task.taskId > 0) 'taskId': task.taskId,
                'description': task.description.trim(),
                'technicianEmpId': _selectedTechnicianId,
                if (task.estimatedHours > 0)
                  'estimatedHours': task.estimatedHours,
              },
            )
            .toList(),
      });
      if (mounted) {
        if (ok) {
          HapticFeedback.mediumImpact();
          _toast(
            t.advisorDispatchSuccess,
            icon: Icons.check_circle_outline_rounded,
            color: context.semanticColors.success.base,
          );
          Navigator.pop(context);
        } else {
          _toast(
            t.advisorDispatchFailed,
            icon: Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.error,
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        _toast(
          t.advisorDispatchError('$e'),
          icon: Icons.error_outline_rounded,
          color: Theme.of(context).colorScheme.error,
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final pendingSync =
        ref.watch(advisorPendingSyncCountProvider).valueOrNull ?? 0;
    final techniciansAsync = ref.watch(advisorTechniciansProvider);
    final technicians = techniciansAsync.value ?? [];
    final techLoading = techniciansAsync.isLoading;
    final techError = techniciansAsync.hasError;

    final validTasksCount = _tasks
        .where((task) => task.selected && task.description.trim().isNotEmpty)
        .length;
    final selectedTech = technicians
        .where((tech) => tech.empId == _selectedTechnicianId)
        .firstOrNull;
    final ctaLabel = validTasksCount == 1
        ? t.advisorDispatchCtaOne
        : t.advisorDispatchCta(validTasksCount);
    final canDispatch =
        !_isLoading && _selectedTechnicianId != null && validTasksCount > 0;

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );
    final maxWidth = context.adaptive.pick(
      compact: double.infinity,
      medium: 640.0,
      expanded: 1180.0,
    );

    final techSection = _TechnicianSection(
      loading: techLoading,
      hasError: techError,
      technicians: technicians,
      selectedId: _selectedTechnicianId,
      onSelect: _selectTechnician,
      onRetry: () => ref.invalidate(advisorTechniciansProvider),
    );

    final taskSection = _TaskSection(
      loading: _isLoadingItems,
      hasError: _itemsError,
      tasks: _tasks,
      onAdd: () => setState(() => _tasks.add(TaskDraft(description: ''))),
      onRetry: _loadGeneratedItems,
      onRemove: (i) => setState(() => _tasks.removeAt(i)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Product exception (home grammar): greeting header owns identity +
      // sync pill + refresh; no WorkspaceAppBar bulk. Breadcrumbs below
      // carry the pushed wayfinding.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.s16,
            AppDimensions.s12,
            AppDimensions.s16,
            AppDimensions.s12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selectedTech != null) ...[
                Text(
                  t.advisorDispatchAssignedTo(selectedTech.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
              ],
              PrimaryButton(
                label: ctaLabel,
                icon: Icons.send_outlined,
                isLoading: _isLoading,
                onPressed: canDispatch ? _assignTasks : null,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s16,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _DispatchGreetingHeader(
                      jobCardRef: widget.jobCardRef,
                      pendingSync: pendingSync,
                      onBack: () => Navigator.pop(context),
                      onRefresh: () {
                        ref.invalidate(advisorTechniciansProvider);
                        _loadGeneratedItems();
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.s20,
                    AppDimensions.s12,
                    AppDimensions.s20,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AppBreadcrumbs(
                      items: [
                        AppBreadcrumbItem(
                          label: t.advisorNavJobs,
                          onTap: () => Navigator.pop(context),
                        ),
                        AppBreadcrumbItem.current(t.advisorDispatchTitle),
                      ],
                    ),
                  ),
                ),
                if (wide)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.s20,
                      AppDimensions.s16,
                      AppDimensions.s20,
                      AppDimensions.s24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: techSection),
                          const SizedBox(width: AppDimensions.s24),
                          Expanded(flex: 2, child: taskSection),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.s20,
                      AppDimensions.s16,
                      AppDimensions.s20,
                      AppDimensions.s24,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          techSection,
                          const SizedBox(height: AppDimensions.s24),
                          taskSection,
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── GREETING HEADER (home grammar, pushed variant) ──────────────────────────
class _DispatchGreetingHeader extends StatelessWidget {
  final String jobCardRef;
  final int pendingSync;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _DispatchGreetingHeader({
    required this.jobCardRef,
    required this.pendingSync,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            onBack();
          },
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back_rounded),
          color: colors.onSurfaceVariant,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.advisorDispatchTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                t.advisorDispatchSubtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.s10,
                  vertical: AppDimensions.s4,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    jobCardRef,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mono(color: colors.onSurface),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OfflineStatusPill(pendingSyncCount: pendingSync),
            const SizedBox(height: AppDimensions.s8),
            IconButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onRefresh();
              },
              tooltip: t.advisorActionRefreshJobCard,
              icon: const Icon(Icons.refresh_rounded),
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }
}

// ─── TECHNICIAN SECTION (home tile grammar) ──────────────────────────────────
class _TechnicianSection extends StatelessWidget {
  final bool loading;
  final bool hasError;
  final List<AdvisorTechnicianResponse> technicians;
  final String? selectedId;
  final void Function(String empId, String name) onSelect;
  final VoidCallback onRetry;

  const _TechnicianSection({
    required this.loading,
    required this.hasError,
    required this.technicians,
    required this.selectedId,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: t.advisorDispatchTechnicianSection,
          subtitle: t.advisorDispatchSelectTech,
          leadingIcon: Icons.engineering_outlined,
          count: technicians.isEmpty ? null : technicians.length,
        ),
        if (loading)
          const _TechnicianSkeleton()
        else if (hasError)
          EmptyState.error(
            message: t.advisorStudioError,
            onRetry: onRetry,
          )
        else if (technicians.isEmpty)
          EmptyState(
            icon: Icons.engineering_outlined,
            message: t.advisorDispatchEmpty,
          )
        else
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < technicians.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  _TechnicianCard(
                    tech: technicians[i],
                    selected: technicians[i].empId == selectedId,
                    onTap: () => onSelect(
                      technicians[i].empId,
                      technicians[i].name,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final AdvisorTechnicianResponse tech;
  final bool selected;
  final VoidCallback onTap;

  const _TechnicianCard({
    required this.tech,
    required this.selected,
    required this.onTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _skillLabel(StaffLocalizations t, TechSkill skill) => switch (skill) {
    TechSkill.brakes => t.advisorDispatchSkillBrakes,
    TechSkill.ac => t.advisorDispatchSkillAc,
    TechSkill.electrical => t.advisorDispatchSkillElectrical,
    TechSkill.engine => t.advisorFocusEngine,
    TechSkill.suspension => t.advisorFocusSuspension,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final t = StaffLocalizations.of(context)!;
    final load = loadForTechnician(tech.empId);
    final free = isFree(tech.empId);
    final availability = free
        ? t.advisorDispatchFree
        : t.advisorDispatchAvailableIn(availabilityFor(tech.empId));
    final skills = skillsForTechnician(tech.empId);

    return Semantics(
      button: true,
      selected: selected,
      label: '${tech.name}, $availability',
      child: Material(
        color: selected ? semantic.selectedSurface : colors.surface,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s12,
                vertical: AppDimensions.s12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary
                          : colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: colors.primary, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(tech.name),
                      style: theme.textTheme.titleSmall?.copyWith(
                        // FIXED-INK: white initials on the saturated
                        // primary avatar fill when selected.
                        color: selected
                            ? colors.onPrimary
                            : colors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tech.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: AppDimensions.iconSm,
                                color: colors.primary,
                              ),
                          ],
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            tech.empId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mono(
                              color: colors.onSurfaceVariant,
                            ).copyWith(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.s6),
                        Wrap(
                          spacing: AppDimensions.s6,
                          runSpacing: AppDimensions.s6,
                          children: [
                            for (final skill in skills)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.s8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusPill,
                                  ),
                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _skillLabel(t, skill),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.s8),
                        Row(
                          children: [
                            Expanded(
                              child: AppLinearProgress(
                                value: (load / 5).clamp(0.0, 1.0),
                                height: 6,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.s8),
                            Text(
                              t.advisorDispatchLoad(load),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              free
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.schedule_rounded,
                              size: AppDimensions.iconXs,
                              color: free
                                  ? semantic.success.base
                                  : semantic.warning.base,
                            ),
                            const SizedBox(width: AppDimensions.s4),
                            Expanded(
                              child: Text(
                                availability,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: free
                                      ? semantic.success.ink
                                      : semantic.warning.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s4),
                  DirectionalIcon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TechnicianSkeleton extends StatelessWidget {
  const _TechnicianSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard.standard(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const Divider(height: AppDimensions.s24),
            const Row(
              children: [
                AppSkeleton.circle(size: 44),
                SizedBox(width: AppDimensions.s12),
                Expanded(child: AppSkeleton.textBlock(lines: 2)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── TASK SECTION ────────────────────────────────────────────────────────────
class _TaskSection extends StatelessWidget {
  final bool loading;
  final bool hasError;
  final List<TaskDraft> tasks;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final void Function(int index) onRemove;

  const _TaskSection({
    required this.loading,
    required this.hasError,
    required this.tasks,
    required this.onAdd,
    required this.onRetry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: t.advisorDispatchTaskSection,
          leadingIcon: Icons.fact_check_outlined,
          count: tasks.isEmpty ? null : tasks.length,
          action: t.advisorDispatchAddExtraWork,
          onAction: () {
            HapticFeedback.selectionClick();
            onAdd();
          },
        ),
        AppCard.standard(
          child: Column(
            children: [
              if (loading)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.s16),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      ),
                      const SizedBox(width: AppDimensions.s12),
                      Expanded(
                        child: Text(
                          t.advisorDispatchLoading,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (hasError && tasks.isEmpty)
                EmptyState.error(
                  message: t.advisorStudioError,
                  onRetry: onRetry,
                )
              else if (tasks.isEmpty)
                EmptyState(
                  icon: Icons.fact_check_outlined,
                  message: t.advisorDispatchEmpty,
                  actionLabel: t.advisorDispatchAddExtraWork,
                  onAction: onAdd,
                )
              else
                for (var i = 0; i < tasks.length; i++) ...[
                  if (i > 0)
                    Divider(height: AppDimensions.s16, color: colors.outlineVariant),
                  _TaskRow(
                    index: i,
                    draft: tasks[i],
                    showRemove: tasks.length > 1,
                    onRemove: () => onRemove(i),
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatefulWidget {
  final int index;
  final TaskDraft draft;
  final bool showRemove;
  final VoidCallback onRemove;

  const _TaskRow({
    required this.index,
    required this.draft,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  late final TextEditingController _descCtrl = TextEditingController(
    text: widget.draft.description,
  );
  late final TextEditingController _hoursCtrl = TextEditingController(
    text: widget.draft.estimatedHours > 0
        ? '${widget.draft.estimatedHours}'
        : '',
  );

  @override
  void dispose() {
    _descCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.draft.selected,
          activeColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          ),
          onChanged: (v) => setState(() => widget.draft.selected = v ?? true),
        ),
        Expanded(
          child: TextField(
            controller: _descCtrl,
            onChanged: (v) => widget.draft.description = v,
            maxLines: 2,
            minLines: 1,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: t.advisorDispatchTaskHint,
              filled: true,
              fillColor: colors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s14,
                vertical: AppDimensions.s12,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s8),
        SizedBox(
          width: 78,
          child: TextField(
            controller: _hoursCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) =>
                widget.draft.estimatedHours = double.tryParse(v.trim()) ?? 0,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              hintText: t.advisorDispatchHoursHint,
              filled: true,
              fillColor: colors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s10,
                vertical: AppDimensions.s12,
              ),
            ),
          ),
        ),
        if (widget.showRemove)
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: colors.error,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.onRemove();
            },
          ),
      ],
    );
  }
}
