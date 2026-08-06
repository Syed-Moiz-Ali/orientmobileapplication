import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_lead_provider.dart';

class CrmHeaderBanner extends ConsumerWidget {
  const CrmHeaderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(crmLeadProvider);
    final wonLeads = leads.where((l) => l.status == 'WON').length;
    return GradientBanner(
      title: 'CRM Dashboard',
      liveDotColor: CrmColors.liveDot,
      gradient: const LinearGradient(
        colors: [CrmColors.gStart, CrmColors.gEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      pills: [
        GradientBannerPill(icon: Icons.person_search_rounded, label: '${leads.length} Leads', accent: CrmColors.amberPill),
        // FIX (audit P0): '1,247 Messages' was a fabricated constant — no
        // conversation data exists yet; show the real won-lead count instead.
        GradientBannerPill(icon: Icons.task_alt_rounded, label: '$wonLeads Won', accent: CrmColors.liveDot),
      ],
      icon: Icons.hub_rounded,
    );
  }
}
