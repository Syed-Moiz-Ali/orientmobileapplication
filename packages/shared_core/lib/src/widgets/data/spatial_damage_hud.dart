import 'package:flutter/material.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// The type of a logged damage point — drives the hotspot colour/icon.
enum DamageKind { scratch, dent, glass }

/// One of the eight blueprint viewpoints around the vehicle.
///
/// The physical layout is **never mirrored**: front stays at the top in both
/// LTR and RTL so the diagram matches the real vehicle the technician faces.
enum VehicleZone {
  front,
  frontLeft,
  sideLeft,
  rearLeft,
  rear,
  rearRight,
  sideRight,
  frontRight,
}

/// A single tapped damage point.
@immutable
class DamageHotspot {
  final VehicleZone zone;
  final DamageKind kind;

  /// Optional short descriptor (e.g. "Front bumper").
  final String? label;

  /// Optional reference code (e.g. "D-04").
  final String? code;

  const DamageHotspot({
    required this.zone,
    required this.kind,
    this.label,
    this.code,
  });
}

/// Normalized anchor for each zone, in a top-view coordinate space where the
/// vehicle points up (front at top). Values are fractions of the plot box.
const Map<VehicleZone, Alignment> _zoneAnchors = {
  VehicleZone.front: Alignment(0, -0.86),
  VehicleZone.frontLeft: Alignment(-0.66, -0.56),
  VehicleZone.sideLeft: Alignment(-0.9, 0),
  VehicleZone.rearLeft: Alignment(-0.66, 0.56),
  VehicleZone.rear: Alignment(0, 0.86),
  VehicleZone.rearRight: Alignment(0.66, 0.56),
  VehicleZone.sideRight: Alignment(0.9, 0),
  VehicleZone.frontRight: Alignment(0.66, -0.56),
};

/// **Spatial damage HUD (Phase 03, Concept A).**
///
/// An interactive top-view vehicle blueprint with eight tap-to-pin damage
/// hotspots (scratch → amber, dent → crimson, glass/lamp → ice blue). The
/// diagram is a real vector line-drawing, not a gray silhouette box, and its
/// physical orientation is locked LTR inside an Arabic RTL screen so the front
/// of the vehicle always faces the same way.
///
/// Presentation only — the caller owns the damage list and any persistence.
class SpatialDamageHud extends StatelessWidget {
  final List<DamageHotspot> hotspots;
  final void Function(DamageHotspot hotspot)? onHotspotTap;

  /// Fires when the caller taps an empty blueprint zone (no pin nearby), so
  /// hosts can drop a new pin. Null keeps the previous pins-only behaviour.
  ///
  /// Phase 08 addition (additive, backward compatible): previously the canvas
  /// was not tappable on empty zones, which made tap-to-pin impossible.
  final void Function(VehicleZone zone)? onZoneTap;
  final double height;
  final bool showLegend;

  const SpatialDamageHud({
    super.key,
    this.hotspots = const [],
    this.onHotspotTap,
    this.onZoneTap,
    this.height = 260,
    this.showLegend = true,
  });

  static IconData iconForKind(DamageKind kind) => switch (kind) {
    DamageKind.scratch => Icons.gesture_rounded,
    DamageKind.dent => Icons.warning_amber_rounded,
    DamageKind.glass => Icons.lightbulb_outline_rounded,
  };

  static String labelForKind(BuildContext context, DamageKind kind) {
    final t = SharedCoreL10n.of(context);
    return switch (kind) {
      DamageKind.scratch => t.damageKindScratch,
      DamageKind.dent => t.damageKindDent,
      DamageKind.glass => t.damageKindGlass,
    };
  }

  _DamageTone _toneFor(AppSemanticColors s, DamageKind kind) {
    final status = switch (kind) {
      DamageKind.scratch => s.warning,
      DamageKind.dent => s.danger,
      DamageKind.glass => s.info,
    };
    return _DamageTone(
      base: status.base,
      subtle: status.subtle,
      border: status.border,
      ink: status.ink,
    );
  }

  /// Resolves an empty-canvas tap to the nearest blueprint zone.
  ///
  /// Taps landing on an existing pin are ignored here — the pin's own
  /// gesture handles them — so a pin tap never also drops a new pin.
  void _handleZoneTap(
    Offset local,
    Size size,
    Map<VehicleZone, List<DamageHotspot>> byZone,
  ) {
    if (size.width <= 0 || size.height <= 0) return;
    VehicleZone? nearest;
    var nearestDist = double.infinity;
    for (final entry in _zoneAnchors.entries) {
      final fx = (entry.value.x + 1) / 2;
      final fy = (entry.value.y + 1) / 2;
      final dx = (local.dx - fx * size.width) / size.width;
      final dy = (local.dy - fy * size.height) / size.height;
      final dist = dx * dx + dy * dy;
      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = entry.key;
      }
    }
    if (nearest == null || nearestDist > 0.05) return;
    final anchor = _zoneAnchors[nearest]!;
    final pinCenter = Offset(
      ((anchor.x + 1) / 2) * size.width,
      ((anchor.y + 1) / 2) * size.height,
    );
    if (byZone.containsKey(nearest) &&
        (local - pinCenter).distance < 26) {
      return;
    }
    onZoneTap?.call(nearest);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semanticColors;

    // Group hotspots by zone so multiple points on one panel stack cleanly.
    final byZone = <VehicleZone, List<DamageHotspot>>{};
    for (final h in hotspots) {
      byZone.putIfAbsent(h.zone, () => []).add(h);
    }

    // The blueprint is physical and must not mirror — lock it to LTR.
    final diagram = Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, height);
          return SizedBox(
            width: size.width,
            height: size.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: onZoneTap == null
                  ? null
                  : (details) => _handleZoneTap(
                      details.localPosition,
                      size,
                      byZone,
                    ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _VehicleBlueprintPainter(
                        bodyFill: colors.surfaceContainerLow,
                        lineColor: colors.outline,
                        accentColor: colors.onSurfaceVariant,
                        windowColor: colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  for (final entry in byZone.entries)
                    _positionedPin(
                      context,
                      semantic,
                      entry.key,
                      entry.value,
                      size,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: diagram,
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: AppDimensions.s12),
          Wrap(
            spacing: AppDimensions.s16,
            runSpacing: AppDimensions.s8,
            children: [
              for (final kind in DamageKind.values)
                _LegendItem(
                  kind: kind,
                  tone: _toneFor(semantic, kind),
                  label: labelForKind(context, kind),
                  arabic: AppTypography.isArabic(
                    Localizations.maybeLocaleOf(context),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _positionedPin(
    BuildContext context,
    AppSemanticColors semantic,
    VehicleZone zone,
    List<DamageHotspot> items,
    Size size,
  ) {    final anchor = _zoneAnchors[zone]!;
    final primary = items.first;
    final tone = _toneFor(semantic, primary.kind);
    final count = items.length;

    // Convert the alignment anchor into a fractional position.
    final fx = (anchor.x + 1) / 2;
    final fy = (anchor.y + 1) / 2;

    const pin = 30.0;
    final left = (fx * size.width) - pin / 2;
    final top = (fy * size.height) - pin / 2;

    return Positioned(
      left: left,
      top: top,
      child: Semantics(
        button: onHotspotTap != null,
        label:
            '${labelForKind(context, primary.kind)}'
            '${primary.label != null ? ' — ${primary.label}' : ''}'
            '${count > 1 ? ' (+${count - 1})' : ''}',
        child: Tooltip(
          message: primary.label ?? labelForKind(context, primary.kind),
          child: GestureDetector(
            onTap: onHotspotTap == null ? null : () => onHotspotTap!(primary),
            child: Container(
              width: pin,
              height: pin,
              decoration: BoxDecoration(
                color: tone.base,
                shape: BoxShape.circle,
                border: Border.all(color: tone.subtle, width: 3),
                boxShadow: AppDimensions.shadowSurface,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(
                      iconForKind(primary.kind),
                      size: 15,
                      color: semantic.onPrimary,
                    ),
                  ),
                  if (count > 1)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.onSurface,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXs,
                          ),
                        ),
                        child: Text(
                          '$count',
                          style: AppTextStyles.captionMicro(
                            color: semantic.onPrimary,
                            arabic: AppTypography.isArabic(
                              Localizations.maybeLocaleOf(context),
                            ),
                          ).copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DamageTone {
  final Color base;
  final Color subtle;
  final Color border;
  final Color ink;
  const _DamageTone({
    required this.base,
    required this.subtle,
    required this.border,
    required this.ink,
  });
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.kind,
    required this.tone,
    required this.label,
    required this.arabic,
  });

  final DamageKind kind;
  final _DamageTone tone;
  final String label;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: tone.base,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
          ),
        ),
        const SizedBox(width: AppDimensions.s6),
        Text(
          label,
          style: AppTextStyles.metadata(
            color: context.colors.onSurfaceVariant,
            arabic: arabic,
          ),
        ),
      ],
    );
  }
}

class _VehicleBlueprintPainter extends CustomPainter {
  final Color bodyFill;
  final Color lineColor;
  final Color accentColor;
  final Color windowColor;

  const _VehicleBlueprintPainter({
    required this.bodyFill,
    required this.lineColor,
    required this.accentColor,
    required this.windowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final pad = 34.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;
    final left = pad;
    final top = pad;

    final bodyRect = Rect.fromLTWH(left + w * 0.10, top, w * 0.80, h);
    final body = RRect.fromRectAndRadius(bodyRect, const Radius.circular(30));

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = bodyFill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = lineColor;
    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accentColor;

    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    // Greenhouse / roof.
    final greenhouse = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.245, top + h * 0.22, w * 0.51, h * 0.56),
      const Radius.circular(20),
    );
    canvas.drawRRect(
      greenhouse,
      Paint()
        ..style = PaintingStyle.fill
        ..color = windowColor,
    );
    canvas.drawRRect(greenhouse, stroke);

    // Windshield + rear window divider lines.
    canvas.drawLine(
      Offset(left + w * 0.245, top + h * 0.36),
      Offset(left + w * 0.755, top + h * 0.36),
      accent,
    );
    canvas.drawLine(
      Offset(left + w * 0.245, top + h * 0.64),
      Offset(left + w * 0.755, top + h * 0.64),
      accent,
    );

    // Side mirrors.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.02, top + h * 0.30, w * 0.09, h * 0.06),
        const Radius.circular(4),
      ),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.89, top + h * 0.30, w * 0.09, h * 0.06),
        const Radius.circular(4),
      ),
      stroke,
    );

    // Wheels (four corners).
    final wheelPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withValues(alpha: 0.55);
    for (final fy in [0.16, 0.72]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + w * 0.04, top + h * fy, w * 0.07, h * 0.12),
          const Radius.circular(3),
        ),
        wheelPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + w * 0.89, top + h * fy, w * 0.07, h * 0.12),
          const Radius.circular(3),
        ),
        wheelPaint,
      );
    }

    // Headlights (front, top).
    final lightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = accentColor.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.30, top + h * 0.01, w * 0.14, h * 0.03),
        const Radius.circular(3),
      ),
      lightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.56, top + h * 0.01, w * 0.14, h * 0.03),
        const Radius.circular(3),
      ),
      lightPaint,
    );

    // Tail lights (rear, bottom).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.30, top + h * 0.96, w * 0.14, h * 0.03),
        const Radius.circular(3),
      ),
      lightPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w * 0.56, top + h * 0.96, w * 0.14, h * 0.03),
        const Radius.circular(3),
      ),
      lightPaint,
    );
  }

  @override
  bool shouldRepaint(_VehicleBlueprintPainter old) {
    return old.bodyFill != bodyFill ||
        old.lineColor != lineColor ||
        old.accentColor != accentColor ||
        old.windowColor != windowColor;
  }
}
