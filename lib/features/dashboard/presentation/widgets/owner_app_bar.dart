import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/core/widgets/notification_bell.dart';
import 'package:orientmobileapplication/core/widgets/user_avatar.dart';
import 'package:orientmobileapplication/core/widgets/profile_sheet.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/providers/dashboard_ui_providers.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/period_dropdown.dart';

class OwnerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const OwnerAppBar({super.key});

  static const _titles = ['Owner Dashboard', 'Top Sales', 'Messages'];
  static const _subtitles = [
    'Bircon, Hifri',
    'Performance Breakdown by Category',
    'Internal Messaging',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardUiProvider);
    final notifier = ref.read(dashboardUiProvider.notifier);

    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.navy, AppColors.accent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                ),
                child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 22),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => notifier.selectTab(0),
            ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_titles[state.selectedIndex], style: AppTextStyles.rajdhaniButton(color: Colors.white)),
          Text(_subtitles[state.selectedIndex], style: AppTextStyles.rajdhaniBodySmall(color: Colors.white70)),
        ],
      ),
      actions: [
        if (state.selectedIndex == 0)
          const Padding(padding: EdgeInsets.only(right: 6), child: PeriodDropdown()),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(initials: 'O', onTap: () => showProfileSheet(context, _profileData)),
        ),
      ],
    );
  }
}

const _profileData = ProfileSheetData(
  name: 'Owner',
  initials: 'O',
  roleLabel: 'Owner',
  roleBadge: 'Owner \u2022 Auto Garage ERP',
);
