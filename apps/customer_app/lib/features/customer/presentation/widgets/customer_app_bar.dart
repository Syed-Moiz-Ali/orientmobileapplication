import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:customer_app/core/models/profile_data.dart';
import 'package:customer_app/features/customer/presentation/customer_notifications_view.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';

const Color _navy = AppColors.darkNavy;

class CustomerAppBar extends ConsumerWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
        // FE-FIX (pre-deployment): the bell was decorative â€” no badge, no
        // destination, while the backend delivered real notifications.
        NotificationBell(
          showBadge: state.unreadCount > 0,
          badgeCount: state.unreadCount > 99 ? null : state.unreadCount,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerNotificationsView(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(
            initials: 'C',
            onTap: () => showProfileSheet(
              context,
              // FIX (audit QA BUG-027): onLogout was never wired — the
              // Logout button confirmed but did nothing.
              customerProfileData,
              onLogout: () => ref
                  .read(authNotifierProvider.notifier)
                  .logout(),
            ),
          ),
        ),
      ],
    );
  }
}
