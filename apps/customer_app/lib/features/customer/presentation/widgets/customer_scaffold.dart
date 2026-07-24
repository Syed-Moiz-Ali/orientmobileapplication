import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_app_bar.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_book_service_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_home_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_vehicles_tab.dart';

class CustomerScaffold extends ConsumerStatefulWidget {
  const CustomerScaffold({super.key});

  @override
  ConsumerState<CustomerScaffold> createState() => _CustomerScaffoldState();
}

class _CustomerScaffoldState extends ConsumerState<CustomerScaffold> {
  static const _pages = <Widget>[
    CustomerHomeTab(),
    CustomerServiceStatusTab(),
    CustomerBookServiceTab(),
    CustomerVehiclesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerDashboardProvider);
    final notifier = ref.read(customerDashboardProvider.notifier);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return DashboardShell(
      appBar: CustomerAppBar(state: state, notifier: notifier),
      body: IndexedStack(index: state.selectedIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        selectedIndex: state.selectedIndex,
        onTap: (index) => notifier.selectTab(index),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _BottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.track_changes_rounded, Icons.track_changes_outlined, 'Status'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Book'),
      (Icons.directions_car_rounded, Icons.directions_car_outlined, 'Vehicles'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: List.generate(items.length, (i) {
              final sel = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppColors.cyanLight
                              : Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r24)),
                        ),
                        child: Icon(
                          sel ? items[i].$1 : items[i].$2,
                          color: sel ? AppColors.accent : AppColors.text3,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? AppColors.accent : AppColors.text3,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                          letterSpacing: sel ? 0.2 : 0,
                        ),
                      ),
                    ],
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
