import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 04 rendered-review gallery: a representative role shell built from the
/// shared shell/navigation components (`WorkspaceAppBar`, `AppAdaptiveNavigation
/// Frame`, `AppNavigationRail`, `AppBottomNavigation`, `AppNavDrawer`,
/// `AppBreadcrumbs`, `AppMasterDetailScaffold`), plus a master–detail sample.
///
/// Real workshop fixtures only; no placeholder text.
class Phase04Shell extends StatelessWidget {
  final String workspace;
  final String title;
  final String subtitle;
  final String brandInitial;
  final List<AppNavItem> items;
  final int selectedIndex;
  final List<AppBreadcrumbItem>? breadcrumbs;

  const Phase04Shell({
    super.key,
    required this.workspace,
    required this.title,
    required this.subtitle,
    required this.items,
    this.brandInitial = 'O',
    this.selectedIndex = 0,
    this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final useRail = context.adaptive.useNavigationRail;

    return Scaffold(
      appBar: WorkspaceAppBar(
        title: title,
        subtitle: subtitle,
        actions: const [
          NotificationBell(showBadge: true, badgeCount: 3),
          SizedBox(width: AppDimensions.s8),
        ],
      ),
      body: AppAdaptiveNavigationFrame(
        items: items,
        selectedIndex: selectedIndex,
        onSelected: (_) {},
        headerBuilder: (ctx, ext) =>
            OrientBrandMark(workspace: workspace, compact: !ext),
        footerBuilder: (ctx, ext) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ext ? AppDimensions.s8 : 0,
            vertical: AppDimensions.s4,
          ),
          child: CircleAvatar(
            radius: ext ? 16 : 18,
            backgroundColor: Theme.of(
              ctx,
            ).colorScheme.primary.withValues(alpha: 0.14),
            child: Text(
              brandInitial,
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        child: AppResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                breadcrumbs: breadcrumbs,
                eyebrow: '$workspace workspace',
                title: 'Today',
                subtitle: 'Priority work and recent activity in one calm view.',
                primaryAction: AppButton.primary(
                  label: 'New job card',
                  isExpanded: false,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: AppDimensions.s20),
              const AppRecordRow(
                identifier: 'JOB-4091',
                title: 'Mercedes-Benz E300',
                subtitle: 'Major 60,000 km service',
                status: StatusPill.inProgress('In progress'),
                onTap: _noop,
              ),
              const SizedBox(height: AppDimensions.s12),
              const AppRecordRow(
                identifier: 'JOB-4092',
                title: 'Toyota Camry 2022',
                subtitle: 'Brake pad replacement',
                status: StatusPill.warning('Waiting parts'),
                metadata: PendingSyncChip(state: SyncChipState.notSent),
                onTap: _noop,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: useRail
          ? null
          : AppBottomNavigation(
              items: items,
              selectedIndex: selectedIndex,
              onSelected: (_) {},
            ),
    );
  }
}

/// Master (list) + detail panes for the tablet/desktop master–detail template.
class Phase04MasterDetail extends StatelessWidget {
  const Phase04MasterDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppMasterDetailScaffold(
        master: ListView(
          padding: const EdgeInsets.all(AppDimensions.s8),
          children: const [
            AppRecordRow(
              identifier: 'JOB-4091',
              title: 'Mercedes-Benz E300',
              subtitle: 'Major 60,000 km service',
              status: StatusPill.inProgress('In progress'),
            ),
            SizedBox(height: 8),
            AppRecordRow(
              identifier: 'JOB-4092',
              title: 'Toyota Camry 2022',
              subtitle: 'Brake pad replacement',
              status: StatusPill.warning('Waiting parts'),
            ),
            SizedBox(height: 8),
            AppRecordRow(
              identifier: 'JOB-4093',
              title: 'Nissan Patrol 2021',
              subtitle: 'Air-conditioning recharge',
              status: StatusPill.success('Completed'),
            ),
          ],
        ),
        detail: AppResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              AppPageHeader(
                breadcrumbs: [
                  AppBreadcrumbItem(label: 'Job cards'),
                  AppBreadcrumbItem.current('JOB-4091'),
                ],
                eyebrow: 'Job card',
                title: 'Mercedes-Benz E300',
                subtitle: 'A 12345 · Major 60,000 km service',
              ),
              SizedBox(height: AppDimensions.s18),
              AppInfoPanel.primary(
                title: 'Assigned to Moiz Ali',
                message: 'Bay 03 · Estimated completion 16:30.',
              ),
              SizedBox(height: AppDimensions.s12),
              AppLinearProgress(
                value: 0.65,
                label: 'Inspection checklist',
                showPercentage: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phase 04 refinement showcase: the frosted-glass workspace header with the
/// integrated offline telemetry pill and the omnichannel ⌘K search trigger,
/// rendered over scrolling content so the frosted readability is visible.
class Phase04RefinedShell extends StatelessWidget {
  const Phase04RefinedShell({super.key, this.pendingSyncCount = 0});

  final int pendingSyncCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: WorkspaceAppBar(
        title: 'Today',
        subtitle: 'Workshop Advisor',
        frosted: true,
        showOfflineStatus: true,
        offlinePendingCount: pendingSyncCount,
        onSearch: _noop,
        actions: const [
          NotificationBell(showBadge: true, badgeCount: 3),
          SizedBox(width: AppDimensions.s8),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
              ),
            ),
            padding: EdgeInsets.only(
              top: topInset + 96,
              left: AppDimensions.s20,
              right: AppDimensions.s20,
            ),
            child: Text(
              'Workshop floor · Live',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                AppRecordRow(
                  identifier: 'JOB-4091',
                  title: 'Mercedes-Benz E300',
                  subtitle: 'Major 60,000 km service',
                  status: StatusPill.inProgress('In progress'),
                ),
                SizedBox(height: AppDimensions.s12),
                AppRecordRow(
                  identifier: 'JOB-4092',
                  title: 'Toyota Camry 2022',
                  subtitle: 'Brake pad replacement',
                  status: StatusPill.warning('Waiting parts'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        items: kStaffNav,
        selectedIndex: 0,
        onSelected: _noopSelect,
      ),
    );
  }
}

void _noopSelect(int _) {}

const kCustomerNav = <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.home_rounded,
    icon: Icons.home_outlined,
    label: 'Home',
  ),
  AppNavItem(
    selectedIcon: Icons.calendar_month_rounded,
    icon: Icons.calendar_month_outlined,
    label: 'Bookings',
  ),
  AppNavItem(
    selectedIcon: Icons.directions_car_rounded,
    icon: Icons.directions_car_outlined,
    label: 'Vehicles',
  ),
  AppNavItem(
    selectedIcon: Icons.person_rounded,
    icon: Icons.person_outline_rounded,
    label: 'Profile',
  ),
];

const kStaffNav = <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.dashboard_rounded,
    icon: Icons.dashboard_outlined,
    label: 'Today',
  ),
  AppNavItem(
    selectedIcon: Icons.receipt_long_rounded,
    icon: Icons.receipt_long_outlined,
    label: 'Jobs',
  ),
  AppNavItem(
    selectedIcon: Icons.bar_chart_rounded,
    icon: Icons.bar_chart_outlined,
    label: 'Reports',
  ),
];

const kCrmNav = <AppNavItem>[
  AppNavItem(
    selectedIcon: Icons.dashboard_rounded,
    icon: Icons.dashboard_outlined,
    label: 'Dashboard',
  ),
  AppNavItem(
    selectedIcon: Icons.person_search_rounded,
    icon: Icons.person_search_outlined,
    label: 'Leads',
  ),
  AppNavItem(
    selectedIcon: Icons.chat_bubble_rounded,
    icon: Icons.chat_bubble_outline_rounded,
    label: 'Conversations',
  ),
  AppNavItem(
    selectedIcon: Icons.groups_rounded,
    icon: Icons.groups_outlined,
    label: 'Sales Team',
  ),
  AppNavItem(
    selectedIcon: Icons.task_alt_rounded,
    icon: Icons.task_outlined,
    label: 'Tasks',
  ),
  AppNavItem(
    selectedIcon: Icons.bar_chart_rounded,
    icon: Icons.bar_chart_outlined,
    label: 'Reports',
  ),
];

void _noop() {}
