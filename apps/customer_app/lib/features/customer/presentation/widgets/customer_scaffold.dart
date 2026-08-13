import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_bookings_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_profile_tab.dart';

class CustomerScaffold extends ConsumerStatefulWidget {
  final int initialTab;
  const CustomerScaffold({super.key, this.initialTab = 0});

  @override
  ConsumerState<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends ConsumerState<CustomerScaffold> {
  static const _navItems = <AppNavItem>[
    AppNavItem(selectedIcon: Icons.home_rounded, icon: Icons.home_outlined, label: 'Home'),
    AppNavItem(selectedIcon: Icons.track_changes_rounded, icon: Icons.track_changes_outlined, label: 'Status'),
    AppNavItem(selectedIcon: Icons.calendar_month_rounded, icon: Icons.calendar_month_outlined, label: 'Appointments'),
    AppNavItem(selectedIcon: Icons.directions_car_rounded, icon: Icons.directions_car_outlined, label: 'Vehicles'),
    AppNavItem(selectedIcon: Icons.person_rounded, icon: Icons.person_outline_rounded, label: 'Profile'),
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
          ref.read(customerDashboardProvider.notifier).selectTab(widget.initialTab);
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
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: AppAdaptiveNavigationFrame(
              items: _navItems,
              selectedIndex: state.selectedIndex,
              onSelected: notifier.selectTab,
              child: IndexedStack(index: state.selectedIndex, children: _pages),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !adaptive.useNavigationRail
          ? _BottomNav(items: _navItems, selectedIndex: state.selectedIndex, onTap: notifier.selectTab)
          : null,
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({required this.items, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(240),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = selectedIndex == i;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: sel,
                  label: items[i].label,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            // color: sel ? colorScheme.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            sel ? items[i].selectedIcon : items[i].icon,
                            color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                        // const SizedBox(height: 1),
                        Text(
                          items[i].label,
                          style: textTheme.labelSmall?.copyWith(
                            color: sel ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            fontWeight: sel ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
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
