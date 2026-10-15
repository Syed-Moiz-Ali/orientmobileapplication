import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';

/// Phase 07.1: the bespoke `SupervisorStatCard` is deleted — tiles compose
/// the shared [AppKpiCard] (same label/value/icon; sub maps to the shared
/// trend slot; tint resolves from the entity's semantic state).
class SupervisorStatsGrid extends StatelessWidget {
  final List<SupervisorKpiEntity> kpis;
  const SupervisorStatsGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kpis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final kpi = kpis[i];
          return SizedBox(
            width: 172,
            child: AppKpiCard(
              label: kpi.label,
              value: kpi.value,
              icon: kpi.icon,
              semanticState: kpi.state,
              trend: kpi.sub.isEmpty
                  ? null
                  : KpiTrend(label: kpi.sub, isPositive: true),
            ),
          );
        },
      ),
    );
  }
}
