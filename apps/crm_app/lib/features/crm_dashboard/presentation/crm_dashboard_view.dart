import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_task_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/support/crm_l10n.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_leads_search_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_sales_team_search_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_tasks_search_sheet.dart';
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

/// Ruling (a) contextual list search (presentation/flow-wiring only):
/// the shell AppBar trigger opens the tab's EXISTING list-scoped sheet
/// (same widget, same provider predicate, same routes — no logic, no data,
/// no predicate changes). Leads goes straight to the dossier (the same
/// `LeadDetailSheet.show` the kanban/palette paths use): the compact
/// list-mode scroll-reveal needs the page's scroll anchors (page-owned
/// presentation state), so the shell path skips the extra record tap
/// (≤ taps, no regression). Tasks/team STOP (see below): no dossier route
/// exists and the scroll-reveal needs the page's scroll anchors, so the
/// shell `onSelect` only re-selects the tab (existing route, no-op when
/// already there) — the sheet already popped; manual scroll is unchanged.
/// Same sheets, same ≤ budgets.
Future<void> _openLeadsSearch(BuildContext context, WidgetRef ref) async {
  final leads = ref.read(crmLeadProvider);
  await showCrmLeadsSearchSheet(
    context,
    leads: leads,
    onSelect: (lead) {
      if (context.mounted) LeadDetailSheet.show(context, lead);
    },
  );
}

Future<void> _openTasksSearch(BuildContext context, WidgetRef ref) async {
  final tasks = ref.read(crmTaskProvider).tasks;
  final notifier = ref.read(crmUiProvider.notifier);
  await showCrmTasksSearchSheet(
    context,
    tasks: tasks,
    onSelect: (_) => notifier.selectTab(4),
  );
}

Future<void> _openTeamSearch(BuildContext context, WidgetRef ref) async {
  final team = ref.read(crmUiProvider.notifier).salesTeam;
  final notifier = ref.read(crmUiProvider.notifier);
  await showCrmSalesTeamSearchSheet(
    context,
    team: team,
    onSelect: (_) => notifier.selectTab(3),
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
      // Ruling (a) single-path (presentation/flow-wiring only): the shell
      // search trigger is the SINGLE visible icon on the leads (1), sales
      // team (3) and tasks (4) tabs — contextual per tab, opening the tab's
      // EXISTING list search sheet (leads/tasks/team sheets from F8),
      // gated by the same >5 loaded condition relocated from the list
      // headers (same predicates: raw loaded counts, no logic change).
      // List page headers show no search icon (filter + Add stay where
      // they are). Non-list tabs keep the shell palette
      // (jump-to-dossier over the first 50) untouched. The Ctrl+K shortcut
      // above stays wired to the palette on all tabs — only the visible
      // trigger is contextual.
      final leadsCount = ref.watch(crmLeadProvider).length;
      final tasksCount = ref.watch(crmTaskProvider).tasks.length;
      // R1 (stale-gate fix, presentation wiring only): the gate reads the
      // SAME list object the team page renders
      // (`crm_sales_team_page.dart`: `ref.read(crmUiProvider.notifier).salesTeam`),
      // not a separate `crmRepositoryProvider` watch — same provider/selector,
      // same >5 predicate, no logic/data change.
      final teamCount = ref.watch(crmUiProvider.notifier).salesTeam.length;
      final VoidCallback? contextualSearch;
      if (selectedIndex == 1) {
        contextualSearch = leadsCount > 5 ? () => _openLeadsSearch(context, ref) : null;
      } else if (selectedIndex == 3) {
        contextualSearch = teamCount > 5 ? () => _openTeamSearch(context, ref) : null;
      } else if (selectedIndex == 4) {
        contextualSearch = tasksCount > 5 ? () => _openTasksSearch(context, ref) : null;
      } else {
        contextualSearch = () => _openSearch(context, ref);
      }
      return WorkspaceAppBar(
        title: _titles(t)[selectedIndex],
        subtitle: '${t.shellSubtitle} · ${t.shellBranchName}',
        toolbarHeight: 56,
        // Frosted glass on desktop; the bar falls back to a solid surface
        // where translucency is reduced.
        frosted: !adaptive.isCompact,
        showOfflineStatus: true,
        onSearch: contextualSearch,
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
