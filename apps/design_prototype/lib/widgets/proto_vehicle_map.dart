// Vehicle damage map for the prototype.
//
// Reuses the REAL production assets copied into this app:
//   - assets/vehicle_map/advisor_car_top_mapped.svg  (base illustration,
//     extracted at runtime from the embedded base64 PNG - no SVG dependency)
//   - assets/vehicle_map/advisor_car_top_mapping.json (the 25 interactive
//     part outlines, parsed by a minimal M/L/C/Z path reader)
//
// RTL EXCEPTION (canonical, spec §9.8): the vehicle outline keeps its
// physical orientation in Arabic; only the surrounding UI mirrors. The map is
// therefore wrapped in its own LTR Directionality.
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/prototype_theme.dart';
import '../design/provisional_tokens.dart';

class ProtoMapPart {
  final String id;
  final String label;
  final String category;
  final Path path;
  final int hitTestPriority;

  const ProtoMapPart({
    required this.id,
    required this.label,
    required this.category,
    required this.path,
    required this.hitTestPriority,
  });
}

class ProtoVehicleMapDefinition {
  final Rect viewBox;
  final List<ProtoMapPart> parts;

  const ProtoVehicleMapDefinition({required this.viewBox, required this.parts});

  ProtoMapPart? hitTest(Offset mapPoint) {
    final ordered = [...parts]..sort((a, b) => b.hitTestPriority.compareTo(a.hitTestPriority));
    for (final part in ordered) {
      if (part.path.contains(mapPoint)) return part;
    }
    return null;
  }
}

class ProtoMapTransform {
  final Rect viewBox;
  final Size viewport;
  late final double scale = _scale();
  late final Rect renderedRect = Rect.fromLTWH(
    (viewport.width - viewBox.width * scale) / 2,
    (viewport.height - viewBox.height * scale) / 2,
    viewBox.width * scale,
    viewBox.height * scale,
  );

  ProtoMapTransform({required this.viewBox, required this.viewport});

  double _scale() {
    if (viewBox.isEmpty || viewport.isEmpty) return 0;
    final x = viewport.width / viewBox.width;
    final y = viewport.height / viewBox.height;
    return x < y ? x : y;
  }

  Offset? displayToMap(Offset local) {
    if (scale == 0 || !renderedRect.contains(local)) return null;
    return Offset(
      viewBox.left + (local.dx - renderedRect.left) / scale,
      viewBox.top + (local.dy - renderedRect.top) / scale,
    );
  }

  Offset mapToDisplay(Offset map) => Offset(
        renderedRect.left + (map.dx - viewBox.left) * scale,
        renderedRect.top + (map.dy - viewBox.top) * scale,
      );

  Offset normalizedToDisplay(Offset normalized) => mapToDisplay(
        Offset(
          viewBox.left + normalized.dx.clamp(0, 1) * viewBox.width,
          viewBox.top + normalized.dy.clamp(0, 1) * viewBox.height,
        ),
      );
}

abstract final class ProtoVehicleMapLoader {
  static const String svgAsset = 'assets/vehicle_map/advisor_car_top_mapped.svg';
  static const String mappingAsset = 'assets/vehicle_map/advisor_car_top_mapping.json';

  static ProtoVehicleMapDefinition? _definition;
  static Uint8List? _imageBytes;
  static Future<ProtoVehicleMapDefinition>? _definitionPending;
  static Future<Uint8List>? _imagePending;

  /// Caches the decoded VALUES and returns a [SynchronousFuture] on cache hit
  /// so widgets can build with data in the first frame (and tests that warm
  /// the cache through `tester.runAsync` render deterministically).
  static Future<ProtoVehicleMapDefinition> load() {
    final cached = _definition;
    if (cached != null) return SynchronousFuture(cached);
    return _definitionPending ??= _loadDefinition().then((definition) {
      _definition = definition;
      return definition;
    });
  }

  static Future<Uint8List> loadBaseImage() {
    final cached = _imageBytes;
    if (cached != null) return SynchronousFuture(cached);
    return _imagePending ??= _loadBaseImage().then((bytes) {
      _imageBytes = bytes;
      return bytes;
    });
  }

  static Future<ProtoVehicleMapDefinition> _loadDefinition() async {
    final raw = jsonDecode(await rootBundle.loadString(mappingAsset));
    final json = Map<String, dynamic>.from(raw as Map);
    final box = Map<String, dynamic>.from(json['viewBox'] as Map);
    final parts = <ProtoMapPart>[];
    final partsJson = json['parts'] as List<dynamic>;
    for (var index = 0; index < partsJson.length; index++) {
      final item = Map<String, dynamic>.from(partsJson[index] as Map);
      final id = item['id']?.toString() ?? '';
      final pathData = item['svgPath']?.toString() ?? '';
      if (id.isEmpty || pathData.isEmpty) continue;
      final category = item['category']?.toString() ?? 'other';
      parts.add(
        ProtoMapPart(
          id: id,
          label: item['label']?.toString() ?? id,
          category: category,
          path: _parseSvgPathData(pathData),
          hitTestPriority: _priority(category) * 1000 + index,
        ),
      );
    }
    return ProtoVehicleMapDefinition(
      viewBox: Rect.fromLTWH(
        (box['x'] as num?)?.toDouble() ?? 0,
        (box['y'] as num?)?.toDouble() ?? 0,
        (box['width'] as num?)?.toDouble() ?? 1254,
        (box['height'] as num?)?.toDouble() ?? 1254,
      ),
      parts: parts,
    );
  }

  static Future<Uint8List> _loadBaseImage() async {
    final svg = await rootBundle.loadString(svgAsset);
    final match = RegExp(r'data:image/png;base64,([A-Za-z0-9+/=]+)').firstMatch(svg);
    if (match == null) {
      throw const FormatException('Embedded base illustration not found');
    }
    return base64Decode(match.group(1)!);
  }

  static int _priority(String category) => switch (category) {
        'mirror' => 5,
        'light' => 4,
        'wheel' => 3,
        'glass' => 2,
        'body' => 1,
        _ => 0,
      };
}

/// Minimal SVG path reader for the absolute commands used by the production
/// mapping file (M / L / C / Z only - verified against the asset).
Path _parseSvgPathData(String data) {
  final path = Path();
  final tokens = RegExp(r'[MLCZmlcz]|-?\d*\.?\d+(?:[eE][-+]?\d+)?').allMatches(data);
  final values = tokens.map((m) => m.group(0)!).toList();

  var i = 0;
  String? command;
  double next() => double.parse(values[i++]);
  bool hasNumber() => i < values.length && !RegExp(r'^[A-Za-z]$').hasMatch(values[i]);

  while (i < values.length) {
    final token = values[i];
    if (RegExp(r'^[A-Za-z]$').hasMatch(token)) {
      command = token;
      i++;
      if (command == 'Z' || command == 'z') {
        path.close();
        command = null;
      }
      continue;
    }
    switch (command) {
      case 'M':
        final x = next();
        final y = next();
        path.moveTo(x, y);
        command = 'L'; // implicit lineto after moveto (SVG spec)
      case 'L':
        path.lineTo(next(), next());
      case 'C':
        path.cubicTo(next(), next(), next(), next(), next(), next());
      default:
        i++; // unknown token - skip defensively
    }
    if (!hasNumber()) command = null;
  }
  return path;
}

/// One numbered finding marker on the map.
class ProtoMapMarker {
  final String partId;
  final String label; // "1" based index rendered inside the marker
  final double nx;
  final double ny;
  final bool major;

  const ProtoMapMarker({
    required this.partId,
    required this.label,
    required this.nx,
    required this.ny,
    this.major = false,
  });
}

/// Interactive body-condition map. Condition per part: 'good' / 'minor' /
/// 'major' (absent = not inspected). Never mirrors in RTL (physical car).
class ProtoVehicleMap extends StatelessWidget {
  final ProtoVehicleMapDefinition definition;
  final Map<String, String> partConditions;
  final List<ProtoMapMarker> markers;
  final String? selectedPartId;
  final void Function(ProtoMapPart part)? onPartTap;
  final Widget? background;

  const ProtoVehicleMap({
    super.key,
    required this.definition,
    required this.partConditions,
    this.markers = const [],
    this.selectedPartId,
    this.onPartTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Semantics(
        label: 'Interactive vehicle body condition map',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final transform = ProtoMapTransform(viewBox: definition.viewBox, viewport: size);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onPartTap == null
                  ? null
                  : (details) {
                      final mapPoint = transform.displayToMap(details.localPosition);
                      if (mapPoint == null) return;
                      final part = definition.hitTest(mapPoint);
                      if (part != null) onPartTap!(part);
                    },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (background != null) background!,
                  CustomPaint(
                    size: size,
                    painter: _MapPainter(
                      definition: definition,
                      conditions: partConditions,
                      selectedPartId: selectedPartId,
                      transform: transform,
                      palette: p,
                    ),
                  ),
                  for (final marker in markers)
                    _marker(context, transform, marker),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _marker(BuildContext context, ProtoMapTransform transform, ProtoMapMarker marker) {
    final p = context.palette;
    final point = transform.normalizedToDisplay(Offset(marker.nx, marker.ny));
    final color = marker.major ? p.danger : p.warning;
    return Positioned(
      left: point.dx - 13,
      top: point.dy - 13,
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: ProtoElevation.card,
        ),
        child: Text(
          marker.label,
          style: context.types.metadata.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final ProtoVehicleMapDefinition definition;
  final Map<String, String> conditions;
  final String? selectedPartId;
  final ProtoMapTransform transform;
  final ProtoPalette palette;

  const _MapPainter({
    required this.definition,
    required this.conditions,
    required this.selectedPartId,
    required this.transform,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(transform.renderedRect.left, transform.renderedRect.top);
    canvas.scale(transform.scale, transform.scale);
    canvas.translate(-definition.viewBox.left, -definition.viewBox.top);

    for (final part in definition.parts) {
      final condition = conditions[part.id];
      final selected = part.id == selectedPartId;
      final color = switch (condition) {
        'good' => palette.success,
        'minor' => palette.warning,
        'major' => palette.danger,
        _ => selected ? palette.primary : null,
      };
      if (color != null) {
        canvas.drawPath(
          part.path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color.withValues(alpha: selected ? 0.34 : 0.22),
        );
      }
      if (selected) {
        canvas.drawPath(
          part.path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 / transform.scale
            ..color = palette.primary,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.conditions != conditions ||
      oldDelegate.selectedPartId != selectedPartId ||
      oldDelegate.palette != palette ||
      oldDelegate.transform.viewport != transform.viewport;
}

/// Runtime extraction of the base illustration from the real SVG asset.
class ProtoVehicleMapImage extends StatelessWidget {
  final ProtoVehicleMapDefinition definition;
  final void Function(ProtoMapPart part)? onPartTap;
  final Map<String, String> partConditions;
  final List<ProtoMapMarker> markers;
  final String? selectedPartId;

  const ProtoVehicleMapImage({
    super.key,
    required this.definition,
    required this.partConditions,
    this.markers = const [],
    this.selectedPartId,
    this.onPartTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: ProtoVehicleMapLoader.loadBaseImage(),
      builder: (context, snapshot) {
        final image = snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                gaplessPlayback: true,
              )
            : const SizedBox.shrink();
        return ProtoVehicleMap(
          definition: definition,
          partConditions: partConditions,
          markers: markers,
          selectedPartId: selectedPartId,
          onPartTap: onPartTap,
          background: ColoredBox(
            color: context.palette.surface,
            child: FittedBox(child: image),
          ),
        );
      },
    );
  }
}
