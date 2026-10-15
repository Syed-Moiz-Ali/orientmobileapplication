import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_grid.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  const kpis = <OwnerKpi>[
    OwnerKpi(
      label: 'Active jobs',
      value: '24',
      icon: Icons.build_circle_outlined,
      state: KpiSemanticState.info,
      sub: '6 due today',
    ),
    OwnerKpi(
      label: 'Revenue',
      value: 'AED 84K',
      icon: Icons.payments_outlined,
      state: KpiSemanticState.success,
      sub: 'This month',
    ),
    OwnerKpi(
      label: 'Receivables',
      value: 'AED 19K',
      icon: Icons.receipt_long_outlined,
      state: KpiSemanticState.warning,
      sub: '8 outstanding',
    ),
    OwnerKpi(
      label: 'Approvals',
      value: '7',
      icon: Icons.fact_check_outlined,
      state: KpiSemanticState.info,
      sub: 'Needs attention',
    ),
  ];

  for (final size in <Size>[
    const Size(320, 720),
    const Size(390, 844),
    const Size(800, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('owner KPI grid is overflow-free at ${size.width}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: KpiGrid(kpis: kpis),
            ),
          ),
        ),
      );

      expect(find.byType(AppKpiCard), findsNWidgets(kpis.length));
      expect(tester.takeException(), isNull);
    });
  }
}
