import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owner_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_card.dart';
import 'package:owner_app/features/dashboard/presentation/widgets/kpi_grid.dart';

void main() {
  const kpis = <OwnerKpi>[
    OwnerKpi(
      label: 'Active jobs',
      value: '24',
      icon: Icons.build_circle_outlined,
      color: Color(0xFF167C80),
      sub: '6 due today',
    ),
    OwnerKpi(
      label: 'Revenue',
      value: 'AED 84K',
      icon: Icons.payments_outlined,
      color: Color(0xFF1A8754),
      sub: 'This month',
    ),
    OwnerKpi(
      label: 'Receivables',
      value: 'AED 19K',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFB7791F),
      sub: '8 outstanding',
    ),
    OwnerKpi(
      label: 'Approvals',
      value: '7',
      icon: Icons.fact_check_outlined,
      color: Color(0xFF6746B8),
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

      expect(find.byType(KpiCard), findsNWidgets(kpis.length));
      expect(tester.takeException(), isNull);
    });
  }
}
