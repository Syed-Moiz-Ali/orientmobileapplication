import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/models/profile_data.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

const Color _navy = AppColors.darkNavy;

class CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CustomerDashboardState state;
  final CustomerDashboardNotifier notifier;

  const CustomerAppBar({
    super.key,
    required this.state,
    required this.notifier,
  });

  static const _titles = [
    'Customer Portal',
    'Service Status',
    'Book a Service',
    'Estimates & Invoices',
    'My Vehicles',
  ];

  static const _subtitles = [
    'Welcome back',
    'Live Job Tracker',
    'Schedule an Appointment',
    'Approve Workshop Estimates',
    'Registered Vehicles',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [_navy, AppColors.accent]),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleSpacing: 0,
      leading: state.selectedIndex == 0
          ? Padding(
              padding: const EdgeInsets.all(AppDimensions.s10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => notifier.selectTab(0),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[state.selectedIndex],
            style: AppTextStyles.rajdhaniTitle(color: Colors.white),
          ),
          Text(
            _subtitles[state.selectedIndex],
            style: AppTextStyles.rajdhaniBodySmall(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: 'C',
            onTap: () => showProfileSheet(context, customerProfileData),
          ),
        ),
      ],
    );
  }
}
