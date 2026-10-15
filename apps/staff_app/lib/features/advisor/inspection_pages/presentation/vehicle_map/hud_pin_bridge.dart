import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

// ─── HUD PIN BRIDGE (Phase 08) ───────────────────────────────────────────────
// Damage pins dropped on the 8-zone blueprint are stored as regular
// [VehicleDamageFinding] records on synthetic `hud_<zone>` parts, so the
// existing persist/sync payload (`vehicleBodyCondition.parts`) carries them
// with zero contract change. Findings recorded at intake on real SVG parts
// (e.g. `front_left_door`) are listed alongside and stay deletable.

String hudPartId(VehicleZone zone) => 'hud_${zone.name}';

VehicleZone? hudZoneForPart(String partId) {
  if (!partId.startsWith('hud_')) return null;
  final name = partId.substring(4);
  for (final zone in VehicleZone.values) {
    if (zone.name == name) return zone;
  }
  return null;
}

String hudZoneLabel(StaffLocalizations t, VehicleZone zone) {
  switch (zone) {
    case VehicleZone.front:
      return t.advisorHudZoneFront;
    case VehicleZone.frontLeft:
      return t.advisorHudZoneFrontLeft;
    case VehicleZone.sideLeft:
      return t.advisorHudZoneSideLeft;
    case VehicleZone.rearLeft:
      return t.advisorHudZoneRearLeft;
    case VehicleZone.rear:
      return t.advisorHudZoneRear;
    case VehicleZone.rearRight:
      return t.advisorHudZoneRearRight;
    case VehicleZone.sideRight:
      return t.advisorHudZoneSideRight;
    case VehicleZone.frontRight:
      return t.advisorHudZoneFrontRight;
  }
}

Offset hudZoneAnchor(VehicleZone zone) {
  switch (zone) {
    case VehicleZone.front:
      return const Offset(0.5, 0.07);
    case VehicleZone.frontLeft:
      return const Offset(0.17, 0.22);
    case VehicleZone.sideLeft:
      return const Offset(0.05, 0.5);
    case VehicleZone.rearLeft:
      return const Offset(0.17, 0.78);
    case VehicleZone.rear:
      return const Offset(0.5, 0.93);
    case VehicleZone.rearRight:
      return const Offset(0.83, 0.78);
    case VehicleZone.sideRight:
      return const Offset(0.95, 0.5);
    case VehicleZone.frontRight:
      return const Offset(0.83, 0.22);
  }
}

/// Amber minor / Crimson structural / Blue glass-lamp, per the HUD spec.
DamageKind hudKindForFindings(List<VehicleDamageFinding> findings) {
  if (findings.any((f) => f.damageType == VehicleDamageType.crack)) {
    return DamageKind.glass;
  }
  if (findings.any((f) => f.severity == VehicleDamageSeverity.major)) {
    return DamageKind.dent;
  }
  return DamageKind.scratch;
}

VehicleDamageFinding hudFindingForKind(DamageKind kind, VehicleZone zone) {
  final anchor = hudZoneAnchor(zone);
  switch (kind) {
    case DamageKind.scratch:
      return VehicleDamageFinding(
        id: 'HUD-${DateTime.now().microsecondsSinceEpoch}',
        partId: hudPartId(zone),
        damageType: VehicleDamageType.scratch,
        severity: VehicleDamageSeverity.minor,
        normalizedX: anchor.dx,
        normalizedY: anchor.dy,
      );
    case DamageKind.dent:
      return VehicleDamageFinding(
        id: 'HUD-${DateTime.now().microsecondsSinceEpoch}',
        partId: hudPartId(zone),
        damageType: VehicleDamageType.dent,
        severity: VehicleDamageSeverity.major,
        normalizedX: anchor.dx,
        normalizedY: anchor.dy,
      );
    case DamageKind.glass:
      return VehicleDamageFinding(
        id: 'HUD-${DateTime.now().microsecondsSinceEpoch}',
        partId: hudPartId(zone),
        damageType: VehicleDamageType.crack,
        severity: VehicleDamageSeverity.moderate,
        normalizedX: anchor.dx,
        normalizedY: anchor.dy,
      );
  }
}
