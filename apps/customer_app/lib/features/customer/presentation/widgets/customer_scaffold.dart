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
      label: 'Appointments',
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

    return Scaffold(
      extendBody: true,
      appBar: null,
      body: Stack(
        children: [
          Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: AppAdaptiveNavigationFrame(
                  items: _navItems,
                  selectedIndex: state.selectedIndex,
                  onSelected: notifier.selectTab,
                  child: IndexedStack(
                    index: state.selectedIndex,
                    children: _pages,
                  ),
                ),
              ),
            ],
          ),
          if (!adaptive.useNavigationRail)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomNav(
                items: _navItems,
                selectedIndex: state.selectedIndex,
                onTap: notifier.selectTab,
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int selectedIndex;
  final void Function(int) onTap;

  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: SizedBox(
        height: 66,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.72),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.16),
                    blurRadius: 30,
                    spreadRadius: -8,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Row(
                  children: List.generate(items.length, (i) {
                    final sel = selectedIndex == i;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: sel,
                        label: items[i].label,
                        child: InkWell(
                          onTap: () => onTap(i),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 7,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  width: sel ? 42 : 34,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? colorScheme.primary.withValues(
                                            alpha: 0.12,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    sel ? items[i].selectedIcon : items[i].icon,
                                    color: sel
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
                                    size: sel ? 22 : 21,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Flexible(
                                  child: Text(
                                    items[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: sel
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: sel
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 11,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
