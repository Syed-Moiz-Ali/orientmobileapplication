import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_app_bar.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_approvals_tab.dart';

class CustomerScaffold extends ConsumerStatefulWidget {
  final int initialTab;
  const CustomerScaffold({super.key, this.initialTab = 0});

  @override
  ConsumerState<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends ConsumerState<CustomerScaffold> {
  static const _pages = <Widget>[
    CustomerHomeTab(),
    CustomerServiceStatusTab(),
    CustomerBookingsTab(),
    CustomerApprovalsTab(),
    CustomerVehiclesTab(),
  ];

  @override
  void initState() {
    super.initState();
    // FIX (audit): apply the requested initial tab once (deep-link/extra).
    if (widget.initialTab > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(customerDashboardProvider.notifier).selectTab(widget.initialTab);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomerAppBar(state: state, notifier: notifier),
      body: IndexedStack(index: state.selectedIndex, children: _pages),
      bottomNavigationBar: _BottomNav(selectedIndex: state.selectedIndex, onTap: (index) => notifier.selectTab(index)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.track_changes_rounded, Icons.track_changes_outlined, 'Status'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Bookings'),
      (Icons.fact_check_rounded, Icons.fact_check_outlined, 'Approvals'),
      (Icons.directions_car_rounded, Icons.directions_car_outlined, 'Vehicles'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.12))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = selectedIndex == i;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: sel,
                  label: items[i].$3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: sel ? colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(
                          sel ? items[i].$1 : items[i].$2,
                          color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].$3,
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
