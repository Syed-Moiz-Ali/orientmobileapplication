import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_ui_provider.dart';

class CrmSettingsPage extends ConsumerWidget {
  const CrmSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);

    final items = [
      (
        'Push Notifications',
        'Receive alerts for new leads and messages',
        Icons.notifications_outlined,
        ui.notificationsEnabled,
        ui.toggleNotifications,
      ),
      (
        'Dark Mode',
        'Use dark theme across the application',
        Icons.dark_mode_outlined,
        ui.darkMode,
        ui.toggleDarkMode,
      ),
      (
        'Auto Assign Leads',
        'Automatically assign incoming leads to team',
        Icons.auto_awesome_outlined,
        ui.autoAssign,
        ui.toggleAutoAssign,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Settings'),
          const SizedBox(height: AppDimensions.s16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.s10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.r14),
                  border: Border.all(color: CrmColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: CrmColors.primary.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: CrmColors.accentLight,
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                      child: Icon(item.$3, color: CrmColors.accent, size: 20),
                    ),
                    const SizedBox(width: AppDimensions.s14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$1,
                            style: const TextStyle(
                              color: CrmColors.textH,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item.$2,
                            style: const TextStyle(
                              color: CrmColors.textM,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: item.$4,
                      onChanged: (_) => item.$5(),
                      activeThumbColor: CrmColors.accent,
                      activeTrackColor: CrmColors.accentLight,
                      inactiveThumbColor: CrmColors.textM,
                      inactiveTrackColor: CrmColors.border,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: CrmColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: AppDimensions.s10),
      Text(
        text,
        style: const TextStyle(
          color: CrmColors.textH,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}
