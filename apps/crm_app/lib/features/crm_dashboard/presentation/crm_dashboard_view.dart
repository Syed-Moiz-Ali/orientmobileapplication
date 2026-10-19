import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_drawer.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_dashboard_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_conversations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_reports_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_integrations_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_settings_page.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/lead_detail_sheet.dart';
import 'package:crm_app/l10n/gen/crm_localizations.dart';

class CrmDashboardView extends ConsumerWidget {
  const CrmDashboardView({super.key});

  static List<AppNavItem> _navItems(CrmLocalizations t) => [
    AppNavItem(
      selectedIcon: Icons.dashboard_rounded,
      icon: Icons.dashboard_outlined,
      label: t.navDashboard,
    ),
    AppNavItem(
      selectedIcon: Icons.person_search_rounded,
      icon: Icons.person_search_outlined,
      label: t.navLeads,
    ),
    AppNavItem(
      selectedIcon: Icons.chat_bubble_rounded,
      icon: Icons.chat_bubble_outline_rounded,
      label: t.navConversations,
    ),
    AppNavItem(
      selectedIcon: Icons.groups_rounded,
      icon: Icons.groups_outlined,
      label: t.navSalesTeam,
    ),
    AppNavItem(
      selectedIcon: Icons.task_alt_rounded,
      icon: Icons.task_outlined,
      label: t.navTasks,
    ),
    AppNavItem(
      selectedIcon: Icons.bar_chart_rounded,
      icon: Icons.bar_chart_outlined,
      label: t.navReports,
    ),
    AppNavItem(
      selectedIcon: Icons.power_rounded,
      icon: Icons.power_outlined,
      label: t.navIntegrations,
    ),
    AppNavItem(
      selectedIcon: Icons.settings_rounded,
      icon: Icons.settings_outlined,
      label: t.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final notifier = ref.read(crmUiProvider.notifier);
    final state = ref.watch(crmUiProvider);
    final adaptive = context.adaptive;
    final leadCount = ref.watch(crmLeadProvider).length;

    final pages = <Widget>[
      const CrmDashboardPage(),
      const CrmLeadsPage(),
      const CrmConversationsPage(),
      const CrmSalesTeamPage(),
      const CrmTasksPage(),
      const CrmReportsPage(),
      const CrmIntegrationsPage(),
      const CrmSettingsPage(),
    ];

    return WorkspaceSearchShortcuts(
      onSearch: () => _openSearch(context, ref),
      child: DashboardShell(
        // The pill owns offline state; the banner stays off to avoid double
        // chrome.
        showOfflineBanner: false,
        appBar: _CrmChrome(selectedIndex: state.selectedIndex),
        drawer: !adaptive.useNavigationRail
            ? CrmDrawer(notifier: notifier)
            : null,
        body: AppAdaptiveNavigationFrame(
          items: _navItems(t),
          selectedIndex: state.selectedIndex,
          onSelected: notifier.selectTab,
          badgeCounts: leadCount > 0 ? {1: leadCount} : const <int, int>{},
          headerBuilder: (ctx, ext) => OrientBrandMark(
            workspace: t.shellCrm,
            compact: !ext,
          ),
          footerBuilder: (ctx, ext) => InkWell(
            onTap: () => notifier.selectTab(7),
            borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ext ? AppDimensions.s8 : 0,
                vertical: AppDimensions.s4,
              ),
              child: ext
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                          child: Text(
                            t.shellAdminBadge.substring(0, 1),
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s10),
                        Expanded(
                          child: Text(
                            t.chromeSettings,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(ctx).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Tooltip(
                      message: t.chromeSettings,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.14),
                        child: Text(
                          t.shellAdminBadge.substring(0, 1),
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          child: IndexedStack(index: state.selectedIndex, children: pages),
        ),
      ),
    );
  }
}

/// Omnichannel search over live leads: typing filters, picking a lead jumps
/// to the Leads tab and opens its dossier. No mock entries — every command
/// is a real lead from the provider.
Future<void> _openSearch(BuildContext context, WidgetRef ref) async {
  final t = context.cx;
  final leads = ref.read(crmLeadProvider);
  final notifier = ref.read(crmUiProvider.notifier);
  await showAppCommandPalette(
    context: context,
    hint: t.chromeSearchHint,
    commands: [
      for (final lead in leads.take(50))
        AppCommand(
          id: lead.id,
          label: lead.customerName.isEmpty ? lead.leadNumber : lead.customerName,
          hint: lead.leadNumber,
          icon: Icons.person_search_rounded,
          onSelected: () {
            notifier.selectTab(1);
          },
        ),
    ],
    onSelected: (command) {
      final lead = leads.where((l) => l.id == command.id).firstOrNull;
      notifier.selectTab(1);
      if (lead != null && context.mounted) {
        LeadDetailSheet.show(context, lead);
      }
    },
  );
}

/// Phase 07.1 centralized chrome: the bespoke `CrmAppBar` is deleted — tab
/// titles, workspace subtitle, rail/drawer leading, search trigger, offline
/// pill and the refresh / notification / profile actions now compose the
/// shared [WorkspaceAppBar] with identical behavior.
class _CrmChrome extends ConsumerWidget implements PreferredSizeWidget {
  final int selectedIndex;

  const _CrmChrome({required this.selectedIndex});

  static List<String> _titles(CrmLocalizations t) => [
    t.shellWorkspace,
    t.navLeads,
    t.navConversations,
    t.navSalesTeam,
    t.navTasks,
    t.navReports,
    t.navIntegrations,
    t.navSettings,
  ];

  @override
  Size get preferredSize => const Size.fromHeight(57);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.cx;
    final colors = Theme.of(context).colorScheme;
    final notifier = ref.read(crmUiProvider.notifier);
    final adaptive = context.adaptive;
    final useRail = adaptive.useNavigationRail;
    return WorkspaceAppBar(
      title: _titles(t)[selectedIndex],
      subtitle: '${t.shellSubtitle} · ${t.shellBranchName}',
      toolbarHeight: 56,
      // Frosted glass on desktop; the bar falls back to a solid surface
      // where translucency is reduced.
      frosted: !adaptive.isCompact,
      showOfflineStatus: true,
      onSearch: () => _openSearch(context, ref),
      // The kbd hint only fits non-compact bars.
      searchShortcutLabel: adaptive.isCompact ? null : t.chromeShortcut,
      leading: useRail
          ? Icon(Icons.hub_outlined, color: colors.primary)
          : Builder(
              builder: (scaffoldContext) => IconButton(
                tooltip: t.chromeOpenNav,
                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                icon: const Icon(Icons.menu_rounded),
              ),
            ),
      actions: [
        // Pull-to-refresh covers compact screens; the bar keeps search,
        // offline, bell and avatar within 320px at 1.3x.
        if (!adaptive.isCompact)
          IconButton(
            tooltip: t.chromeRefresh,
            onPressed: notifier.refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        const NotificationBell(),
        Padding(
          padding: const EdgeInsets.only(right: AppDimensions.s12),
          child: UserAvatar(
            initials: t.shellAdminBadge.substring(0, 1),
            onTap: () => showProfileSheet(
              context,
              ProfileSheetData(
                name: t.shellAdminName,
                initials: t.shellAdminBadge.substring(0, 1),
                roleLabel: t.shellAdminRole,
                roleBadge: t.shellAdminBadge,
                branch: t.shellBranchName,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
