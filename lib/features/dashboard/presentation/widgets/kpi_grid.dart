import 'package:flutter/material.dart';
import 'package:orientmobileapplication/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:orientmobileapplication/features/dashboard/presentation/widgets/kpi_card.dart';

class KpiGrid extends StatelessWidget {
  final List<OwnerKpi> kpis;
  const KpiGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) => KpiCard(kpi: kpis[i]),
    );
  }
}
