import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

class CustomerScaffold extends ConsumerStatefulWidget {
  final int initialTab;

  const CustomerScaffold({super.key, this.initialTab = 0});

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

  static const _pages = <Widget>[
    CustomerHomeTab(),
    CustomerServiceStatusTab(),
    CustomerBookingsTab(),
    CustomerVehiclesTab(),
    CustomerProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTab > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(customerDashboardProvider.notifier)
              .selectTab(widget.initialTab);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final adaptive = context.adaptive;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return DashboardShell(
      body: AppAdaptiveNavigationFrame(
        items: _navItems,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        child: IndexedStack(index: state.selectedIndex, children: _pages),
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
