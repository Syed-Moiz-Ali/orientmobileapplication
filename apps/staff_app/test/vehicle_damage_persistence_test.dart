import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/presentation/pages/inspection_provider.dart';

void main() {
  const minor = VehicleDamageFinding(
    id: 'one',
    partId: 'front_left_door',
    damageType: VehicleDamageType.scratch,
    severity: VehicleDamageSeverity.minor,
    normalizedX: 0.28,
    normalizedY: 0.52,
  );
  const major = VehicleDamageFinding(
    id: 'two',
    partId: 'front_left_door',
    damageType: VehicleDamageType.dent,
    severity: VehicleDamageSeverity.major,
    normalizedX: 0.30,
    normalizedY: 0.55,
  );

  test('multiple findings persist and major condition wins', () {
    const part = VehiclePartInspection(
      partId: 'front_left_door',
      condition: VehiclePartCondition.good,
      findings: [minor, major],
    );
    expect(part.effectiveCondition, VehiclePartCondition.major);
    final restored = VehiclePartInspection.fromJson(part.toJson());
    expect(restored.findings, hasLength(2));
    expect(restored.findings.first.normalizedX, closeTo(0.28, 0.0001));
    expect(
      restored.copyWith(findings: const [minor]).effectiveCondition,
      VehiclePartCondition.minor,
    );
  });

  test('inspection draft restores body map and old drafts stay readable', () {
    const state = InspectionState(
      vehiclePartInspections: {
        'front_left_door': VehiclePartInspection(
          partId: 'front_left_door',
          findings: [minor],
        ),
      },
    );
    final restored = InspectionState.fromPersistableMap(
      state.toPersistableMap(),
    );
    expect(
      restored.vehiclePartInspections['front_left_door']?.findings,
      hasLength(1),
    );
    expect(
      InspectionState.fromPersistableMap(const {}).vehiclePartInspections,
      isEmpty,
    );
    expect(state.toLiveRequestMap()['vehicleBodyCondition'], isNotNull);
  });
}
