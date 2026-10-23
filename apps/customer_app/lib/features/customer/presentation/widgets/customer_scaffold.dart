import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_search_sheet.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';
import 'package:customer_app/l10n/gen/customer_localizations.dart';

List<AppNavItem> _navItems(CustomerLocalizations t) => <AppNavItem>[
      AppNavItem(
        selectedIcon: Icons.home_rounded,
        icon: Icons.home_outlined,
        label: t.garNavHome,
      ),
      AppNavItem(
        selectedIcon: Icons.calendar_month_rounded,
        icon: Icons.calendar_month_outlined,
        label: t.garNavBookings,
      ),
      AppNavItem(
        selectedIcon: Icons.directions_car_rounded,
        icon: Icons.directions_car_outlined,
        label: t.garNavVehicles,
      ),
      AppNavItem(
        selectedIcon: Icons.person_rounded,
        icon: Icons.person_outline_rounded,
        label: t.garNavProfile,
      ),
    ];

/// Customer workspace shell (consumer composition ONLY).
///
/// Brand/title bar with notifications bell, profile avatar and the offline
/// pill (banner off), plus an always-present bottom navigation across the
/// four permanent destinations. There is deliberately NO rail, NO
/// breadcrumbs and NO command palette here: enterprise workspace chrome is
/// forbidden on consumer surfaces (04.1 §3.1, Airbnb addendum §6).
///
/// Service Status and Approvals stay contextual pushed pages, reached from
/// Home, Bookings, Booking Details or a deep link when they genuinely apply.
class CustomerScaffold extends ConsumerStatefulWidget {
  final CustomerDestination initialDestination;

  const CustomerScaffold({
    super.key,
    this.initialDestination = CustomerDestination.home,
  });

  @override
  ConsumerState<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends ConsumerState<CustomerScaffold> {
  /// Keys let the shell AppBar search trigger open the SAME list-scoped
  /// sheets the tabs own (same predicate/target/reveal) — only WHICH visible
  /// icon opens them moved (ruling a). No logic/data/predicate changes.
  final _bookingsKey = GlobalKey<CustomerBookingsTabState>();
  final _vehiclesKey = GlobalKey<CustomerVehiclesTabState>();

  @override
  void initState() {
    super.initState();
    _applyInitialDestination();
  }

  @override
  void didUpdateWidget(covariant CustomerScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDestination != widget.initialDestination) {
      _applyInitialDestination();
    }
  }

  void _applyInitialDestination() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(customerDashboardProvider.notifier)
            .selectDestination(widget.initialDestination);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final items = _navItems(t);
    final bookings =
        ref.watch(customerBookingsProvider).valueOrNull ??
        const <CustomerBookingEntity>[];
    final vehicles = state.vehicles;

    // Must stay in [CustomerDestination] order.
    final pages = <Widget>[
      const CustomerHomeTab(),
      CustomerBookingsTab(key: _bookingsKey),
      CustomerVehiclesTab(key: _vehiclesKey),
      const CustomerProfileTab(),
    ];

    int pending = 0;
    try {
      pending = ref.watch(syncQueueProvider).length;
    } catch (_) {
      pending = 0;
    }

    final titles = <String>[
      t.garBrand,
      t.bkTitle,
      t.vhTitle,
      t.pfTitle,
    ];
    final subtitles = <String?>[
      t.garBrandSub,
      null,
      null,
      null,
    ];

    // Ruling (a): shell AppBar WITH search trigger — the icon lives HERE
    // (top-right, adjacent to bell/avatar); pages show none. Same
    // sheets/predicates/targets — only WHICH visible icon opens them moved.
    // >5 gating relocated verbatim: vehicles/bookings shell icons visible
    // ONLY when loaded >5; home always (no threshold ever existed there).
    final VoidCallback? shellSearch = switch (state.selectedIndex) {
      0 => () => _openHomeSearch(context, vehicles: vehicles, bookings: bookings),
      1 => bookings.length > 5
          ? () {
              HapticFeedback.selectionClick();
              _bookingsKey.currentState?.openSearch();
            }
          : null,
      2 => vehicles.length > 5
          ? () {
              HapticFeedback.selectionClick();
              _vehiclesKey.currentState?.openSearch();
            }
          : null,
      _ => null,
    };

    return DashboardShell(
      // The bar pill owns offline state; the banner stays off.
      showOfflineBanner: false,
      appBar: WorkspaceAppBar(
        title: titles[state.selectedIndex],
        subtitle: subtitles[state.selectedIndex],
        showOfflineStatus: true,
        offlinePendingCount: pending,
        // Shell search trigger (ruling a): direction-aware AppBar actions
        // mirror in RTL; bell/avatar stay end-side adjacent.
        onSearch: shellSearch,
        actions: [
          _BellButton(unreadCount: state.unreadCount),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: AppDimensions.s14),
            child: _ProfileAvatar(
              initials: state.profile?.avatarInitials.trim() ?? '',
              onTap: () {
                HapticFeedback.selectionClick();
                notifier.selectTab(3);
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(index: state.selectedIndex, children: pages),
      // Consumer shells never grow a rail: bottom navigation on every width.
      bottomNavigationBar: AppBottomNavigation(
        items: items,
        selectedIndex: state.selectedIndex,
        onSelected: (index) {
          HapticFeedback.selectionClick();
          notifier.selectTab(index);
        },
      ),
    );
  }
}

/// Opens the full-screen home search sheet over the home's existing vehicles +
/// bookings (same sheet/predicate/targets as the removed header icon — only
/// WHICH visible icon opens it moved to the shell AppBar per ruling a).
/// No new routes: result taps reuse the home's own destinations.
void _openHomeSearch(
  BuildContext context, {
  required List<CustomerVehicleEntity> vehicles,
  required List<CustomerBookingEntity> bookings,
}) {
  HapticFeedback.selectionClick();
  final size = MediaQuery.sizeOf(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      // Tight full-size box: the sheet route sizes to content, so the
      // content itself claims the screen (U1 full-screen search). The box
      // carries the surface token (the route Material is transparent).
      child: SizedBox.fromSize(
        size: size,
        child: ColoredBox(
          color: Theme.of(sheetContext).colorScheme.surface,
          child: SingleChildScrollView(
            child: CustomerHomeSearchSheet(
              vehicles: vehicles,
              bookings: bookings,
              onSelectVehicle: (vehicle) {
                Navigator.pop(sheetContext);
                context.push(
                  AppRoutes.customerBookServiceLocation(vehicleId: vehicle.id),
                );
              },
              onSelectBooking: (booking) {
                Navigator.pop(sheetContext);
                context.push(
                  AppRoutes.customerBookingDetail,
                  extra: booking,
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

/// Bell with the real unread badge. Opens the pushed notifications inbox.
///
/// Carries the exact announcement contract the home header bell used to own
/// (`Notifications, N unread`), so the single chrome relocation loses no
/// accessibility behavior.
class _BellButton extends StatelessWidget {
  final int unreadCount;

  const _BellButton({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: hasUnread
          ? 'Notifications, $unreadCount unread'
          : 'Notifications',
      child: NotificationBell(
        showBadge: hasUnread,
        badgeCount: hasUnread ? unreadCount : null,
        onPressed: () {
          HapticFeedback.selectionClick();
          context.push(AppRoutes.customerNotifications);
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String initials;
  final VoidCallback onTap;

  const _ProfileAvatar({required this.initials, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Tooltip(
        message: context.cx.garNavProfile,
        child: CircleAvatar(
          radius: 17,
          backgroundColor: colors.primary.withValues(alpha: 0.14),
          child: initials.isEmpty
              ? Icon(
                  Icons.person_outline_rounded,
                  size: AppDimensions.iconMd,
                  color: colors.primary,
                )
              : Text(
                  initials,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}
