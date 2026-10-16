import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Compact agenda cell keeps the time only (mirrors the bay-tile meta rule).
String _shortTime(String bookingDate) {
  final parts = bookingDate.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) return parts.sublist(1).join(' ');
  return bookingDate.trim();
}

/// Bay schedule: today's appointment agenda as a compact matrix with the
/// current day highlighted, plus a filter over the agenda status. Rows open the
/// dispatch queue. Real booking data only.
class SupervisorScheduleTab extends ConsumerStatefulWidget {
  final VoidCallback onOpenQueue;
  const SupervisorScheduleTab({super.key, required this.onOpenQueue});

  @override
  ConsumerState<SupervisorScheduleTab> createState() =>
      _SupervisorScheduleTabState();
}

class _SupervisorScheduleTabState
    extends ConsumerState<SupervisorScheduleTab> {
  String? _filter;

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(supervisorDashboardProvider);
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bookings = notifier.bookings;

    final todayLabel = t.svScheduleToday;
    final confirmedLabel = SharedCoreL10n.of(context).statusConfirmed;
    final pendingLabel = SharedCoreL10n.of(context).statusPending;

    final sorted = [...bookings]
      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    final filtered = _filter == null
        ? sorted
        : sorted.where((b) {
            if (_filter == todayLabel) return bookingIsToday(b);
            if (_filter == confirmedLabel) {
              return b.status.toLowerCase().contains('confirm');
            }
            if (_filter == pendingLabel) {
              return b.status.toLowerCase().contains('pending');
            }
            return true;
          }).toList();

    final counts = {
      todayLabel: bookings.where(bookingIsToday).length,
      confirmedLabel: bookings
          .where((b) => b.status.toLowerCase().contains('confirm'))
          .length,
      pendingLabel: bookings
          .where((b) => b.status.toLowerCase().contains('pending'))
          .length,
    };

    final isEmpty = bookings.isEmpty && !state.isQueueLoading;
    final isNoMatch = _filter != null && filtered.isEmpty && bookings.isNotEmpty;

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
              title: t.svScheduleTitle,
              subtitle: t.svScheduleSubtitle,
              leading: const Icon(Icons.calendar_month_outlined),
              trailing: StatusPill.info(todayLabel),
            ),
            const SizedBox(height: AppDimensions.s16),
            AppFilterBar(
              options: [todayLabel, confirmedLabel, pendingLabel],
              selected: _filter,
              counts: counts,
              onSelected: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: AppDimensions.s16),
            if (state.queueError.isNotEmpty)
              AppInfoPanel.danger(
                message: t.svScheduleError,
                action: TextButton(
                  onPressed: notifier.refreshQueue,
                  child: Text(SharedCoreL10n.of(context).commonRetry),
                ),
              )
            else if (state.isQueueLoading && isEmpty)
              const AppSkeleton.table(rows: 6, columns: 4)
            else if (isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.s40),
                child: EmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: t.svScheduleEmpty,
                  message: t.svScheduleEmptyMessage,
                ),
              )
            else if (isNoMatch)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
                child: EmptyState.noMatch(
                  message: t.svScheduleEmpty,
                  actionLabel: SharedCoreL10n.of(context).filterBarClear,
                  onAction: () => setState(() => _filter = null),
                ),
              )
            else
              _ScheduleTable(
                bookings: filtered,
                onOpenQueue: () {
                  HapticFeedback.selectionClick();
                  widget.onOpenQueue();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTable extends StatelessWidget {
  final List<BookingQueueResponse> bookings;
  final VoidCallback onOpenQueue;

  const _ScheduleTable({required this.bookings, required this.onOpenQueue});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    return AppTable<BookingQueueResponse>(
      columns: [
        AppTableColumn(label: t.svScheduleTime, flex: 2, numeric: true),
        AppTableColumn(label: t.svScheduleVehicle, flex: 3),
        AppTableColumn(label: t.svScheduleService, flex: 3),
        AppTableColumn(label: t.svScheduleStatus, flex: 2),
      ],
      items: bookings,
      itemKey: (b) => ValueKey('sv-schedule-${b.id}'),
      isSelected: bookingIsToday,
      onRowTap: (_) => onOpenQueue(),
      cells: (ctx, b) => [
        AppTableCell.custom(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              b.bookingDate,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: supervisorMono(
                ctx,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
          AlignmentDirectional.centerEnd,
        ),
        AppTableCell.text(ctx, b.vehicleName.isNotEmpty ? b.vehicleName : b.customerName),
        AppTableCell.text(ctx, b.serviceType),
        AppTableCell.custom(
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: supervisorStatusPill(b.status),
          ),
          AlignmentDirectional.centerStart,
        ),
      ],
      compactBuilder: (ctx, b) => Row(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              _shortTime(b.bookingDate),
              style: supervisorMono(
                ctx,
                color: context.colors.onSurfaceVariant,
              ).copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.vehicleName.isNotEmpty ? b.vehicleName : b.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  b.serviceType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s8),
          supervisorStatusPill(b.status),
        ],
      ),
    );
  }
}
