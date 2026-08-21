import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_analytics_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_activity_feed_widget.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_followups_widget.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_pipeline_widget.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_header_banner.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_channel_widgets.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_kpi_card.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/crm_recent_leads.dart';

class CrmDashboardPage extends ConsumerWidget {
  const CrmDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);
    final leads = ref.watch(crmLeadProvider);
    final analytics = ref.watch(leadAnalyticsProvider);
    final integrations = ui.integrations;
    final anyConnected = integrations.any((i) => i.connected);

    if (ui.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: CrmColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    final hasData = leads.isNotEmpty || ui.channels.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await ui.refresh();
        await ref.read(leadAnalyticsProvider.notifier).refresh();
      },
      color: CrmColors.accent,
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CrmHeaderBanner(),
            if (!anyConnected)
              _connectBanner(context)
            else if (!hasData)
              _emptyBanner(context, ui.refresh),
            SizedBox(height: context.adaptive.sectionSpacing),
            _sectionLabel('Sales pulse'),
            const SizedBox(height: AppDimensions.s12),
            _kpiGrid(context, ui.kpis),
            SizedBox(height: context.adaptive.sectionSpacing),
            _sectionLabel('Attention queue'),
            const SizedBox(height: AppDimensions.s12),
            AppSplitView(
              primary: analytics.stats.total > 0
                  ? LeadPipelineWidget(stats: analytics.stats)
                  : _emptySection(
                      Icons.filter_alt_outlined,
                      'No pipeline data',
                      'Leads will build your pipeline here',
                    ),
              secondary: FollowUpsWidget(followUps: analytics.followUps),
              primaryFlex: 1.15,
            ),
            SizedBox(height: context.adaptive.sectionSpacing),
            AppSplitView(
              primary: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Channel performance'),
                  const SizedBox(height: AppDimensions.s12),
                  if (ui.channels.isEmpty)
                    _emptySection(
                      Icons.chat_bubble_outline_rounded,
                      'No channel data yet',
                      'Messages from connected platforms will appear here',
                    )
                  else
                    CrmChannelGrid(channels: ui.channels),
                ],
              ),
              secondary: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Recent activity'),
                  const SizedBox(height: AppDimensions.s12),
                  ActivityFeedWidget(feed: analytics.feed),
                ],
              ),
            ),
            SizedBox(height: context.adaptive.sectionSpacing),
            _sectionLabel('Recent leads'),
            const SizedBox(height: AppDimensions.s12),
            if (leads.isEmpty)
              _emptySection(
                Icons.people_outline_rounded,
                'No leads yet',
                anyConnected
                    ? 'Sync your connected CRM to fetch leads'
                    : 'Connect a CRM to start receiving leads',
              )
            else
              CrmRecentLeadsCard(leads: leads.take(5).toList()),
            const SizedBox(height: AppDimensions.s24),
          ],
        ),
      ),
    );
  }

  Widget _kpiGrid(BuildContext context, List<CrmKpiEntity> kpis) {
    final adaptive = context.adaptive;
    final columns = adaptive.isSmallMobile
        ? 1
        : adaptive.pick(compact: 2, medium: 2, expanded: 4, large: 4);
    return AppAdaptiveGrid(
      columns: columns,
      minChildWidth: adaptive.isCompact ? 142 : 190,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.isSmallMobile
          ? 2.65
          : adaptive.pick(
              compact: 1.35,
              medium: 1.75,
              expanded: 2.05,
              large: 2.15,
            ),
      children: [for (final kpi in kpis) CrmKpiCard(kpi: kpi)],
    );
  }

  Widget _connectBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.s16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CrmColors.primary, CrmColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.link_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No CRMs connected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Connect Meta or Zoho to see live leads here',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => ConnectIntegrationSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(
                  color: CrmColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBanner(BuildContext context, VoidCallback onSync) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.s16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CrmColors.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CrmColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sync_problem_rounded,
            color: CrmColors.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing leads...',
                  style: TextStyle(
                    color: CrmColors.textH,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your CRM is connected but no leads yet',
                  style: TextStyle(color: CrmColors.textM, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSync,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: CrmColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Sync Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySection(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CrmColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: CrmColors.textM),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: CrmColors.textH,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: CrmColors.textM, fontSize: 11),
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
