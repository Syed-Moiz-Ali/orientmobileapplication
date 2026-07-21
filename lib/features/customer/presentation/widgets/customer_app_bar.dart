import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/local/hive/hive_cleaner.dart';
import 'package:orientmobileapplication/core/pages/profile_view.dart';
import 'package:orientmobileapplication/core/router/app_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/features/customer/domain/entities/customer_entities.dart';
import 'package:orientmobileapplication/features/customer/providers/customer_providers.dart';

const Color _navy = AppColors.darkNavy;
const Color _accentLight = AppColors.cyanLight;

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
    'My Vehicles',
  ];

  static const _subtitles = [
    'Welcome back',
    'Live Job Tracker',
    'Schedule an Appointment',
    'Registered Vehicles',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_navy, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {},
            ),
            if (state.unreadCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: _navy, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.s14),
          child: GestureDetector(
            onTap: () => _showProfile(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  CustomerEntity.mock.avatarInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final customer = CustomerEntity.mock;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.rPill),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s24,
          AppDimensions.s16,
          AppDimensions.s24,
          AppDimensions.s32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppDimensions.r2),
              ),
            ),
            const SizedBox(height: AppDimensions.s24),
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  customer.avatarInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s14),
            Text(
              customer.name,
              style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.s4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.s12,
                vertical: AppDimensions.s4,
              ),
              decoration: BoxDecoration(
                color: _accentLight,
                borderRadius: BorderRadius.circular(AppDimensions.r20),
              ),
              child: Text(
                'Customer \u2022 Auto Garage ERP',
                style: AppTextStyles.rajdhaniLabel(color: AppColors.accent),
              ),
            ),
            const SizedBox(height: AppDimensions.s24),
            _menuItem(context,
              icon: Icons.person_outline_rounded,
              label: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.profile, extra: ProfileData(
                  name: customer.name,
                  id: 'CUST-001',
                  role: 'Customer',
                  branch: 'Auto Garage ERP',
                  shift: '',
                  avatarInitials: customer.avatarInitials,
                ));
              },
            ),
            _menuItem(context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.settings, extra: {
                  'version': '1.0.0',
                });
              },
            ),
            const SizedBox(height: AppDimensions.s8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.s6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.r12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.s12,
              vertical: AppDimensions.s14,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.text2),
                SizedBox(width: AppDimensions.s12),
                Text(
                  label,
                  style: AppTextStyles.rajdhaniBody(color: AppColors.textPrimary),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.text3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    if (HiveCleaner.hasPendingSync()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
          title: const Row(children: [
            Icon(Icons.sync_problem_rounded, color: AppColors.warning, size: 22),
            SizedBox(width: 10),
            Text('Sync Pending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ]),
          content: const Text(
            'You have pending sync operations.\nPlease wait for sync to complete before logging out.',
            style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r16)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: AppColors.danger, size: 22),
          SizedBox(width: 10),
          Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        content: const Text('Are you sure you want to logout?\nAll local data will be cleared.',
            style: TextStyle(fontSize: 14, color: AppColors.text2, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.text3)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              HiveCleaner.clearAll().then((_) {
                if (context.mounted) context.go(AppRoutes.roleSelection);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Yes, Logout', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
