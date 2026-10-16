import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Floor command board (Phase 11, Archetype 4 — Tactical Operations Radar).
///
/// A spatial 16-bay workshop map coloured by bay state (occupied / idle / parts
/// delay / QC), not a KPI grid. Each tile carries the bay id, technician
/// initials when known, the job and its real meta; tapping a bay opens the
/// dispatch sheet. On wide viewports the rail beside the board previews the
/// incoming queue / selected bay.
class SupervisorDashboardTab extends ConsumerStatefulWidget {
  final VoidCallback onOpenAssign;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenReview;

  const SupervisorDashboardTab({
    super.key,
    required this.onOpenAssign,
    required this.onOpenQueue,
    required this.onOpenReview,
  });

  @override
  ConsumerState<SupervisorDashboardTab> createState() =>
      _SupervisorDashboardTabState();
}

class _SupervisorDashboardTabState
    extends ConsumerState<SupervisorDashboardTab> {
  String? _filter;
  SupervisorBay? _selected;

  void _onBayTap(SupervisorBay bay) {
    HapticFeedback.selectionClick();
    setState(() => _selected = bay);
    widget.onOpenAssign();
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final awaiting = notifier.awaitingCompletions;
    final jobs = notifier.jobs;
    final bookings = notifier.bookings;
    final breakdowns = notifier.breakdowns;

    final bays = buildSupervisorBays(
      awaiting: awaiting,
      jobs: jobs,
      bookings: bookings,
    );
    final isEmpty =
        jobs.isEmpty && bookings.isEmpty && awaiting.isEmpty;

    final wide = !context.isCompact;

    return RefreshIndicator(
      onRefresh: notifier.refreshDashboard,
      color: context.colors.primary,
      backgroundColor: context.colors.surface,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.pagePadding.left,
          AppDimensions.s16,
          context.pagePadding.right,
          AppDimensions.s40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.dashboardError.isNotEmpty) ...[
              AppInfoPanel.danger(
                message: t.svFloorError,
                action: TextButton(
                  onPressed: notifier.refreshDashboard,
                  child: Text(SharedCoreL10n.of(context).commonRetry),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            if (state.isDashboardLoading && isEmpty)
              const _FloorSkeleton()
            else ...[
              _FloorMasthead(
                active: bays.where((b) => b.hasJob).length,
                filter: _filter,
                onFilter: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: AppDimensions.s16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _FloorBoard(
                        bays: _filteredBays(t, bays),
                        selected: _selected,
                        isNoMatch: _isNoMatch(t, bays),
                        onTap: _onBayTap,
                        onClearFilter: () => setState(() => _filter = null),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s24),
                    Expanded(
                      flex: 2,
                      child: _FloorRail(
                        selected: _selected,
                        breakdowns: breakdowns,
                        bookings: bookings,
                        onOpenQueue: widget.onOpenQueue,
                        onOpenReview: widget.onOpenReview,
                        onDispatch: widget.onOpenAssign,
                      ),
                    ),
                  ],
                )
              else ...[
                _FloorBoard(
                  bays: _filteredBays(t, bays),
                  selected: _selected,
                  isNoMatch: _isNoMatch(t, bays),
                  onTap: _onBayTap,
                  onClearFilter: () => setState(() => _filter = null),
                ),
                const SizedBox(height: AppDimensions.s24),
                _FloorRail(
                  selected: _selected,
                  breakdowns: breakdowns,
                  bookings: bookings,
                  onOpenQueue: widget.onOpenQueue,
                  onOpenReview: widget.onOpenReview,
                  onDispatch: widget.onOpenAssign,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<SupervisorBay> _filteredBays(StaffLocalizations t, List<SupervisorBay> bays) {
    final filter = _filter;
    if (filter == null) return bays;
    final state = switch (filter) {
      _ when filter == t.svBayOccupied => SupervisorBayState.occupied,
      _ when filter == t.svBayPartsDelay => SupervisorBayState.partsDelay,
      _ when filter == t.svBayQc => SupervisorBayState.qc,
      _ when filter == t.svBayIdle => SupervisorBayState.idle,
      _ => null,
    };
    if (state == null) return bays;
    return bays.where((b) => b.state == state).toList();
  }

  bool _isNoMatch(StaffLocalizations t, List<SupervisorBay> bays) =>
      _filter != null && _filteredBays(t, bays).isEmpty;
}

// ─── MASTHEAD ────────────────────────────────────────────────────────────────

class _FloorMasthead extends StatelessWidget {
  final int active;
  final String? filter;
  final ValueChanged<String?> onFilter;

  const _FloorMasthead({
    required this.active,
    required this.filter,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: t.svFloorTitle,
          subtitle: t.svFloorSubtitle(active, kSupervisorBayCount),
          leadingIcon: Icons.grid_view_rounded,
        ),
        const _BayLegend(),
        const SizedBox(height: AppDimensions.s8),
        AppFilterBar(
          options: [
            t.svBayOccupied,
            t.svBayPartsDelay,
            t.svBayQc,
            t.svBayIdle,
          ],
          selected: filter,
          onSelected: onFilter,
        ),
      ],
    );
  }
}

class _BayLegend extends StatelessWidget {
  const _BayLegend();

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final entries = <(String, SupervisorBayState)>[
      (t.svBayOccupied, SupervisorBayState.occupied),
      (t.svBayIdle, SupervisorBayState.idle),
      (t.svBayPartsDelay, SupervisorBayState.partsDelay),
      (t.svBayQc, SupervisorBayState.qc),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: AppDimensions.s4),
      child: Wrap(
        spacing: AppDimensions.s16,
        runSpacing: AppDimensions.s6,
        children: [
          for (final (label, state) in entries)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: supervisorBayTone(context, state).base,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.s6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── FLOOR BOARD ─────────────────────────────────────────────────────────────

class _FloorBoard extends StatelessWidget {
  final List<SupervisorBay> bays;
  final SupervisorBay? selected;
  final bool isNoMatch;
  final ValueChanged<SupervisorBay> onTap;
  final VoidCallback onClearFilter;

  const _FloorBoard({
    required this.bays,
    required this.selected,
    required this.isNoMatch,
    required this.onTap,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    if (isNoMatch) {
      return AppCard.standard(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
        child: EmptyState.noMatch(
          message: t.svFloorNoMatch,
          actionLabel: SharedCoreL10n.of(context).filterBarClear,
          onAction: onClearFilter,
        ),
      );
    }
    final columns = context.adaptive.pick(
      compact: 2,
      medium: 3,
      expanded: 4,
      large: 4,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimensions.s10;
        final width = constraints.maxWidth;
        final tileWidth = (width - spacing * (columns - 1)) / columns;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final bay in bays)
                  SizedBox(
                    width: tileWidth,
                    child: _BayTile(
                      bay: bay,
                      selected: selected?.number == bay.number &&
                          bay.hasJob &&
                          selected?.ref == bay.ref,
                      onTap: () => onTap(bay),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.s8),
            Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: AppDimensions.iconXs,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.s6),
                Expanded(
                  child: Text(
                    t.svFloorTapHint,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// One spatial bay tile: state-tinted surface, status rail, bay id, technician
/// initials and the job identity. Never a KPI card — the plate is the board's
/// spatial unit.
class _BayTile extends StatelessWidget {
  final SupervisorBay bay;
  final bool selected;
  final VoidCallback onTap;

  const _BayTile({
    required this.bay,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tone = supervisorBayTone(context, bay.state);
    final idle = bay.isIdle;

    return Semantics(
      button: true,
      selected: selected,
      label: '${bayCode(bay.number)}, '
          '${_stateLabel(context, bay.state)}'
          '${bay.hasJob ? ', ${bay.ref}' : ''}',
      child: Material(
        color: idle ? context.semanticColors.surfaceSubtle : tone.subtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: BorderSide(
            color: selected ? colors.primary : tone.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.primary.withValues(alpha: 0.08),
          highlightColor: colors.primary.withValues(alpha: 0.04),
          child: Container(
            constraints: const BoxConstraints(minHeight: 104),
            padding: const EdgeInsets.all(AppDimensions.s10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        bayCode(bay.number),
                        style: AppTextStyles.mono(
                          color: colors.onSurfaceVariant,
                        ).copyWith(fontWeight: FontWeight.w800, fontSize: 11),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: tone.base,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.s8),
                _TechSlot(initials: bay.techInitials, tone: tone),
                const SizedBox(height: AppDimensions.s8),
                if (idle)
                  Text(
                    _stateLabel(context, bay.state),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  Text(
                    bay.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            bay.ref,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mono(
                              color: colors.onSurfaceVariant,
                            ).copyWith(fontSize: 10.5),
                          ),
                        ),
                      ),
                      if (bay.meta.isNotEmpty) ...[
                        const SizedBox(width: AppDimensions.s4),
                        Flexible(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              bay.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.mono(
                                color: colors.onSurfaceVariant,
                              ).copyWith(fontSize: 10.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _stateLabel(BuildContext context, SupervisorBayState state) {
    final t = StaffLocalizations.of(context)!;
    return switch (state) {
      SupervisorBayState.occupied => t.svBayOccupied,
      SupervisorBayState.partsDelay => t.svBayPartsDelay,
      SupervisorBayState.qc => t.svBayQc,
      SupervisorBayState.idle => t.svBayIdle,
    };
  }
}

/// Technician initials slot — a filled chip when a real technician is known,
/// otherwise a dashed "unassigned" placeholder (never an invented name).
class _TechSlot extends StatelessWidget {
  final String initials;
  final AppStatusColors tone;
  const _TechSlot({required this.initials, required this.tone});

  @override
  Widget build(BuildContext context) {
    final hasInitials = initials.isNotEmpty;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hasInitials
                ? tone.base.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: hasInitials
                ? Border.all(color: tone.border)
                : Border.all(
                    color: context.semanticColors.borderStrong,
                    width: 1,
                  ),
          ),
          child: Text(
            hasInitials ? initials : '—',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: hasInitials
                  ? tone.ink
                  : context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SIDE RAIL ───────────────────────────────────────────────────────────────

class _FloorRail extends StatelessWidget {
  final SupervisorBay? selected;
  final List<BreakdownQueueResponse> breakdowns;
  final List<BookingQueueResponse> bookings;
  final VoidCallback onOpenQueue;
  final VoidCallback onOpenReview;
  final VoidCallback onDispatch;

  const _FloorRail({
    required this.selected,
    required this.breakdowns,
    required this.bookings,
    required this.onOpenQueue,
    required this.onOpenReview,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final bay = selected;
    final pending = [
      ...breakdowns.map((b) => b.vehicleName),
      ...bookings.map((b) => b.vehicleName),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (bay != null && bay.hasJob) ...[
          AppCard.standard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: bay.title,
                  leadingIcon: Icons.place_outlined,
                  count: bay.number,
                  padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                ),
                Text(
                  bay.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                PrimaryButton(
                  label: t.svAssignTitle,
                  icon: Icons.engineering_rounded,
                  onPressed: onDispatch,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        AppCard.standard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: t.svFloorQueueTitle,
                count: breakdowns.length + bookings.length,
                leadingIcon: Icons.inbox_outlined,
                padding: const EdgeInsets.only(bottom: AppDimensions.s4),
              ),
              if (pending.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.s16),
                  child: Text(
                    t.svFloorQueueEmpty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                for (final b in breakdowns.take(2))
                  _RailRow(
                    icon: Icons.emergency_rounded,
                    tone: context.semanticColors.danger,
                    title: b.issue.isNotEmpty ? b.issue : b.vehicleName,
                    subtitle: b.location,
                    onTap: onOpenQueue,
                  ),
                for (final b in bookings.take(3))
                  _RailRow(
                    icon: Icons.event_rounded,
                    tone: context.semanticColors.info,
                    title: b.serviceType,
                    subtitle: b.vehicleName,
                    onTap: onOpenQueue,
                  ),
              ],
              const SizedBox(height: AppDimensions.s4),
              SecondaryButton(
                label: t.svQueueTitle,
                leadingIcon: Icons.arrow_forward_rounded,
                onPressed: onOpenQueue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppCard.standard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                title: t.svReviewTitle,
                leadingIcon: Icons.verified_outlined,
                padding: const EdgeInsets.only(bottom: AppDimensions.s4),
              ),
              SecondaryButton(
                label: t.svNavReview,
                leadingIcon: Icons.fact_check_outlined,
                onPressed: onOpenReview,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RailRow extends StatelessWidget {
  final IconData icon;
  final AppStatusColors tone;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RailRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
        child: Row(
          children: [
            Icon(icon, size: AppDimensions.iconSm, color: tone.base),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
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

// ─── SKELETON ────────────────────────────────────────────────────────────────

class _FloorSkeleton extends StatelessWidget {
  const _FloorSkeleton();

  @override
  Widget build(BuildContext context) {
    final columns = context.adaptive.pick(
      compact: 2,
      medium: 3,
      expanded: 4,
      large: 4,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSkeleton(width: 160, height: 20),
        const SizedBox(height: AppDimensions.s8),
        const AppSkeleton(width: 220, height: 14),
        const SizedBox(height: AppDimensions.s16),
        AppSkeleton.grid(columns: columns, rows: 4, itemHeight: 104),
      ],
    );
  }
}
