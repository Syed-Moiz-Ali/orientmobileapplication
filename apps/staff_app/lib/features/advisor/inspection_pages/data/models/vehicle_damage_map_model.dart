import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';

enum VehiclePartCategory { body, glass, wheel, light, mirror, other }

enum VehiclePartCondition { uninspected, good, minor, major }

enum VehicleDamageType {
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

enum VehicleDamageSeverity { minor, moderate, major }

enum VehicleRecommendedAction { noAction, monitor, repair, repaint, replace }

class VehicleMapPart {
  final String id;
  final String label;
  final VehiclePartCategory category;
  final String svgPath;
  final Path path;
  final int hitTestPriority;

  const VehicleMapPart({
    required this.id,
    required this.label,
    required this.category,
    required this.svgPath,
    required this.path,
    required this.hitTestPriority,
  });
}

class VehicleMapDefinition {
  final String id;
  final String view;
  final Rect viewBox;
  final List<VehicleMapPart> parts;

  const VehicleMapDefinition({
    required this.id,
    required this.view,
    required this.viewBox,
    required this.parts,
  });

  VehicleMapPart? partById(String id) {
    for (final part in parts) {
      if (part.id == id) return part;
    }
    return null;
  }

  /// Later entries are painted above earlier entries, so hit testing follows
  /// the inverse paint order. Explicit category priority breaks edge overlaps.
  VehicleMapPart? hitTest(Offset mapPoint) {
    final ordered = [...parts]
      ..sort((a, b) => b.hitTestPriority.compareTo(a.hitTestPriority));
    for (final part in ordered) {
      if (part.path.contains(mapPoint)) {
        return part;
      }
    }
    return null;
  }
}

class VehicleDamageFinding {
  final String id;
  final String partId;
  final VehicleDamageType damageType;
  final VehicleDamageSeverity severity;
  final String damageLocation;
  final String note;
  final List<String> photos;
  final VehicleRecommendedAction recommendedAction;
  final double normalizedX;
  final double normalizedY;

  const VehicleDamageFinding({
    required this.id,
    required this.partId,
    required this.damageType,
    required this.severity,
    this.damageLocation = '',
    this.note = '',
    this.photos = const [],
    this.recommendedAction = VehicleRecommendedAction.noAction,
    required this.normalizedX,
    required this.normalizedY,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'partId': partId,
    'damageType': damageType.name,
    'severity': severity.name,
    'damageLocation': damageLocation,
    'note': note,
    'photos': photos,
    'recommendedAction': recommendedAction.name,
    'position': {'x': normalizedX, 'y': normalizedY},
  };

  factory VehicleDamageFinding.fromJson(Map<String, dynamic> json) {
    final position = json['position'] is Map
        ? Map<String, dynamic>.from(json['position'] as Map)
        : const <String, dynamic>{};
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) =>
        values.where((value) => value.name == raw?.toString()).firstOrNull ??
        fallback;
    return VehicleDamageFinding(
      id: json['id']?.toString() ?? '',
      partId: json['partId']?.toString() ?? '',
      damageType: enumValue(
        VehicleDamageType.values,
        json['damageType'],
        VehicleDamageType.other,
      ),
      severity: enumValue(
        VehicleDamageSeverity.values,
        json['severity'],
        VehicleDamageSeverity.minor,
      ),
      damageLocation: json['damageLocation']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      photos: (json['photos'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      recommendedAction: enumValue(
        VehicleRecommendedAction.values,
        json['recommendedAction'],
        VehicleRecommendedAction.noAction,
      ),
      normalizedX: ((position['x'] as num?)?.toDouble() ?? 0).clamp(0, 1),
      normalizedY: ((position['y'] as num?)?.toDouble() ?? 0).clamp(0, 1),
    );
  }
}

class VehiclePartInspection {
  final String partId;
  final VehiclePartCondition condition;
  final List<VehicleDamageFinding> findings;

  const VehiclePartInspection({
    required this.partId,
    this.condition = VehiclePartCondition.uninspected,
    this.findings = const [],
  });

  VehiclePartCondition get effectiveCondition {
    if (findings.any((item) => item.severity == VehicleDamageSeverity.major)) {
      return VehiclePartCondition.major;
    }
    if (findings.isNotEmpty &&
        condition.index < VehiclePartCondition.minor.index) {
      return VehiclePartCondition.minor;
    }
    return condition;
  }

  VehiclePartInspection copyWith({
    VehiclePartCondition? condition,
    List<VehicleDamageFinding>? findings,
  }) => VehiclePartInspection(
    partId: partId,
    condition: condition ?? this.condition,
    findings: findings ?? this.findings,
  );

  Map<String, dynamic> toJson() => {
    'partId': partId,
    'condition': condition.name,
    'findings': findings.map((item) => item.toJson()).toList(),
  };

  factory VehiclePartInspection.fromJson(Map<String, dynamic> json) =>
      VehiclePartInspection(
        partId: json['partId']?.toString() ?? '',
        condition: VehiclePartCondition.values.firstWhere(
          (value) => value.name == json['condition']?.toString(),
          orElse: () => VehiclePartCondition.uninspected,
        ),
        findings: (json['findings'] as List? ?? const [])
            .whereType<Map>()
            .map(
              (item) => VehicleDamageFinding.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(),
      );
}

class VehicleMapLoader {
  static const assetPath = 'assets/vehicle_maps/advisor_car_top_mapping.json';
  static Future<VehicleMapDefinition>? _cached;

  static Future<VehicleMapDefinition> load() => _cached ??= _load();

  static Future<VehicleMapDefinition> _load() async {
    final raw = jsonDecode(await rootBundle.loadString(assetPath));
    if (raw is! Map) throw const FormatException('Invalid vehicle map JSON');
    final json = Map<String, dynamic>.from(raw);
    final box = Map<String, dynamic>.from(json['viewBox'] as Map);
    final partsJson = json['parts'];
    if (partsJson is! List) {
      throw const FormatException('Map parts are missing');
    }
    final parts = <VehicleMapPart>[];
    for (var index = 0; index < partsJson.length; index++) {
      final item = Map<String, dynamic>.from(partsJson[index] as Map);
      final id = item['id']?.toString() ?? '';
      final pathData = item['svgPath']?.toString() ?? '';
      if (id.isEmpty || pathData.isEmpty) continue;
      final category = VehiclePartCategory.values.firstWhere(
        (value) => value.name == item['category']?.toString(),
        orElse: () => VehiclePartCategory.other,
      );
      parts.add(
        VehicleMapPart(
          id: id,
          label: item['label']?.toString() ?? id,
          category: category,
          svgPath: pathData,
          path: parseSvgPathData(pathData),
          hitTestPriority: _priority(category) * 1000 + index,
        ),
      );
    }
    if (parts.isEmpty) throw const FormatException('No valid map parts');
    return VehicleMapDefinition(
      id: json['asset']?.toString() ?? 'advisor_car_top',
      view: json['view']?.toString() ?? 'top',
      viewBox: Rect.fromLTWH(
        (box['x'] as num?)?.toDouble() ?? 0,
        (box['y'] as num?)?.toDouble() ?? 0,
        (box['width'] as num?)?.toDouble() ?? 1254,
        (box['height'] as num?)?.toDouble() ?? 1254,
      ),
      parts: parts,
    );
  }

  static int _priority(VehiclePartCategory category) => switch (category) {
    VehiclePartCategory.mirror => 5,
    VehiclePartCategory.light => 4,
    VehiclePartCategory.wheel => 3,
    VehiclePartCategory.glass => 2,
    VehiclePartCategory.body => 1,
    VehiclePartCategory.other => 0,
  };
}
