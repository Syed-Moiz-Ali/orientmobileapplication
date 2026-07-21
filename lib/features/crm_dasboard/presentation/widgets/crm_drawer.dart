import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_lead_provider.dart';
import 'package:orientmobileapplication/features/crm_dasboard/presentation/providers/crm_ui_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrmDrawer extends ConsumerWidget {
  final CrmUiNotifier notifier;
  const CrmDrawer({super.key, required this.notifier});

  static const _items = [
    (Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    (Icons.person_search_rounded, Icons.person_search_outlined, 'Leads'),
    (
      Icons.chat_bubble_rounded,
      Icons.chat_bubble_outline_rounded,
      'Conversations',
    ),
    (Icons.groups_rounded, Icons.groups_outlined, 'Sales Team'),
    (Icons.task_alt_rounded, Icons.task_outlined, 'Tasks'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Reports & Analytics'),
    (Icons.power_rounded, Icons.power_outlined, 'Integrations'),
    (Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(crmLeadProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [CrmColors.gStart, CrmColors.gEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.r14),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CRM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const Text(
                      'DASHBOARD',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final sel = notifier.selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: () {
                      notifier.selectTab(i);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? CrmColors.accentLight : Colors.transparent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.r12),
                        ),
                        border: Border.all(
                          color: sel
                              ? CrmColors.accent.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            sel ? _items[i].$1 : _items[i].$2,
                            color: sel ? CrmColors.accent : CrmColors.textM,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _items[i].$3,
                            style: TextStyle(
                              color: sel ? CrmColors.accent : CrmColors.textB,
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          if (i == 1) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: CrmColors.accentLight,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(AppDimensions.r10),
                                ),
                              ),
                              child: Text(
                                '${leads.length}',
                                style: const TextStyle(
                                  color: CrmColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: CrmColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [CrmColors.gStart, CrmColors.gEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin',
                      style: TextStyle(
                        color: CrmColors.textH,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Super Admin',
                      style: TextStyle(color: CrmColors.textM, fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.logout_rounded,
                  color: CrmColors.red.withValues(alpha: 0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
