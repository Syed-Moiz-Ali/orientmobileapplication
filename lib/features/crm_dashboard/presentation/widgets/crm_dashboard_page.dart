import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_header_banner.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_channel_widgets.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_kpi_card.dart';
import 'package:orientmobileapplication/features/crm_dashboard/presentation/widgets/crm_recent_leads.dart';

class CrmDashboardPage extends ConsumerWidget {
  const CrmDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);
    final leads = ref.watch(crmLeadProvider);

    if (ui.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CrmColors.accent, strokeWidth: 2.5),
      );
    }

    return RefreshIndicator(
      onRefresh: ui.refresh,
      color: CrmColors.accent,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CrmHeaderBanner(),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('KPI Overview'),
                  const SizedBox(height: AppDimensions.s12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: ui.kpis.length,
                    itemBuilder: (_, i) => CrmKpiCard(kpi: ui.kpis[i]),
                  ),
                  const SizedBox(height: 2),
                  _sectionLabel('Incoming Messages Breakdown'),
                  const SizedBox(height: AppDimensions.s12),
                  CrmChannelGrid(channels: ui.channels),
                  const SizedBox(height: 2),
                  _sectionLabel('Recent Leads'),
                  const SizedBox(height: AppDimensions.s12),
                  CrmRecentLeadsCard(leads: leads.take(5).toList()),
                ],
              ),
            ),
          ],
        ),
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
