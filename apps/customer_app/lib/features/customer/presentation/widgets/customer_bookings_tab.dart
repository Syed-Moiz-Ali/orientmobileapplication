import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_bookings_presentation.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';
import 'package:customer_app/features/customer/presentation/support/customer_service_tracking.dart';
import 'package:customer_app/features/customer/presentation/support/failed_booking_sync.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_booking_item.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_filter_sheet.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_search_sheet.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_failed_booking_item.dart';

/// Customer Bookings — "my appointments and service history".
///
/// A management/history surface, not a second tracker: rows stay compact and
/// the live service timeline stays in Status. Everything shown comes from real
/// booking fields; there is no service catalogue, pricing, stock imagery or
/// fabricated availability.
///
/// Presentation only — providers, sync, predicates, refresh, routes and keys
/// are unchanged; the list is rebuilt on shared atoms (AppPageHeader, cards,
/// search/filter sheets, AppBanner, AppEmptyState/AppErrorState,
/// AppShimmerSkeleton).
class CustomerBookingsTab extends ConsumerStatefulWidget {
  const CustomerBookingsTab({super.key});

  @override
  ConsumerState<CustomerBookingsTab> createState() =>
      _CustomerBookingsTabState();
}

class _CustomerBookingsTabState extends ConsumerState<CustomerBookingsTab> {
  /// List-scoped lifecycle filter (presentation state only; the group
  /// derivation stays in `CustomerBookingsPresentation.groupOf`).
  CustomerBookingFilter _filter = CustomerBookingFilter.all;

  /// Scroll anchors for search-result reveals (presentation only).
  final Map<String, GlobalKey> _scrollKeys = {};

  GlobalKey _scrollKeyFor(String id) =>
      _scrollKeys.putIfAbsent(id, () => GlobalKey());

  static String _anchorOf(CustomerBookingEntity booking) =>
      CustomerBookingsPresentation.bookingKey(
        vehicleName: booking.vehicleName,
        plateNumber: booking.plateNumber,
        service: booking.service,
        date: booking.date,
        time: booking.time,
      );

  bool _matchesFilter(CustomerBookingGroup group) => switch (_filter) {
    CustomerBookingFilter.all => true,
    CustomerBookingFilter.upcoming => group == CustomerBookingGroup.upcoming,
    CustomerBookingFilter.inService => group == CustomerBookingGroup.inService,
    CustomerBookingFilter.history => group == CustomerBookingGroup.history,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    final dash = ref.watch(customerDashboardProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    // Local bookings whose replay the workshop never accepted are terminal
    // failures, not lifecycle records: they are pulled out of the workshop feed
    // so they never render (or count) as an ordinary requested booking.
    final failedBookings = ref.watch(customerFailedBookingsProvider);
    final failedKeys = failedBookings
        .map((booking) => booking.identityKey)
        .toSet();
    final bookings =
        (bookingsAsync.valueOrNull ?? const <CustomerBookingEntity>[])
            .where(
              (booking) => !failedKeys.contains(
                CustomerBookingsPresentation.bookingKey(
                  vehicleName: booking.vehicleName,
                  plateNumber: booking.plateNumber,
                  service: booking.service,
                  date: booking.date,
                  time: booking.time,
                ),
              ),
            )
            .toList();

    // The bookings feed falls back to the local cache, so "nothing readable"
    // plus a reported failure is the only honest first-load error signal.
    final firstLoadFailed =
        bookings.isEmpty &&
        failedBookings.isEmpty &&
        (bookingsAsync.hasError || dash.loadError.isNotEmpty);

    if (firstLoadFailed) {
      return AppResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s48),
          child: AppErrorState(
            title: t.bkLoadFailTitle,
            message: t.bkLoadFailBody,
            retryLabel: t.bkRetryCta,
            onRetry: () => _refresh(ref),
          ),
        ),
      );
    }

    if (bookingsAsync.isLoading && bookings.isEmpty) {
      // Skeleton mirrors the cards: header lines + card shapes.
      return AppResponsivePage(
        maxContentWidth: 1080,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppShimmerSkeleton(width: 130, height: 26),
            SizedBox(height: AppDimensions.s10),
            AppShimmerSkeleton(width: 200, height: 12),
            SizedBox(height: AppDimensions.s20),
            AppShimmerSkeleton.card(height: 148),
            SizedBox(height: AppDimensions.s12),
            AppShimmerSkeleton.card(height: 148),
          ],
        ),
      );
    }

    final visible = [
      for (final booking in bookings)
        if (_matchesFilter(
          CustomerBookingsPresentation.groupOf(booking.status),
        ))
          booking,
    ];
    _scrollKeys.removeWhere(
      (id, _) => !bookings.any((booking) => _anchorOf(booking) == id),
    );

    final active = <CustomerBookingEntity>[];
    final inWorkshop = <CustomerBookingEntity>[];
    final history = <CustomerBookingEntity>[];
    for (final booking in visible) {
      switch (CustomerBookingsPresentation.groupOf(booking.status)) {
        case CustomerBookingGroup.inService:
          inWorkshop.add(booking);
          active.add(booking);
        case CustomerBookingGroup.upcoming:
          active.add(booking);
        case CustomerBookingGroup.history:
          history.add(booking);
      }
    }

    final activeOrdered = CustomerBookingsPresentation.sortByUpcoming(active);
    final historyOrdered = CustomerBookingsPresentation.sortByRecent(history);
    final liveService =
        CustomerServiceTracking.isLiveService(dash.activeService)
        ? dash.activeService
        : null;

    // Progressive disclosure (the ONE sanctioned U1 exception, vehicles-list
    // precedent): the search + filter find-aids appear ONLY when the loaded
    // list has MORE THAN 5 items; with ≤ 5 items the cards stand alone.
    final showFindAids = bookings.length > 5;
    final subtitle = _subtitle(
      t,
      active: activeOrdered.length,
      inWorkshop: inWorkshop.length,
      history: historyOrdered.length,
    );

    final sections = <Widget>[
      if (activeOrdered.isNotEmpty)
        _BookingSection(
          title: inWorkshop.isEmpty
              ? t.bkUpcoming
              : '${t.bkUpcoming} & ${t.bkInService.toLowerCase()}',
          count: activeOrdered.length,
          bookings: activeOrdered,
          liveService: liveService,
          formatAmount: dash.formatAmount,
          scrollKeyFor: _scrollKeyFor,
          anchorOf: _anchorOf,
          onOpen: (booking) =>
              context.push(AppRoutes.customerBookingDetail, extra: booking),
          // Service Status is contextual: it is a pushed page, not a tab.
          onTrackService: () => context.push(AppRoutes.customerServiceStatus),
          onReviewApproval: (estimateId) =>
              context.go(AppRoutes.approvalsLocation(estimateId: estimateId)),
        ),
      if (historyOrdered.isNotEmpty)
        _BookingSection(
          title: t.bkHistory,
          count: historyOrdered.length,
          bookings: historyOrdered,
          liveService: liveService,
          formatAmount: dash.formatAmount,
          scrollKeyFor: _scrollKeyFor,
          anchorOf: _anchorOf,
          onOpen: (booking) =>
              context.push(AppRoutes.customerBookingDetail, extra: booking),
          // Service Status is contextual: it is a pushed page, not a tab.
          onTrackService: () => context.push(AppRoutes.customerServiceStatus),
          onReviewApproval: (estimateId) =>
              context.go(AppRoutes.approvalsLocation(estimateId: estimateId)),
        ),
    ];

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      color: colors.primary,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        // A single group keeps a comfortable reading width; two groups share
        // the wider canvas instead of stretching one phone-wide column.
        maxContentWidth: sections.length == 2 ? 1080 : 760,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plain Row header (not AppPageHeader, whose compact layout stacks
            // actions below the subtitle): title+subtitle expanded start-side,
            // search/filter/Book actions end-side on the SAME row. Same >5
            // condition, same sheets/targets. RTL-mirrored.
            _BookingsHeader(
              title: t.bkTitle,
              subtitle: subtitle,
              showFindAids: showFindAids,
              showBook: bookings.isNotEmpty,
              searchTooltip: t.bkSearchTitle,
              filterTooltip: t.bkFilterTitle,
              bookLabel: t.bkBookCta,
              onSearch: () => _openSearch(bookings),
              onFilter: _openFilter,
              onBook: () => context.push(AppRoutes.customerBookService),
            ),
            if (dash.loadError.isNotEmpty && bookings.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s16),
              AppBanner(
                kind: AppBannerKind.warning,
                message: t.stRefreshFail,
                actionLabel: t.stRetry,
                onAction: () => _refresh(ref),
              ),
            ],
            const SizedBox(height: AppDimensions.s20),
            if (failedBookings.isNotEmpty) ...[
              _FailedBookingsSection(bookings: failedBookings),
              const SizedBox(height: AppDimensions.s24),
            ],
            if (bookings.isEmpty && failedBookings.isEmpty)
              _NoBookings(
                hasVehicles: dash.vehicles.isNotEmpty,
                onBookService: () =>
                    context.push(AppRoutes.customerBookService),
                onAddVehicle: () => context.push(AppRoutes.customerAddVehicle),
              )
            else if (visible.isEmpty)
              _FilterNoMatch(
                onClear: () => setState(
                  () => _filter = CustomerBookingFilter.all,
                ),
              )
            else if (sections.length == 2)
              AppSplitView(
                primaryFlex: context.adaptive.isMedium ? 1 : 3,
                secondaryFlex: context.adaptive.isMedium ? 1 : 2,
                spacing: AppDimensions.s24,
                primary: sections[0],
                secondary: sections[1],
              )
            else if (sections.isNotEmpty)
              sections.single,
          ],
        ),
      ),
    );
  }

  void _openSearch(List<CustomerBookingEntity> bookings) {
    showCustomerBookingsSearchSheet(
      context,
      bookings: bookings,
      onSelect: (booking) {
        final anchor = _scrollKeys[_anchorOf(booking)]?.currentContext;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (anchor != null) {
            Scrollable.ensureVisible(
              anchor,
              duration: const Duration(milliseconds: 300),
              alignment: 0.05,
            );
          }
        });
      },
    );
  }

  void _openFilter() {
    showCustomerBookingsFilterSheet(
      context,
      selected: _filter,
      onApply: (selected) => setState(() => _filter = selected),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(customerBookingsProvider);
    await ref.read(customerDashboardProvider.notifier).refresh();
  }

  static String _subtitle(
    CustomerLocalizations t, {
    required int active,
    required int inWorkshop,
    required int history,
  }) {
    // Local presentation count copy; the groups themselves come from the
    // frozen presentation helpers.
    final upcoming = active - inWorkshop;
    final parts = <String>[
      if (upcoming > 0)
        upcoming == 1 ? t.bkUpOne : t.bkUpMany(upcoming),
      if (inWorkshop > 0)
        inWorkshop == 1 ? t.bkInOne : t.bkInMany(inWorkshop),
      if (history > 0)
        history == 1 ? t.bkPastOne : t.bkPastMany(history),
    ];
    if (parts.isEmpty) return t.bkSubDefault;
    return parts.join(' \u00b7 ');
  }
}

/// Upcoming/current or history group of borderless booking cards.
class _BookingSection extends StatelessWidget {
  final String title;
  final int count;
  final List<CustomerBookingEntity> bookings;
  final CustomerServiceEntity? liveService;
  final String Function(double amount) formatAmount;
  final GlobalKey Function(String id) scrollKeyFor;
  final String Function(CustomerBookingEntity booking) anchorOf;
  final void Function(CustomerBookingEntity booking) onOpen;
  final VoidCallback onTrackService;
  final void Function(String estimateId) onReviewApproval;

  const _BookingSection({
    required this.title,
    required this.count,
    required this.bookings,
    required this.formatAmount,
    required this.onOpen,
    required this.onTrackService,
    required this.onReviewApproval,
    required this.scrollKeyFor,
    required this.anchorOf,
    this.liveService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title, count: count),
        for (var index = 0; index < bookings.length; index++) ...[
          SizedBox(
            key: scrollKeyFor(anchorOf(bookings[index])),
            child: CustomerBookingItem(
              booking: bookings[index],
              liveService: _liveServiceFor(bookings[index]),
              formatAmount: formatAmount,
              onOpen: () => onOpen(bookings[index]),
              onTrackService: onTrackService,
              onReviewApproval: onReviewApproval,
            ),
          ),
          if (index < bookings.length - 1)
            const SizedBox(height: AppDimensions.s12),
        ],
      ],
    );
  }

  /// Only the booking that owns the live job card carries live stage detail.
  CustomerServiceEntity? _liveServiceFor(CustomerBookingEntity booking) {
    final service = liveService;
    if (service == null) return null;
    final owner = CustomerServiceTracking.bookingForJobCard([
      booking,
    ], service.jobCardId);
    return owner == null ? null : service;
  }
}

class _NoBookings extends StatelessWidget {
  final bool hasVehicles;
  final VoidCallback onBookService;
  final VoidCallback onAddVehicle;

  const _NoBookings({
    required this.hasVehicles,
    required this.onBookService,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;

    return AppEmptyState(
      icon: Icons.calendar_month_outlined,
      title: hasVehicles ? t.bkEmptyTitle : t.bkEmptyVehiclesTitle,
      message: hasVehicles ? t.bkEmptyBody : t.bkEmptyVehiclesBody,
      actionLabel: hasVehicles ? t.bkBookCta : t.garHeroAdd,
      onAction: hasVehicles ? onBookService : onAddVehicle,
    );
  }
}

/// Filter-no-match state: the loaded list is non-empty but nothing matches the
/// active lifecycle filter. One sentence + one Clear control.
class _FilterNoMatch extends StatelessWidget {
  final VoidCallback onClear;

  const _FilterNoMatch({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.bkFilterNoMatch,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.s8),
            TextButton(
              onPressed: onClear,
              child: Text(t.bkFilterClear),
            ),
          ],
        ),
      ),
    );
  }
}

/// List header: title + count subtitle start-side, find-aids + Book end-side
/// on the SAME row (plain Row, not AppPageHeader whose compact layout stacks
/// actions below the subtitle). Same strings, styles, AppIconButton contract.
/// Presentation only.
class _BookingsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showFindAids;
  final bool showBook;
  final String searchTooltip;
  final String filterTooltip;
  final String bookLabel;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onBook;

  const _BookingsHeader({
    required this.title,
    required this.subtitle,
    required this.showFindAids,
    required this.showBook,
    required this.searchTooltip,
    required this.filterTooltip,
    required this.bookLabel,
    required this.onSearch,
    required this.onFilter,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    // Same pattern as vehicles: title row keeps search/filter top-right
    // (U1 fix); subtitle full width (U5); Book end-side below (same route).
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (showFindAids) ...[
                const SizedBox(width: AppDimensions.s8),
                AppIconButton(
                  icon: Icons.search_rounded,
                  tooltip: searchTooltip,
                  onPressed: onSearch,
                ),
                const SizedBox(width: AppDimensions.s8),
                AppIconButton(
                  icon: Icons.filter_list_rounded,
                  tooltip: filterTooltip,
                  onPressed: onFilter,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimensions.s4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (showBook) ...[
            const SizedBox(height: AppDimensions.s4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(bookLabel),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The local bookings the workshop never received. Every recovery action
/// targets one stable failed operation, so more than one failed booking is
/// supported and each is handled on its own.
class _FailedBookingsSection extends ConsumerStatefulWidget {
  final List<FailedBooking> bookings;

  const _FailedBookingsSection({required this.bookings});

  @override
  ConsumerState<_FailedBookingsSection> createState() =>
      _FailedBookingsSectionState();
}

class _FailedBookingsSectionState
    extends ConsumerState<_FailedBookingsSection> {
  /// Operation ids with a recovery action in flight, so a second tap cannot
  /// replay the same failed booking twice.
  final Set<String> _busy = {};

  Future<void> _retry(FailedBooking booking) async {
    final id = booking.operationId;
    if (_busy.contains(id)) return;
    setState(() => _busy.add(id));

    final accepted = await ref.read(failedBookingSyncProvider).retry(id);
    if (!mounted) return;

    // The terminal state is read from the failed operation, so a successful
    // replay clears it whether or not the follow-up refresh succeeds. A failed
    // refresh must never bring "Not sent" back — the workshop has the booking.
    ref.invalidate(customerFailedBookingsProvider);
    ref.invalidate(customerBookingsProvider);
    await ref.read(customerDashboardProvider.notifier).refresh();
    if (!mounted) return;

    setState(() => _busy.remove(id));
    if (!accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.cx.bkSendFail),
        ),
      );
    }
  }

  Future<void> _remove(FailedBooking booking) async {
    final id = booking.operationId;
    if (_busy.contains(id)) return;

    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    // Confirmation becomes a bottom sheet (destructive, no undo — same
    // failedBookingSync.remove handler + invalidate contracts as before).
    final confirmed =
        await showAppModalSheet<bool>(
          context: context,
          title: t.bkRemoveTitle,
          builder: (sheetContext) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                child: Text(
                  t.bkRemoveBody,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      sheetContext,
                    ).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s16),
              FilledButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                ),
                child: Text(t.bkRemoveCta),
              ),
              const SizedBox(height: AppDimensions.s8),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                child: Text(t.bkKeepCta),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;

    setState(() => _busy.add(id));
    await ref.read(failedBookingSyncProvider).remove(id);
    if (!mounted) return;
    ref.invalidate(customerFailedBookingsProvider);
    ref.invalidate(customerBookingsProvider);
    setState(() => _busy.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: context.cx.bkFailedTitle,
          count: widget.bookings.length,
        ),
        for (var index = 0; index < widget.bookings.length; index++) ...[
          CustomerFailedBookingItem(
            booking: widget.bookings[index],
            busy: _busy.contains(widget.bookings[index].operationId),
            onRetry: () => _retry(widget.bookings[index]),
            onRemove: () => _remove(widget.bookings[index]),
          ),
          if (index < widget.bookings.length - 1)
            const SizedBox(height: AppDimensions.s12),
        ],
      ],
    );
  }
}
