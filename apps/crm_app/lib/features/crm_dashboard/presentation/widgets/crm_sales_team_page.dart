import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';

class CrmSalesTeamPage extends ConsumerWidget {
  const CrmSalesTeamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.read(crmUiProvider.notifier);
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.s16),
      itemCount: ui.salesTeam.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.s12),
      itemBuilder: (_, i) {
        final m = ui.salesTeam[i];
        return Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.r16),
            border: Border.all(color: CrmColors.border),
            boxShadow: [
              BoxShadow(
                color: CrmColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [CrmColors.gStart, CrmColors.gEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        m.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.name,
                        style: const TextStyle(
                          color: CrmColors.textH,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        m.role,
                        style: const TextStyle(
                          color: CrmColors.textM,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    m.revenue,
                    style: const TextStyle(
                      color: CrmColors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s14),
              Row(
                children: [
                  _statPill('Leads', '${m.leadsHandled}', CrmColors.accent),
                  const SizedBox(width: AppDimensions.s8),
                  _statPill('Won', '${m.wonDeals}', CrmColors.green),
                  const SizedBox(width: AppDimensions.s8),
                  _statPill(
                    'Win Rate',
                    '${(m.winRate * 100).round()}%',
                    CrmColors.purple,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s12),
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(AppDimensions.r4)),
                child: LinearProgressIndicator(
                  value: m.winRate,
                  backgroundColor: CrmColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(CrmColors.accent),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.s8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimensions.r10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: CrmColors.textM, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
