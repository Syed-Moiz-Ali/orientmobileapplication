import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CrmUiNotifier notifier;
  const CrmAppBar({super.key, required this.notifier});

  static const _titles = [
    'CRM Dashboard',
    'Leads',
    'Conversations',
    'Sales Team',
    'Tasks',
    'Reports & Analytics',
    'Integrations',
    'Settings',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [CrmColors.gStart, CrmColors.gEnd])),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      leading: Builder(
        builder: (ctx) => InkWell(
          onTap: () => Scaffold.of(ctx).openDrawer(),
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r8)),
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HamburgerLine(width: 20),
                  SizedBox(height: 4),
                  _HamburgerLine(width: 14, faded: true),
                  SizedBox(height: 4),
                  _HamburgerLine(width: 18, faded: true),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _titles[notifier.selectedIndex],
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const Text(
            'CRM \u2014 Bircon, Hifri',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: GestureDetector(
            onTap: () => notifier.refresh(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 19),
            ),
          ),
        ),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: UserAvatar(initials: 'A', onTap: () => showProfileSheet(context, _profileData)),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
      ),
    );
  }
}

final _profileData = ProfileSheetData(
  name: 'Admin',
  initials: 'A',
  roleLabel: 'Admin',
  roleBadge: 'Super Admin \u2022 CRM',
);

class _HamburgerLine extends StatelessWidget {
  final double width;
  final bool faded;
  const _HamburgerLine({required this.width, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: width,
      decoration: BoxDecoration(color: faded ? Colors.white70 : Colors.white, borderRadius: BorderRadius.circular(1)),
    );
  }
}
