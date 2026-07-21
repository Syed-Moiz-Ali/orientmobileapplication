import 'package:flutter/material.dart';
import 'package:orientmobileapplication/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:orientmobileapplication/features/supervisor/presentation/widgets/supervisor_stat_card.dart';

class SupervisorStatsGrid extends StatelessWidget {
  final List<SupervisorKpiEntity> kpis;
  const SupervisorStatsGrid({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kpis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SupervisorStatCard(kpi: kpis[i]),
      ),
    );
  }
}
