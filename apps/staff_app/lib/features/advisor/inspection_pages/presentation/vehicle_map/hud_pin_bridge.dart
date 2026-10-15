import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ─── DAMAGE PIN BRIDGE (Phase 08) ────────────────────────────────────────────
// Pins dropped on the real 25-part top-view map (`advisor_car_top_mapping.json`)
// are stored as regular [VehicleDamageFinding] records keyed by the REAL part
// id (e.g. `front_left_fender`), so the existing persist/sync payload
// (`vehicleBodyCondition.parts`, see `vehicleBodyConditionPayload`) carries
// them with zero contract change: same parts shape, pin = part + damage
// detail (kind, severity, size descriptor in `damageLocation`, note, photos).
//
// Severity presentation follows the frozen theme roles — never raw hex:
// minor → damageMinor (info blue), moderate → damageModerate (warning amber),
// severe → damageSevere (danger crimson).
//
// The dummy 8-zone blueprint (`hud_<zone>` parts) is gone: unknown part ids
// (including stale `hud_*` keys from old drafts) fall back to a prettified id.

/// The five damage kinds offered by the HUD detail sheet.
const damageDetailKinds = <VehicleDamageType>[
  VehicleDamageType.scratch,
  VehicleDamageType.dent,
  VehicleDamageType.crack,
  VehicleDamageType.paintChip,
  VehicleDamageType.broken,
];

/// Damage size descriptors, persisted in [VehicleDamageFinding.damageLocation].
const damageDetailSizes = <String>['coin', 'palm', 'span'];

String damageKindLabel(StaffLocalizations t, VehicleDamageType kind) {
  switch (kind) {
    case VehicleDamageType.scratch:
      return t.advisorDamageKindScratch;
    case VehicleDamageType.dent:
      return t.advisorDamageKindDent;
    case VehicleDamageType.crack:
      return t.advisorDamageKindCrack;
    case VehicleDamageType.paintChip:
      return t.advisorDamageKindPaint;
    case VehicleDamageType.broken:
      return t.advisorDamageKindBroken;
    case VehicleDamageType.deepScratch:
      return t.advisorDamageKindScratch;
    case VehicleDamageType.repainted:
    case VehicleDamageType.faded:
    case VehicleDamageType.rust:
    case VehicleDamageType.other:
      return t.advisorDamageKindPaint;
  }
}

IconData damageKindIcon(VehicleDamageType kind) {
  switch (kind) {
    case VehicleDamageType.scratch:
    case VehicleDamageType.deepScratch:
      return Icons.gesture_rounded;
    case VehicleDamageType.dent:
      return Icons.car_crash_outlined;
    case VehicleDamageType.crack:
      return Icons.lightbulb_outline_rounded;
    case VehicleDamageType.paintChip:
    case VehicleDamageType.repainted:
    case VehicleDamageType.faded:
    case VehicleDamageType.rust:
      return Icons.format_paint_outlined;
    case VehicleDamageType.broken:
    case VehicleDamageType.other:
      return Icons.handyman_outlined;
  }
}

/// The kind's default severity; the sheet lets the advisor override it.
VehicleDamageSeverity defaultSeverityForKind(VehicleDamageType kind) {
  switch (kind) {
    case VehicleDamageType.scratch:
    case VehicleDamageType.paintChip:
    case VehicleDamageType.faded:
      return VehicleDamageSeverity.minor;
    case VehicleDamageType.dent:
    case VehicleDamageType.deepScratch:
    case VehicleDamageType.crack:
    case VehicleDamageType.repainted:
    case VehicleDamageType.rust:
      return VehicleDamageSeverity.moderate;
    case VehicleDamageType.broken:
    case VehicleDamageType.other:
      return VehicleDamageSeverity.major;
  }
}

String damageSeverityLabel(StaffLocalizations t, VehicleDamageSeverity severity) {
  switch (severity) {
    case VehicleDamageSeverity.minor:
      return t.advisorDamageMinor;
    case VehicleDamageSeverity.moderate:
      return t.advisorDamageModerate;
    case VehicleDamageSeverity.major:
      return t.advisorDamageSevere;
  }
}

/// Frozen theme tone for a severity — the single verdict grammar for pins,
/// tints and pills.
AppStatusColors damageSeverityTone(
  AppSemanticColors semantic,
  VehicleDamageSeverity severity,
) {
  switch (severity) {
    case VehicleDamageSeverity.minor:
      return semantic.damageMinor;
    case VehicleDamageSeverity.moderate:
      return semantic.damageModerate;
    case VehicleDamageSeverity.major:
      return semantic.damageSevere;
  }
}

String damageSizeLabel(StaffLocalizations t, String size) {
  switch (size) {
    case 'coin':
      return t.advisorDamageSizeCoin;
    case 'palm':
      return t.advisorDamageSizePalm;
    case 'span':
      return t.advisorDamageSizeSpan;
    default:
      return size;
  }
}

String damageCategoryLabel(
  StaffLocalizations t,
  VehiclePartCategory category,
) {
  switch (category) {
    case VehiclePartCategory.body:
      return t.advisorDamageCatBody;
    case VehiclePartCategory.glass:
      return t.advisorDamageCatGlass;
    case VehiclePartCategory.wheel:
      return t.advisorDamageCatWheel;
    case VehiclePartCategory.light:
      return t.advisorDamageCatLight;
    case VehiclePartCategory.mirror:
      return t.advisorDamageCatMirror;
    case VehiclePartCategory.other:
      return t.advisorDamageCatBody;
  }
}

/// Localized part name for a real map part id, with prettified-id fallback
/// (covers stale `hud_*` keys from pre-rework drafts).
String damagePartLabel(StaffLocalizations t, String partId) {
  switch (partId) {
    case 'front_bumper':
      return t.advisorPartFrontBumper;
    case 'hood':
      return t.advisorPartHood;
    case 'front_left_headlight':
      return t.advisorPartFrontLeftHeadlight;
    case 'front_right_headlight':
      return t.advisorPartFrontRightHeadlight;
    case 'front_windshield':
      return t.advisorPartFrontWindshield;
    case 'roof':
      return t.advisorPartRoof;
    case 'rear_windshield':
      return t.advisorPartRearWindshield;
    case 'trunk':
      return t.advisorPartTrunk;
    case 'rear_bumper':
      return t.advisorPartRearBumper;
    case 'front_left_fender':
      return t.advisorPartFrontLeftFender;
    case 'front_right_fender':
      return t.advisorPartFrontRightFender;
    case 'front_left_door':
      return t.advisorPartFrontLeftDoor;
    case 'rear_left_door':
      return t.advisorPartRearLeftDoor;
    case 'front_right_door':
      return t.advisorPartFrontRightDoor;
    case 'rear_right_door':
      return t.advisorPartRearRightDoor;
    case 'rear_left_quarter':
      return t.advisorPartRearLeftQuarter;
    case 'rear_right_quarter':
      return t.advisorPartRearRightQuarter;
    case 'left_mirror':
      return t.advisorPartLeftMirror;
    case 'right_mirror':
      return t.advisorPartRightMirror;
    case 'front_left_wheel':
      return t.advisorPartFrontLeftWheel;
    case 'front_right_wheel':
      return t.advisorPartFrontRightWheel;
    case 'rear_left_wheel':
      return t.advisorPartRearLeftWheel;
    case 'rear_right_wheel':
      return t.advisorPartRearRightWheel;
    case 'rear_left_taillight':
      return t.advisorPartRearLeftTaillight;
    case 'rear_right_taillight':
      return t.advisorPartRearRightTaillight;
    default:
      return partId.replaceAll('_', ' ');
  }
}

/// Worst severity across findings — drives zone tinting (severe wins).
VehicleDamageSeverity? worstSeverity(List<VehicleDamageFinding> findings) {
  if (findings.any((f) => f.severity == VehicleDamageSeverity.major)) {
    return VehicleDamageSeverity.major;
  }
  if (findings.any((f) => f.severity == VehicleDamageSeverity.moderate)) {
    return VehicleDamageSeverity.moderate;
  }
  if (findings.isNotEmpty) return VehicleDamageSeverity.minor;
  return null;
}
