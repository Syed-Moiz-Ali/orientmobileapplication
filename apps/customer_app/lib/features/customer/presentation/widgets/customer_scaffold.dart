import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/support/customer_destination.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

/// Customer workspace shell.
///
/// Exactly four permanent destinations — Home, Bookings, Vehicles and Profile —
/// configured straight from [CustomerDestination], so the navigation order,
/// labels and indices have one source of truth and the shared More/overflow
/// destination is never needed here.
///
/// Service Status and Approvals are deliberately absent: both are contextual
/// pushed pages (`CustomerServiceStatusPage`, `CustomerApprovalsPage`) reached
/// from Home, Bookings, Booking Details or a deep link when they genuinely
/// apply to the customer right now.
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
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final adaptive = context.adaptive;
    final items = CustomerDestination.navItems;

    // Must stay in [CustomerDestination] order.
    final pages = <Widget>[
      const CustomerHomeTab(),
      const CustomerBookingsTab(),
      const CustomerVehiclesTab(),
      const CustomerProfileTab(),
    ];

    return DashboardShell(
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: state.selectedIndex,
        onSelected: notifier.selectTab,
        headerBuilder: (ctx, ext) => OrientBrandMark(
          workspace: 'Customer',
          compact: !ext,
        ),
        footerBuilder: (ctx, ext) => InkWell(
          onTap: () => notifier.selectTab(3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ext ? AppDimensions.s8 : 0,
              vertical: AppDimensions.s4,
            ),
            child: ext
                ? Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                        child: Text(
                          'C',
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.s10),
                      Expanded(
                        child: Text(
                          'My Account',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(ctx).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: 'My Account',
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                      child: Text(
                        'C',
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        child: IndexedStack(index: state.selectedIndex, children: pages),
      ),
      bottomNavigationBar: adaptive.useNavigationRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: state.selectedIndex,
              onSelected: notifier.selectTab,
            ),
    );
  }
}
