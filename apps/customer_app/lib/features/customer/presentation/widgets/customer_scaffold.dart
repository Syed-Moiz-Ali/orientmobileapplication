import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_approvals_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

class CustomerScaffold extends ConsumerStatefulWidget {
  final int initialTab;
  final String pendingEstimateId;

  const CustomerScaffold({
    super.key,
    this.initialTab = 0,
    this.pendingEstimateId = '',
  });

  @override
  ConsumerState<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends ConsumerState<CustomerScaffold> {
  static const _navItems = <AppNavItem>[
    AppNavItem(
      selectedIcon: Icons.home_rounded,
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    AppNavItem(
      selectedIcon: Icons.track_changes_rounded,
      icon: Icons.track_changes_outlined,
      label: 'Status',
    ),
    AppNavItem(
      selectedIcon: Icons.calendar_month_rounded,
      icon: Icons.calendar_month_outlined,
      label: 'Bookings',
    ),
    AppNavItem(
      selectedIcon: Icons.fact_check_rounded,
      icon: Icons.fact_check_outlined,
      label: 'Approvals',
    ),
    AppNavItem(
      selectedIcon: Icons.directions_car_rounded,
      icon: Icons.directions_car_outlined,
      label: 'Vehicles',
    ),
    AppNavItem(
      selectedIcon: Icons.person_rounded,
      icon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _applyInitialTab();
  }

  @override
  void didUpdateWidget(covariant CustomerScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _applyInitialTab();
    }
  }

  void _applyInitialTab() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(customerDashboardProvider.notifier)
            .selectTab(widget.initialTab);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final adaptive = context.adaptive;
    final pages = <Widget>[
      const CustomerHomeTab(),
      const CustomerServiceStatusTab(),
      const CustomerBookingsTab(),
      CustomerApprovalsTab(initialEstimateId: widget.pendingEstimateId),
      const CustomerVehiclesTab(),
      const CustomerProfileTab(),
    ];

    return DashboardShell(
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        child: IndexedStack(index: state.selectedIndex, children: pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: _navItems,
              selectedIndex: state.selectedIndex,
              onSelected: notifier.selectTab,
            ),
    );
  }
}
