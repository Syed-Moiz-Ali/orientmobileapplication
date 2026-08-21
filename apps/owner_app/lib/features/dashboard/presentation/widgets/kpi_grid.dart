import 'package:flutter/material.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:shared_core/shared_core.dart';

class KpiGrid extends StatelessWidget {
  final List<OwnerKpi> kpis;
  const KpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    final adaptive = context.adaptive;
    final columns = adaptive.isSmallMobile
        ? 1
        : adaptive.pick(compact: 2, medium: 2, expanded: 4, large: 4);

    return AppAdaptiveGrid(
      columns: columns,
      minChildWidth: adaptive.isCompact ? 142 : 210,
      spacing: adaptive.itemSpacing,
      runSpacing: adaptive.itemSpacing,
      childAspectRatio: adaptive.isSmallMobile
          ? 2.65
          : adaptive.pick(
              compact: 1.35,
              medium: 1.8,
              expanded: 2.1,
              large: 2.2,
            ),
      children: [for (final kpi in kpis) KpiCard(kpi: kpi)],
    );
  }
}
