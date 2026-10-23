import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Floor command board (Phase 11, Archetype 4 — Tactical Operations Radar;
/// phase-5 recomposition onto App* pattern widgets).
///
/// A spatial 16-bay workshop map coloured by bay state (occupied / idle / parts
/// delay / QC), not a KPI grid. Each tile carries the bay id, technician
/// initials when known, the job and its real meta; tapping a bay opens the
/// dispatch sheet. On wide viewports the rail beside the board previews the
/// incoming queue / selected bay. Presentation only: providers, routes, sync,
/// selection state and the bay derivation are untouched.
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
    final coreT = SharedCoreL10n.of(context);
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
    final active = bays.where((b) => b.hasJob).length;

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
            // No local offline banner: the shell owns the abnormal-only
            // [OfflineBanner] (C16 — announced once, never duplicated).
            if (state.dashboardError.isNotEmpty)
              AppErrorState(
                title: t.svFloorErrorTitle,
                message: t.svFloorError,
                retryLabel: coreT.commonRetry,
                onRetry: notifier.refreshDashboard,
              )
            else if (state.isDashboardLoading && isEmpty)
              const _FloorSkeleton()
            else ...[
              _FloorHeader(
                title: t.svFloorTitle,
                subtitle: t.svFloorSubtitle(active, kSupervisorBayCount),
              ),
              const SizedBox(height: AppDimensions.s16),
              _FloorHero(
                active: active,
                onDispatch: widget.onOpenAssign,
              ),
              const SizedBox(height: AppDimensions.s16),
              _FloorFilter(
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
                      child: isEmpty
                          ? _FloorEmpty(onDispatch: widget.onOpenAssign)
                          : _FloorBoard(
                              bays: _filteredBays(t, bays),
                              selected: _selected,
                              isNoMatch: _isNoMatch(t, bays),
                              onTap: _onBayTap,
                              onClearFilter: () =>
                                  setState(() => _filter = null),
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
                if (isEmpty)
                  _FloorEmpty(onDispatch: widget.onOpenAssign)
                else
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

// ─── HEADER + HERO + FILTER ──────────────────────────────────────────────────

/// Floor header: title + occupancy sentence. The search glyph moved to the
/// shell AppBar top-right (ruling (a) — same floor sheet/target); this header
/// keeps title + subtitle only, so the floor tab shows exactly one search
/// icon. Same strings, same text styles.
class _FloorHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FloorHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.colors.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppDimensions.s4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// ONE hero summary: plain dispatch sentence + the single primary Dispatch
/// CTA. No decorative media panel or card chrome — the occupancy count
/// already lives in the header subtitle, so the hero stays one sentence.
class _FloorHero extends StatelessWidget {
  final int active;
  final VoidCallback onDispatch;

  const _FloorHero({required this.active, required this.onDispatch});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.svFloorHeroSentence,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppDimensions.s12),
        AppPillButton.primary(
          label: t.svAssignTitle,
          icon: Icons.engineering_rounded,
          onPressed: onDispatch,
        ),
      ],
    );
  }
}

class _FloorFilter extends StatelessWidget {
  final String? filter;
  final ValueChanged<String?> onFilter;

  const _FloorFilter({required this.filter, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

/// Empty floor: the hero above already owns the single primary Dispatch CTA,
/// so the board slot carries the friendly empty state with NO action —
//  exactly one filled Dispatch per screen (U7 / one-primary-per-screen).
class _FloorEmpty extends StatelessWidget {
  final VoidCallback onDispatch;

  const _FloorEmpty({required this.onDispatch});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return AppEmptyState(
      icon: Icons.grid_view_rounded,
      title: t.svFloorEmpty,
      message: t.svFloorEmptyMessage,
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
      // ONE filled CTA per screen: the hero Dispatch above stays primary, so
      // the no-match Clear is a secondary action (never a second filled CTA).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppEmptyState(
            icon: Icons.search_off_rounded,
            title: t.svFloorNoMatch,
            message: t.svFloorNoMatchHint,
          ),
          const SizedBox(height: AppDimensions.s12),
          AppPillButton.secondary(
            label: SharedCoreL10n.of(context).filterBarClear,
            onPressed: onClearFilter,
          ),
        ],
      );
    }
    // C16 exact tiling (16 bays divide evenly — no orphan tile):
    // compact 2, medium 2 (board + rail side-by-side per brief §States),
    // expanded/large 4 (brief's 4-col bend). Medium was 3 (16 mod 3 = 1
    // orphan); 2-col also widens tiles so the vehicle identity fits
    // without a mid-token cut (U5). Tile data unchanged.
    final columns = context.adaptive.pick(
      compact: 2,
      medium: 2,
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
    // C5 border-OR-shadow: light tiles are borderless with a soft shadow
    // (selected keeps the functional primary ring); dark keeps the border
    // and never a shadow.
    final dark = theme.brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: selected,
      label: '${bayCode(bay.number)}, '
          '${_stateLabel(context, bay.state)}'
          '${bay.hasJob ? ', ${bay.ref}' : ''}',
      child: Material(
        color: idle ? context.semanticColors.surfaceSubtle : tone.subtle,
        elevation: !dark && !selected ? 2 : 0,
        shadowColor: !dark ? colors.shadow.withValues(alpha: 0.14) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: selected
              ? BorderSide(color: colors.primary, width: 1.6)
              : (dark
                    ? BorderSide(color: tone.border, width: 1)
                    : BorderSide.none),
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
                  // U5 full-word labels: the vehicle identity wraps to a
                  // second line at word boundaries instead of truncating
                  // mid-token (`Camry ABC 12…`). Same string, same style.
                  Text(
                    bay.title,
                    maxLines: 2,
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
          AppSurfaceCard(
            headerTitle: bay.title,
            headerTrailing: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                bayCode(bay.number),
                style: supervisorMono(context),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  bay.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppDimensions.s12),
                AppPillButton.secondary(
                  label: t.svAssignTitle,
                  icon: Icons.engineering_rounded,
                  onPressed: onDispatch,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.s16),
        ],
        AppSurfaceCard(
          headerTitle: t.svFloorQueueTitle,
          headerTrailing: Text(
            '${breakdowns.length + bookings.length}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (pending.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: AppDimensions.s16),
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
              AppPillButton.secondary(
                label: t.svQueueTitle,
                icon: Icons.arrow_forward_rounded,
                onPressed: onOpenQueue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s16),
        AppSurfaceCard(
          headerTitle: t.svReviewTitle,
          child: AppPillButton.secondary(
            label: t.svNavReview,
            icon: Icons.fact_check_outlined,
            onPressed: onOpenReview,
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
    // Mirrors _FloorBoard columns so the loading shimmer matches the board.
    final columns = context.adaptive.pick(
      compact: 2,
      medium: 2,
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
            const AppShimmerSkeleton(width: 160, height: 20),
            const SizedBox(height: AppDimensions.s8),
            const AppShimmerSkeleton(width: 220, height: 14),
            const SizedBox(height: AppDimensions.s16),
            const AppShimmerSkeleton.card(height: 120),
            const SizedBox(height: AppDimensions.s16),
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (var i = 0; i < 8; i++)
                  SizedBox(
                    width: tileWidth,
                    child: const AppShimmerSkeleton.card(height: 104),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),
            const AppShimmerSkeleton.card(height: 148),
            const SizedBox(height: AppDimensions.s16),
            const AppShimmerSkeleton.card(height: 96),
          ],
        );
      },
    );
  }
}
