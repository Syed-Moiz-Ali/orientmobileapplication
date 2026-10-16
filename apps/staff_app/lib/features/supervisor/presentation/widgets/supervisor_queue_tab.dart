import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Incoming dispatch queue (Phase 11): priority-sorted bookings and emergency
/// breakdowns as divider rows, routed to advisors through a shared modal.
class SupervisorQueueTab extends ConsumerStatefulWidget {
  final VoidCallback onOpenReview;
  const SupervisorQueueTab({super.key, required this.onOpenReview});

  @override
  ConsumerState<SupervisorQueueTab> createState() => _SupervisorQueueTabState();
}

class _SupervisorQueueTabState extends ConsumerState<SupervisorQueueTab> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bookings = notifier.bookings;
    final breakdowns = notifier.breakdowns;

    final vip = t.svQueuePriorityVip;
    final promised = t.svQueuePriorityPromised;
    final insurance = t.svQueuePriorityInsurance;

    final sortedBookings = [...bookings]
      ..sort(
        (a, b) => queuePriorityRank(bookingPriority(a)).compareTo(
          queuePriorityRank(bookingPriority(b)),
        ),
      );
    final visibleBookings = _filter == null
        ? sortedBookings
        : sortedBookings
              .where((b) => _priorityLabel(t, b) == _filter)
              .toList();

    final counts = {
      vip: bookings.where((b) => _priorityLabel(t, b) == vip).length,
      promised: bookings.where((b) => _priorityLabel(t, b) == promised).length,
      insurance: bookings
          .where((b) => _priorityLabel(t, b) == insurance)
          .length,
    };

    final isEmpty =
        bookings.isEmpty && breakdowns.isEmpty && !state.isQueueLoading;
    final isNoMatch = _filter != null &&
        visibleBookings.isEmpty &&
        breakdowns.isEmpty;

    return RefreshIndicator(
      onRefresh: notifier.refreshQueue,
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
            AppPageHeader(
              title: t.svQueueTitle,
              subtitle: t.svQueueSubtitle,
              leading: const Icon(Icons.alt_route_outlined),
              actions: [
                IconButton(
                  tooltip: SharedCoreL10n.of(context).commonRetry,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.refreshQueue();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),
            AppFilterBar(
              options: [vip, promised, insurance],
              selected: _filter,
              counts: counts,
              onSelected: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: AppDimensions.s16),
            if (state.queueError.isNotEmpty)
              AppInfoPanel.danger(
                message: t.svQueueError,
                action: TextButton(
                  onPressed: notifier.refreshQueue,
                  child: Text(SharedCoreL10n.of(context).commonRetry),
                ),
              )
            else if (state.isQueueLoading && isEmpty)
              const AppSkeleton.listRows(rows: 6)
            else if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.s32),
                child: EmptyState(
                  icon: Icons.inbox_outlined,
                  title: t.svQueueEmpty,
                  message: t.svQueueEmptyMessage,
                ),
              )
            else ...[
              if (isNoMatch && breakdowns.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
                  child: EmptyState.noMatch(
                    message: t.svQueueNoMatch,
                    actionLabel: SharedCoreL10n.of(context).filterBarClear,
                    onAction: () => setState(() => _filter = null),
                  ),
                )
              else ...[
                _SectionLabel(
                  icon: Icons.emergency_rounded,
                  tone: context.semanticColors.danger,
                  label: t.svQueueBreakdowns,
                  count: breakdowns.length,
                ),
                if (breakdowns.isEmpty)
                  _EmptyLine(message: t.svQueueEmptyMessage)
                else
                  for (final b in breakdowns)
                    _QueueRow(
                      icon: Icons.emergency_rounded,
                      tone: context.semanticColors.danger,
                      title: b.vehicleName.isNotEmpty ? b.vehicleName : b.issue,
                      detail: b.issue,
                      plate: b.vehiclePlate,
                      trailing: StatusPill.danger(t.svQueuePriorityEmergency),
                      onAssign: () => _route(
                        isBooking: false,
                        id: b.id,
                        label: b.vehicleName,
                      ),
                    ),
                const SizedBox(height: AppDimensions.s24),
                _SectionLabel(
                  icon: Icons.event_available_rounded,
                  tone: context.semanticColors.info,
                  label: t.svQueueBookings,
                  count: visibleBookings.length,
                ),
                if (visibleBookings.isEmpty)
                  _EmptyLine(message: t.svQueueEmptyMessage)
                else
                  for (final b in visibleBookings)
                    _QueueRow(
                      icon: Icons.event_rounded,
                      tone: context.semanticColors.info,
                      title: b.vehicleName.isNotEmpty ? b.vehicleName : b.serviceType,
                      detail: b.serviceType,
                      plate: b.plateNumber,
                      trailing: _priorityPill(t, b),
                      onAssign: () => _route(
                        isBooking: true,
                        id: b.id,
                        label: b.serviceType,
                      ),
                    ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _priorityLabel(StaffLocalizations t, BookingQueueResponse b) =>
      switch (bookingPriority(b)) {
        SupervisorQueuePriority.vip => t.svQueuePriorityVip,
        SupervisorQueuePriority.promisedToday => t.svQueuePriorityPromised,
        SupervisorQueuePriority.insurance => t.svQueuePriorityInsurance,
        SupervisorQueuePriority.normal => '',
      };

  Widget _priorityPill(StaffLocalizations t, BookingQueueResponse b) =>
      switch (bookingPriority(b)) {
        SupervisorQueuePriority.vip => StatusPill.warning(t.svQueuePriorityVip),
        SupervisorQueuePriority.promisedToday =>
          StatusPill.info(t.svQueuePriorityPromised),
        SupervisorQueuePriority.insurance =>
          StatusPill.neutral(t.svQueuePriorityInsurance),
        SupervisorQueuePriority.normal => const SizedBox.shrink(),
      };

  Future<void> _route({
    required bool isBooking,
    required int id,
    required String label,
  }) async {
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final advisors = notifier.advisors;
    if (advisors.isEmpty) {
      showSupervisorToast(context, t.svQueueNoAdvisors,
          icon: Icons.info_outline_rounded,
          color: context.semanticColors.warning.base);
      return;
    }
    final selected = await showAppModalSheet<int>(
      context: context,
      title: t.svQueueAssignTitle,
      builder: (_) => _AdvisorPicker(advisors: advisors, label: label),
    );
    if (selected == null || !mounted) return;
    final msg = isBooking
        ? await notifier.assignBooking(id, selected)
        : await notifier.assignBreakdown(id, selected);
    if (!mounted) return;
    final ok = isBooking
        ? msg == 'Booking assigned'
        : msg == 'Breakdown dispatched';
    showSupervisorToast(
      context,
      ok
          ? (isBooking ? t.svQueueAssigned : t.svQueueDispatched)
          : t.svQueueAssignFailed,
      icon: ok ? Icons.check_circle_outline : Icons.error_outline,
      color: ok ? context.semanticColors.success.base : context.semanticColors.danger.base,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final AppStatusColors tone;
  final String label;
  final int count;

  const _SectionLabel({
    required this.icon,
    required this.tone,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.s8),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSm, color: tone.base),
          const SizedBox(width: AppDimensions.s8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.s8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: tone.subtle,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              border: Border.all(color: tone.border),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: tone.ink,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final IconData icon;
  final AppStatusColors tone;
  final String title;
  final String detail;
  final String plate;
  final Widget trailing;
  final VoidCallback onAssign;

  const _QueueRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.detail,
    required this.plate,
    required this.trailing,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: AppDimensions.iconMd, color: tone.base),
                  const SizedBox(width: AppDimensions.s10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (detail.isNotEmpty)
                              Expanded(
                                child: Text(
                                  detail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            if (plate.isNotEmpty) ...[
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(
                                  plate,
                                  style: supervisorMono(
                                    context,
                                    color: context.colors.onSurfaceVariant,
                                  ).copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s8),
                  trailing,
                ],
              ),
              const SizedBox(height: AppDimensions.s10),
              SecondaryButton(
                label: t.svQueueAssign,
                leadingIcon: Icons.person_add_alt_1_rounded,
                onPressed: onAssign,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String message;
  const _EmptyLine({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.s16),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Advisor picker content for the shared responsive modal.
class _AdvisorPicker extends StatefulWidget {
  final List<AssignableStaffResponse> advisors;
  final String label;

  const _AdvisorPicker({required this.advisors, required this.label});

  @override
  State<_AdvisorPicker> createState() => _AdvisorPickerState();
}

class _AdvisorPickerState extends State<_AdvisorPicker> {
  late int _selected = widget.advisors.first.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.svQueueAssignHint,
          style: theme.textTheme.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        for (final a in widget.advisors)
          InkWell(
            onTap: () => setState(() => _selected = a.id),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.s12,
                horizontal: AppDimensions.s4,
              ),
              child: Row(
                children: [
                  Icon(
                    a.id == _selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: AppDimensions.iconMd,
                    color: a.id == _selected
                        ? context.colors.primary
                        : context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.onSurface,
                          ),
                        ),
                        if (a.role.isNotEmpty)
                          Text(
                            a.role,
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
          ),
        const SizedBox(height: AppDimensions.s12),
        PrimaryButton(
          label: t.svQueueAssign,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
