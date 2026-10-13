// Fixtures mirror the real inspection template
// (inspection_pages/data/models/inspection_model.dart: kInspectionSections)
// and the damage map model (vehicle_damage_map_model.dart). Part ids are the
// real ids from `advisor_car_top_mapping.json`, so the prototype map can
// hit-test against the production asset geometry.
enum FixtureItemStatus { good, fair, poor }

extension FixtureItemStatusX on FixtureItemStatus {
  String get labelKey => switch (this) {
        FixtureItemStatus.good => 'insp.item.good',
        FixtureItemStatus.fair => 'insp.item.fair',
        FixtureItemStatus.poor => 'insp.item.poor',
      };
}

enum FixtureDamageType {
  scratch,
  deepScratch,
  dent,
  paintChip,
  crack,
  repainted,
  faded,
  rust,
  broken,
  other,
}

extension FixtureDamageTypeX on FixtureDamageType {
  String get labelKey => 'insp.damage.${switch (this) {
        FixtureDamageType.scratch => 'scratch',
        FixtureDamageType.deepScratch => 'deepScratch',
        FixtureDamageType.dent => 'dent',
        FixtureDamageType.paintChip => 'paintChip',
        FixtureDamageType.crack => 'crack',
        FixtureDamageType.repainted => 'repainted',
        FixtureDamageType.faded => 'faded',
        FixtureDamageType.rust => 'rust',
        FixtureDamageType.broken => 'broken',
        FixtureDamageType.other => 'other',
      }}';
}

enum FixtureSeverity { minor, moderate, major }

extension FixtureSeverityX on FixtureSeverity {
  String get labelKey => switch (this) {
        FixtureSeverity.minor => 'insp.severity.minor',
        FixtureSeverity.moderate => 'insp.severity.moderate',
        FixtureSeverity.major => 'insp.severity.major',
      };

  String get colorKey => switch (this) {
        FixtureSeverity.minor => 'minor',
        FixtureSeverity.moderate => 'moderate',
        FixtureSeverity.major => 'major',
      };
}

enum FixtureActionRec { noAction, monitor, repair, repaint, replace }

extension FixtureActionRecX on FixtureActionRec {
  String get labelKey => switch (this) {
        FixtureActionRec.noAction => 'insp.actionRec.noAction',
        FixtureActionRec.monitor => 'insp.actionRec.monitor',
        FixtureActionRec.repair => 'insp.actionRec.repair',
        FixtureActionRec.repaint => 'insp.actionRec.repaint',
        FixtureActionRec.replace => 'insp.actionRec.replace',
      };
}

class InspectionSectionFixture {
  final String id;
  final String labelKey;
  final List<String> checkpointKeys; // string map keys, one per checkpoint

  const InspectionSectionFixture({
    required this.id,
    required this.labelKey,
    required this.checkpointKeys,
  });
}

/// Byte-for-byte the item order of `kInspectionSections` in production.
const List<InspectionSectionFixture> inspectionSections = [
  InspectionSectionFixture(
    id: 'interior',
    labelKey: 'insp.sec.interior',
    checkpointKeys: [
      'insp.ck.headlight',
      'insp.ck.wiper',
      'insp.ck.mirror',
      'insp.ck.handbrake',
      'insp.ck.horn',
      'insp.ck.fuelCap',
      'insp.ck.acFilter',
      'insp.ck.seatBelts',
      'insp.ck.dashLights',
      'insp.ck.clutch',
    ],
  ),
  InspectionSectionFixture(
    id: 'underVehicle',
    labelKey: 'insp.sec.underVehicle',
    checkpointKeys: [
      'insp.ck.shocks',
      'insp.ck.steering',
      'insp.ck.exhaust',
      'insp.ck.oilLeaks',
      'insp.ck.brakeLines',
      'insp.ck.uJoints',
      'insp.ck.fuelLines',
      'insp.ck.chassisBolts',
    ],
  ),
  InspectionSectionFixture(
    id: 'underHood',
    labelKey: 'insp.sec.underHood',
    checkpointKeys: [
      'insp.ck.fluidLevels',
      'insp.ck.airFilter',
      'insp.ck.driveBelts',
      'insp.ck.coolant',
      'insp.ck.hoses',
      'insp.ck.radiator',
    ],
  ),
  InspectionSectionFixture(
    id: 'battery',
    labelKey: 'insp.sec.battery',
    checkpointKeys: [
      'insp.ck.batteryTerminals',
      'insp.ck.batteryCapacity',
    ],
  ),
];

/// Checkpoint id used by ratings/media: `'<sectionId>_<index>'`.
String checkpointId(String sectionId, int index) => '${sectionId}_$index';

/// Partial review state: Interior 10/10 evaluated + 1 under-hood checkpoint.
const Map<String, FixtureItemStatus> partialRatings = {
  'interior_0': FixtureItemStatus.good,
  'interior_1': FixtureItemStatus.good,
  'interior_2': FixtureItemStatus.fair,
  'interior_3': FixtureItemStatus.good,
  'interior_4': FixtureItemStatus.good,
  'interior_5': FixtureItemStatus.good,
  'interior_6': FixtureItemStatus.good,
  'interior_7': FixtureItemStatus.good,
  'interior_8': FixtureItemStatus.poor,
  'interior_9': FixtureItemStatus.good,
  'underHood_1': FixtureItemStatus.good,
};

/// Complete review state: everything evaluated.
final Map<String, FixtureItemStatus> completeRatings = {
  for (final section in inspectionSections)
    for (var i = 0; i < section.checkpointKeys.length; i++)
      checkpointId(section.id, i): i == 8 ? FixtureItemStatus.poor : FixtureItemStatus.good,
};

class CheckpointMediaFixture {
  final int photos;
  final int notes;
  final bool audio;

  const CheckpointMediaFixture({this.photos = 0, this.notes = 0, this.audio = false});

  int get total => photos + notes + (audio ? 1 : 0);

  bool get hasMedia => total > 0;
}

/// Evidence already captured on a few checkpoints (partial state).
const Map<String, CheckpointMediaFixture> checkpointMedia = {
  'interior_0': CheckpointMediaFixture(photos: 2),
  'interior_2': CheckpointMediaFixture(notes: 1),
  'interior_8': CheckpointMediaFixture(photos: 1, notes: 1),
  'underHood_1': CheckpointMediaFixture(photos: 1),
};

class DamageFindingFixture {
  final String id;
  final String partId;
  final FixtureDamageType type;
  final FixtureSeverity severity;
  final String location;
  final String note;
  final FixtureActionRec action;
  final double nx;
  final double ny;

  const DamageFindingFixture({
    required this.id,
    required this.partId,
    required this.type,
    required this.severity,
    this.location = '',
    this.note = '',
    this.action = FixtureActionRec.noAction,
    required this.nx,
    required this.ny,
  });
}

/// Two real findings + one monitored chip, matching the partial state.
const List<DamageFindingFixture> damageFindings = [
  DamageFindingFixture(
    id: 'VDF-1',
    partId: 'front_left_door',
    type: FixtureDamageType.scratch,
    severity: FixtureSeverity.minor,
    location: 'Rear edge of the front-left door',
    note: 'Scratch below the handle; paint intact.',
    action: FixtureActionRec.repair,
    nx: 0.38,
    ny: 0.47,
  ),
  DamageFindingFixture(
    id: 'VDF-2',
    partId: 'rear_right_quarter',
    type: FixtureDamageType.dent,
    severity: FixtureSeverity.major,
    location: 'Above the rear-right wheel arch',
    note: 'Dent with paint cracking; panel work required.',
    action: FixtureActionRec.repair,
    nx: 0.72,
    ny: 0.80,
  ),
  DamageFindingFixture(
    id: 'VDF-3',
    partId: 'front_bumper',
    type: FixtureDamageType.paintChip,
    severity: FixtureSeverity.minor,
    location: 'Lower lip, front centre',
    action: FixtureActionRec.monitor,
    nx: 0.50,
    ny: 0.10,
  ),
];

/// Body-map condition of each part in the partial state ('good', 'minor',
/// 'major', or absent = not inspected).
const Map<String, String> partialPartConditions = {
  'front_bumper': 'minor',
  'hood': 'good',
  'front_left_headlight': 'good',
  'front_right_headlight': 'good',
  'front_windshield': 'good',
  'roof': 'good',
  'rear_windshield': 'good',
  'trunk': 'good',
  'rear_bumper': 'good',
  'front_left_fender': 'good',
  'front_right_fender': 'good',
  'front_left_door': 'minor',
  'rear_left_door': 'good',
  'front_right_door': 'good',
  'rear_right_door': 'good',
  'rear_left_quarter': 'good',
  'rear_right_quarter': 'major',
  'left_mirror': 'good',
  'right_mirror': 'good',
  'front_left_wheel': 'good',
  'front_right_wheel': 'good',
  'rear_left_wheel': 'good',
  'rear_right_wheel': 'good',
  'rear_left_taillight': 'good',
  'rear_right_taillight': 'good',
};

/// Localized part label keys - ids match `advisor_car_top_mapping.json`.
const Map<String, String> partLabelKeys = {
  'front_bumper': 'insp.part.frontBumper',
  'hood': 'insp.part.hood',
  'front_left_headlight': 'insp.part.frontLeftHeadlight',
  'front_right_headlight': 'insp.part.frontRightHeadlight',
  'front_windshield': 'insp.part.frontWindshield',
  'roof': 'insp.part.roof',
  'rear_windshield': 'insp.part.rearWindshield',
  'trunk': 'insp.part.trunk',
  'rear_bumper': 'insp.part.rearBumper',
  'front_left_fender': 'insp.part.frontLeftFender',
  'front_right_fender': 'insp.part.frontRightFender',
  'front_left_door': 'insp.part.frontLeftDoor',
  'rear_left_door': 'insp.part.rearLeftDoor',
  'front_right_door': 'insp.part.frontRightDoor',
  'rear_right_door': 'insp.part.rearRightDoor',
  'rear_left_quarter': 'insp.part.rearLeftQuarter',
  'rear_right_quarter': 'insp.part.rearRightQuarter',
  'left_mirror': 'insp.part.leftMirror',
  'right_mirror': 'insp.part.rightMirror',
  'front_left_wheel': 'insp.part.frontLeftWheel',
  'front_right_wheel': 'insp.part.frontRightWheel',
  'rear_left_wheel': 'insp.part.rearLeftWheel',
  'rear_right_wheel': 'insp.part.rearRightWheel',
  'rear_left_taillight': 'insp.part.rearLeftTaillight',
  'rear_right_taillight': 'insp.part.rearRightTaillight',
};
