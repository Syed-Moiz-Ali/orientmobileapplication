import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/features/customer/presentation/widgets/vehicle_health_gauge_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('health gauge renders the real score, not a hardcoded 92%',
      (tester) async {
    await tester.pumpWidget(wrap(const VehicleHealthGaugeCard(
      vehicleName: 'Toyota Camry',
      plateNumber: 'ABC-123',
      mileage: '42500',
      healthScore: 68,
      nextServiceDue: '12 Sep 2026',
    )));

    expect(find.text('Toyota Camry · Health Score'), findsOneWidget);
    expect(find.text('68% ATTENTION'), findsOneWidget);
    expect(find.text('92% GOOD'), findsNothing, reason: 'fabricated score');
    expect(find.textContaining('Next service due'), findsOneWidget);
  });

  testWidgets('health gauge shows critical band for low scores',
      (tester) async {
    await tester.pumpWidget(wrap(const VehicleHealthGaugeCard(
      vehicleName: 'Nissan Patrol',
      plateNumber: 'XYZ-999',
      healthScore: 30,
    )));

    expect(find.text('30% CRITICAL'), findsOneWidget);
  });

  testWidgets('health gauge shows honest empty state without a due date',
      (tester) async {
    await tester.pumpWidget(wrap(const VehicleHealthGaugeCard(
      vehicleName: 'Honda Civic',
      plateNumber: 'DEF-456',
      healthScore: 95,
    )));

    expect(find.text('95% GOOD'), findsOneWidget);
    expect(find.text('No service due date on record'), findsOneWidget);
  });
}
