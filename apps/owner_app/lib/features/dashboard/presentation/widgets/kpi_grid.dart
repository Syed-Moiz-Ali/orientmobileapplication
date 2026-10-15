import 'package:flutter/material.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:shared_core/shared_core.dart';

/// Phase 07.1: the bespoke `KpiCard` is deleted — tiles compose the shared
/// [AppKpiCard] (same label/value/icon; the old success sub-chip maps to the
/// shared trend slot; tint resolves from the entity's semantic state).
class KpiGrid extends StatelessWidget {
  final List<OwnerKpi> kpis;
  const KpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final columns = adaptive.isSmallMobile
        ? 1
        : adaptive.pick(compact: 2, medium: 2, expanded: 4, large: 4);

    // Phase 01 (scale-lock removal): tiles grow with the system text scale so
    // the label/value stack never clips at 1.3x+ (frozen KPI behavior — same
    // rule as the Phase 00 prototype and shared AppKpiCard). At 1.0x the
    // layout is byte-identical to the shipped dashboard.
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final baseAspectRatio = adaptive.isSmallMobile
        ? 2.15
        : adaptive.pick(compact: 1.35, medium: 1.8, expanded: 2.1, large: 2.2);

    return AppAdaptiveGrid(
      columns: columns,
      minChildWidth: adaptive.isCompact ? 142 : 210,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: baseAspectRatio / textScale,
      children: [
        for (final kpi in kpis)
          AppKpiCard(
            label: kpi.label,
            value: kpi.value,
            icon: kpi.icon,
            semanticState: kpi.state,
            trend: kpi.sub.isEmpty
                ? null
                : KpiTrend(label: kpi.sub, isPositive: true),
          ),
      ],
    );
  }
}
