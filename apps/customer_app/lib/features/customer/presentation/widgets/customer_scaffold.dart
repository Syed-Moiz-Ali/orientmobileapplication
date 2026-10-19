import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
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
    final t = CustomerLocalizations.of(context)!;
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final items = _navItems(t);

    // Must stay in [CustomerDestination] order.
    final pages = <Widget>[
      const CustomerHomeTab(),
      const CustomerBookingsTab(),
      const CustomerVehiclesTab(),
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

    return DashboardShell(
      // The bar pill owns offline state; the banner stays off.
      showOfflineBanner: false,
      appBar: WorkspaceAppBar(
        title: titles[state.selectedIndex],
        subtitle: subtitles[state.selectedIndex],
        showOfflineStatus: true,
        offlinePendingCount: pending,
        actions: [
          _BellButton(unreadCount: state.unreadCount),
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.s14),
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

/// Bell with the real unread badge. Opens the pushed notifications inbox.
class _BellButton extends StatelessWidget {
  final int unreadCount;

  const _BellButton({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return NotificationBell(
      showBadge: unreadCount > 0,
      badgeCount: unreadCount > 0 ? unreadCount : null,
      onPressed: () {
        HapticFeedback.selectionClick();
        context.push(AppRoutes.customerNotifications);
      },
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
        message: CustomerLocalizations.of(context)!.garNavProfile,
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
