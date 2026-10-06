import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_core/shared_core.dart';

import '../../data/models/vehicle_damage_map_model.dart';
import 'vehicle_map_transform.dart';

class VehicleInspectionMap extends StatelessWidget {
  static const svgAsset = 'assets/vehicle_maps/advisor_car_top_mapped.svg';

  final VehicleMapDefinition definition;
  final Map<String, VehiclePartInspection> inspections;
  final String? selectedPartId;
  final bool editable;
  final bool placingMarker;
  final bool debugOverlay;
  final void Function(VehicleMapPart part, Offset normalized)? onPartSelected;
  final ValueChanged<VehicleDamageFinding>? onFindingSelected;

  const VehicleInspectionMap({
    super.key,
    required this.definition,
    required this.inspections,
    this.selectedPartId,
    this.editable = true,
    this.placingMarker = false,
    this.debugOverlay = false,
    this.onPartSelected,
    this.onFindingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final transform = VehicleMapTransform(
          viewBox: definition.viewBox,
          viewport: size,
        );
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Semantics(
            label: 'Interactive vehicle body condition map',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: editable
                  ? (details) {
                      final mapPoint = transform.displayToMap(
                        details.localPosition,
                      );
                      if (mapPoint == null) return;
                      final part = definition.hitTest(mapPoint);
                      if (part == null) return;
                      onPartSelected?.call(
                        part,
                        transform.mapToNormalized(mapPoint),
                      );
                    }
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvgPicture.asset(svgAsset, fit: BoxFit.contain),
                  CustomPaint(
                    painter: _VehicleMapPainter(
                      definition: definition,
                      inspections: inspections,
                      selectedPartId: selectedPartId,
                      transform: transform,
                      showDebug: kDebugMode && debugOverlay,
                    ),
                  ),
                  for (final entry in inspections.entries)
                    for (var i = 0; i < entry.value.findings.length; i++)
                      _marker(
                        context,
                        transform,
                        entry.value.findings[i],
                        i + 1,
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _marker(
    BuildContext context,
    VehicleMapTransform transform,
    VehicleDamageFinding finding,
    int number,
  ) {
    final point = transform.normalizedToDisplay(
      Offset(finding.normalizedX, finding.normalizedY),
    );
    final color = finding.severity == VehicleDamageSeverity.major
        ? AppColors.danger
        : AppColors.warning;
    return Positioned(
      left: point.dx - 13,
      top: point.dy - 13,
      child: Semantics(
        button: true,
        label: 'Damage $number on ${finding.partId}',
        child: GestureDetector(
          onTap: () => onFindingSelected?.call(finding),
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: AppDimensions.shadowCard,
            ),
            child: Text(
              '$number',
              style: AppTextStyles.metadata(
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleMapPainter extends CustomPainter {
  final VehicleMapDefinition definition;
  final Map<String, VehiclePartInspection> inspections;
  final String? selectedPartId;
  final VehicleMapTransform transform;
  final bool showDebug;

  _VehicleMapPainter({
    required this.definition,
    required this.inspections,
    required this.selectedPartId,
    required this.transform,
    required this.showDebug,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(transform.renderedRect.left, transform.renderedRect.top);
    canvas.scale(transform.scale, transform.scale);
    canvas.translate(-definition.viewBox.left, -definition.viewBox.top);
    for (final part in definition.parts) {
      final condition = inspections[part.id]?.effectiveCondition;
      final selected = part.id == selectedPartId;
      final color = switch (condition) {
        VehiclePartCondition.good => AppColors.success,
        VehiclePartCondition.minor => AppColors.warning,
        VehiclePartCondition.major => AppColors.danger,
        _ => selected ? AppColors.primary : Colors.transparent,
      };
      if (color != Colors.transparent) {
        canvas.drawPath(
          part.path,
          Paint()
            ..style = PaintingStyle.fill
            ..color = color.withValues(alpha: selected ? 0.32 : 0.20),
        );
      }
      if (selected || showDebug) {
        canvas.drawPath(
          part.path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 / transform.scale
            ..color = selected ? AppColors.primary : AppColors.text4,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VehicleMapPainter oldDelegate) =>
      oldDelegate.inspections != inspections ||
      oldDelegate.selectedPartId != selectedPartId ||
      oldDelegate.transform.viewport != transform.viewport;
}
