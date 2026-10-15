import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/hud_pin_bridge.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_map_transform.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Phase 08 — real top-view damage canvas (Archetype 6 capture surface).
///
/// Vector-first: the 25 JSON regions (`advisor_car_top_mapping.json`) ARE
/// the car — every zone paints as a body panel straight from its `svgPath`,
/// so the vehicle always renders (including web, where the legacy embedded
/// raster never paints and only severity-tint blobs were left behind).
/// Damaged zones tint by worst severity through the frozen
/// `damageMinor/damageModerate/damageSevere` theme roles; pins ride the
/// existing `vehicleBodyCondition.parts` payload with zero contract change.
///
/// The physical geometry is LTR-locked (spec §2.2 exception 1): markers use
/// physical `Positioned(left/top)` inside an LTR [Directionality], so the
/// driver side never mirrors in AR RTL. Zoom is a bounded pinch
/// ([InteractiveViewer] 1×–4×) with +/- steppers and a 48dp reset-view
/// control. Desktop pointers get a hover ring per zone; the selected
/// finding gets a 2px focus outline plus a part-label chip.
class RealDamageCanvas extends StatefulWidget {
  final Map<String, VehiclePartInspection> inspections;
  final bool editable;
  final double? height;
  final Future<VehicleMapDefinition>? definitionFuture;
  final void Function(VehicleMapPart part, Offset normalized)? onPartTap;
  final ValueChanged<VehicleDamageFinding>? onFindingTap;

  /// The currently selected finding id (one selected object shared with the
  /// pins rail). Selection is presentation-only: persistence still flows
  /// through the inspection provider with zero contract change.
  final String? selectedFindingId;

  /// Keyboard commit: Enter on the focused canvas opens the edit sheet
  /// for the selected pin (arrows move the selection). Tab reaches the
  /// canvas through the default traversal; Esc is handled by the drawer
  /// and sheet routes.
  final ValueChanged<VehicleDamageFinding>? onFindingEdit;

  /// External zoom controller (the studio title row drives zoom/reset).
  /// When null the canvas owns its controller internally.
  final TransformationController? transformationController;

  const RealDamageCanvas({
    super.key,
    required this.inspections,
    this.editable = true,
    this.height,
    this.definitionFuture,
    this.onPartTap,
    this.onFindingTap,
    this.selectedFindingId,
    this.onFindingEdit,
    this.transformationController,
  });

  @override
  State<RealDamageCanvas> createState() => _RealDamageCanvasState();
}

class _RealDamageCanvasState extends State<RealDamageCanvas> {
  TransformationController? _ownedZoom;
  late Future<VehicleMapDefinition> _definition;

  TransformationController get _zoom =>
      widget.transformationController ?? (_ownedZoom ??= TransformationController());

  @override
  void initState() {
    super.initState();
    // An explicitly injected definition future (tests, previews) is
    // honored on entry, so loading/error branches stay deterministic
    // and hermetic; otherwise the ambient loader cache serves repeat
    // renders with no loading flash.
    _definition = widget.definitionFuture ?? VehicleMapLoader.load();
  }

  @override
  void didUpdateWidget(covariant RealDamageCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.definitionFuture != oldWidget.definitionFuture &&
        widget.definitionFuture != null) {
      _definition = widget.definitionFuture!;
    }
  }

  @override
  void dispose() {
    _ownedZoom?.dispose();
    super.dispose();
  }

  void _retry() {
    HapticFeedback.selectionClick();
    // Resolve the reload future BEFORE setState: an arrow closure returning
    // the Future trips setState's sync-callback contract (FlutterError).
    final next = VehicleMapLoader.reload();
    setState(() {
      _definition = next;
    });
  }

  /// Zoom/reset entry points for the external studio title row.
  void resetView() {
    HapticFeedback.selectionClick();
    _zoom.value = Matrix4.identity();
  }

  void stepZoom(double factor) {
    HapticFeedback.selectionClick();
    final next = (_zoom.value.getMaxScaleOnAxis() * factor).clamp(1.0, 4.0);
    _zoom.value = Matrix4.identity()..scaleByDouble(next, next, next, 1);
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    // Repeat renders reuse the parsed definition synchronously — no
    // future round-trip, no loading flash when switching tabs.
    final cached = widget.definitionFuture == null
        ? VehicleMapLoader.cached
        : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height =
            widget.height ??
            (constraints.maxHeight.isFinite ? constraints.maxHeight : 420.0);
        return SizedBox(
          width: double.infinity,
          height: height,
          child: cached != null
              ? _LoadedMap(
                  definition: cached,
                  inspections: widget.inspections,
                  editable: widget.editable,
                  zoom: _zoom,
                  onPartTap: widget.editable ? widget.onPartTap : null,
                  onFindingTap: widget.editable ? widget.onFindingTap : null,
                  onFindingEdit: widget.editable ? widget.onFindingEdit : null,
                  selectedFindingId: widget.selectedFindingId,
                  boxHeight: height,
                )
              : FutureBuilder<VehicleMapDefinition>(
                  future: _definition,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      // Never blank: the error card always offers retry.
                      return EmptyState.error(
                        message: t.advisorDamageMapError,
                        onRetry: _retry,
                      );
                    }
                    if (!snapshot.hasData) {
                      // Visible loading status (not screen-reader-only):
                      // asset decode of the 25-zone map can take a beat.
                      return Semantics(
                        label: t.advisorDamageMapLoading,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const LoadingIndicator(),
                              const SizedBox(height: 8),
                              Text(
                                t.advisorDamageMapLoading,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return _LoadedMap(
                      definition: snapshot.data!,
                      inspections: widget.inspections,
                      editable: widget.editable,
                      zoom: _zoom,
                      onPartTap: widget.editable ? widget.onPartTap : null,
                      onFindingTap:
                          widget.editable ? widget.onFindingTap : null,
                      onFindingEdit:
                          widget.editable ? widget.onFindingEdit : null,
                      selectedFindingId: widget.selectedFindingId,
                      boxHeight: height,
                    );
                  },
                ),
        );
      },
    );
  }
}

/// Resolved paint for one car zone: category base, overridden by the worst
/// severity tint, then by hover/selection focus. Theme colors only.
class _PanelLook {
  final Color fill;
  final Color stroke;
  final double strokeWidth;

  const _PanelLook({
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
  });
}

class _LoadedMap extends StatefulWidget {
  final VehicleMapDefinition definition;
  final Map<String, VehiclePartInspection> inspections;
  final bool editable;
  final TransformationController zoom;
  final void Function(VehicleMapPart part, Offset normalized)? onPartTap;
  final ValueChanged<VehicleDamageFinding>? onFindingTap;
  final ValueChanged<VehicleDamageFinding>? onFindingEdit;
  final String? selectedFindingId;
  final double boxHeight;

  const _LoadedMap({
    required this.definition,
    required this.inspections,
    required this.editable,
    required this.zoom,
    required this.onPartTap,
    required this.onFindingTap,
    required this.onFindingEdit,
    required this.selectedFindingId,
    required this.boxHeight,
  });

  @override
  State<_LoadedMap> createState() => _LoadedMapState();
}

class _LoadedMapState extends State<_LoadedMap> {
  String? _hoverPartId;
  final FocusNode _canvasFocus = FocusNode(
    debugLabel: 'damage-map-canvas',
  );

  @override
  void dispose() {
    _canvasFocus.dispose();
    super.dispose();
  }

  /// Keyboard pin walk: arrows move the shared selection, Enter commits
  /// to the edit sheet. Tab reaches the canvas via default traversal.
  KeyEventResult _onCanvasKey(
    FocusNode node,
    KeyEvent event,
    List<VehicleDamageFinding> ordered,
  ) {
    if (event is! KeyDownEvent || !widget.editable || ordered.isEmpty) {
      return KeyEventResult.ignored;
    }
    final current = ordered.indexWhere((f) => f.id == widget.selectedFindingId);
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      HapticFeedback.selectionClick();
      final next = ordered[(current + 1).clamp(0, ordered.length - 1)];
      widget.onFindingTap?.call(next);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      HapticFeedback.selectionClick();
      final prev = ordered[(current - 1).clamp(0, ordered.length - 1)];
      widget.onFindingTap?.call(prev);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final selected = _selectedFinding();
      if (selected != null && widget.onFindingEdit != null) {
        HapticFeedback.mediumImpact();
        widget.onFindingEdit!(selected);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  _PanelLook _lookFor(
    BuildContext context,
    VehicleMapPart part,
    AppStatusColors? tone,
  ) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    Color fill;
    Color stroke = colors.outlineVariant;
    var width = 1.25;
    switch (part.category) {
      case VehiclePartCategory.glass:
        fill = colors.primaryContainer;
      case VehiclePartCategory.wheel:
        fill = colors.onSurfaceVariant;
        stroke = colors.onSurface;
      case VehiclePartCategory.light:
        fill = semantic.warning.base.withValues(alpha: 0.30);
      case VehiclePartCategory.body:
      case VehiclePartCategory.mirror:
      case VehiclePartCategory.other:
        fill = colors.surface;
    }
    if (tone != null) {
      fill = tone.base.withValues(alpha: 0.38);
      stroke = tone.base;
      width = 2.5;
    }
    final hovered = widget.editable && _hoverPartId == part.id;
    final selected = _selectedPartId() == part.id;
    if (hovered && tone == null) {
      fill = colors.primary.withValues(alpha: 0.14);
      stroke = colors.primary;
      width = 2;
    }
    if (selected) {
      // 2px+ focus outline in the action color over any tint.
      stroke = colors.primary;
      width = 3;
      if (tone == null) fill = colors.primary.withValues(alpha: 0.16);
    }
    return _PanelLook(fill: fill, stroke: stroke, strokeWidth: width);
  }

  String? _selectedPartId() {
    final id = widget.selectedFindingId;
    if (id == null) return null;
    for (final entry in widget.inspections.entries) {
      if (entry.value.findings.any((f) => f.id == id)) return entry.key;
    }
    return null;
  }

  VehicleDamageFinding? _selectedFinding() {
    final id = widget.selectedFindingId;
    if (id == null) return null;
    for (final inspection in widget.inspections.values) {
      for (final f in inspection.findings) {
        if (f.id == id) return f;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final semantic = context.semanticColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, widget.boxHeight);
        final transform = VehicleMapTransform(
          viewBox: definitionViewBox,
          viewport: size,
        );

        // Worst severity per part → frozen theme tone (never raw hex).
        final tones = <String, AppStatusColors>{};
        for (final part in widget.definition.parts) {
          final worst = worstSeverity(
            widget.inspections[part.id]?.findings ?? const [],
          );
          if (worst != null) {
            tones[part.id] = damageSeverityTone(semantic, worst);
          }
        }
        final looks = <String, _PanelLook>{
          for (final part in widget.definition.parts)
            part.id: _lookFor(context, part, tones[part.id]),
        };

        // Flattened findings in part order → stable pin numbers.
        final ordered = <VehicleDamageFinding>[];
        for (final part in widget.definition.parts) {
          final findings = widget.inspections[part.id]?.findings ?? const [];
          ordered.addAll(findings);
        }
        // Findings on unknown part ids (intake free parts, stale drafts)
        // join after the mapped ones so no pin is ever silently dropped.
        final known = widget.definition.parts.map((p) => p.id).toSet();
        widget.inspections.forEach((partId, inspection) {
          if (!known.contains(partId)) ordered.addAll(inspection.findings);
        });

        final markerPoints = <String, Offset>{
          for (final f in ordered)
            f.id: transform.normalizedToDisplay(
              Offset(f.normalizedX, f.normalizedY),
            ),
        };
        final selected = _selectedFinding();
        final selectedPoint = selected == null
            ? null
            : markerPoints[selected.id];

        return Directionality(
          // Physical geometry is fixed: never mirrors in AR RTL (§2.2.1).
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: widget.zoom,
                  minScale: 1,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(24),
                  panEnabled: widget.editable,
                  scaleEnabled: widget.editable,
                  child: Focus(
                    focusNode: _canvasFocus,
                    onKeyEvent: (node, event) =>
                        _onCanvasKey(node, event, ordered),
                    child: Semantics(
                      button: false,
                      label: t.advisorHudTabDamage,
                      child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: widget.onPartTap == null
                        ? null
                        : (details) {
                            final local = details.localPosition;
                            // Pin taps belong to the pin widgets below:
                            // ignore canvas taps landing on a pin.
                            for (final point in markerPoints.values) {
                              if ((local - point).distance < 24) return;
                            }
                            final mapPoint = transform.displayToMap(local);
                            if (mapPoint == null) return;
                            final part = widget.definition.hitTest(mapPoint);
                            if (part == null) return;
                            HapticFeedback.mediumImpact();
                            widget.onPartTap!(
                              part,
                              transform.mapToNormalized(mapPoint),
                            );
                          },
                    child: MouseRegion(
                      // Desktop hover ring per zone (no-op on touch).
                      onHover: widget.editable
                          ? (event) {
                              final mapPoint = transform.displayToMap(
                                event.localPosition,
                              );
                              final part = mapPoint == null
                                  ? null
                                  : widget.definition.hitTest(mapPoint);
                              final id = part?.id;
                              if (id != _hoverPartId) {
                                setState(() => _hoverPartId = id);
                              }
                            }
                          : null,
                      onExit: widget.editable
                          ? (_) {
                              if (_hoverPartId != null) {
                                setState(() => _hoverPartId = null);
                              }
                            }
                          : null,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CarBodyPainter(
                                definition: widget.definition,
                                looks: looks,
                                transform: transform,
                              ),
                            ),
                          ),
                          for (var i = 0; i < ordered.length; i++)
                            if (markerPoints.containsKey(ordered[i].id))
                              _MapPin(
                                finding: ordered[i],
                                number: i + 1,
                                center: markerPoints[ordered[i].id]!,
                                selected:
                                    ordered[i].id == widget.selectedFindingId,
                                onTap: widget.onFindingTap == null
                                    ? null
                                    : () {
                                        // Focus follows interaction so arrow
                                        // keys walk pins right after a tap.
                                        _canvasFocus.requestFocus();
                                        widget.onFindingTap!(ordered[i]);
                                      },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ),
              // Selected-zone label chip (part name): the focus outline's
              // caption, clamped inside the canvas.
              if (selected != null && selectedPoint != null)
                Positioned(
                  left: (selectedPoint.dx - 80).clamp(
                    8.0,
                    (size.width - 168).clamp(8.0, double.infinity),
                  ),
                  top: (selectedPoint.dy - 96).clamp(8.0, double.infinity),
                  child: _SelectedChip(finding: selected),
                ),
            ],
          ),
        );
      },
    );
  }

  Rect get definitionViewBox => widget.definition.viewBox;
}
/// Selected-zone caption: localized part name + severity pill.
class _SelectedChip extends StatelessWidget {
  final VehicleDamageFinding finding;

  const _SelectedChip({required this.finding});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final tone = damageSeverityTone(context.semanticColors, finding.severity);

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppDimensions.r8),
        border: Border.all(color: colors.primary, width: 1.5),
        boxShadow: AppDimensions.shadowSurface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              damagePartLabel(t, finding.partId),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: tone.base, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

/// A map pin (teardrop with number, severity color) — never a blob: the
/// teardrop tip lands exactly on the damage point.
class _MapPin extends StatelessWidget {
  final VehicleDamageFinding finding;
  final int number;
  final Offset center;
  final bool selected;
  final VoidCallback? onTap;

  const _MapPin({
    required this.finding,
    required this.number,
    required this.center,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final tone = damageSeverityTone(context.semanticColors, finding.severity);

    // 48dp hit target; the painted pin is 36×44 with its tip on the point.
    return Positioned(
      left: center.dx - 24,
      top: center.dy - 44,
      child: Semantics(
        button: onTap != null,
        selected: selected,
        label:
            '${damageKindLabel(t, finding.damageType)} — ${damageSeverityLabel(t, finding.severity)}',
        child: GestureDetector(
          key: ValueKey('damage-marker-${finding.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!();
                },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: CustomPaint(
                size: const Size(36, 44),
                painter: _PinShapePainter(
                  fill: tone.base,
                  // FIXED-INK: white selection ring on the saturated pin
                  // fill keeps contrast in both themes by construction.
                  ring: selected ? Colors.white : tone.subtle,
                  selected: selected,
                ),
                child: SizedBox(
                  width: 36,
                  height: 44,
                  child: Align(
                    alignment: const Alignment(0, -0.42),
                    child: Text(
                      '$number',
                      style: TextStyle(
                        // FIXED-INK: white number on the saturated pin fill.
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinShapePainter extends CustomPainter {
  final Color fill;
  final Color ring;
  final bool selected;

  const _PinShapePainter({
    required this.fill,
    required this.ring,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Teardrop: head circle + converging tip at the exact damage point.
    final head = Offset(size.width / 2, size.height * 0.36);
    const radius = 13.0;
    final path = Path()
      ..moveTo(head.dx - radius * 0.92, head.dy + radius * 0.42)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(head.dx + radius * 0.92, head.dy + radius * 0.42)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawCircle(head, radius, Paint()..color = fill);
    canvas.drawCircle(
      head,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3 : 2
        ..color = ring,
    );
  }

  @override
  bool shouldRepaint(covariant _PinShapePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.selected != selected;
}

/// The car itself: every JSON zone paints as a body panel (category base),
/// severity tints override per worst finding. No raster dependency — the
/// vehicle renders identically on mobile, desktop and web.
class _CarBodyPainter extends CustomPainter {
  final VehicleMapDefinition definition;
  final Map<String, _PanelLook> looks;
  final VehicleMapTransform transform;

  const _CarBodyPainter({
    required this.definition,
    required this.looks,
    required this.transform,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(transform.renderedRect.left, transform.renderedRect.top);
    canvas.scale(transform.scale, transform.scale);
    canvas.translate(-definition.viewBox.left, -definition.viewBox.top);
    for (final part in definition.parts) {
      final look = looks[part.id];
      if (look == null) continue;
      canvas.drawPath(
        part.path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = look.fill,
      );
      canvas.drawPath(
        part.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = look.strokeWidth / transform.scale
          ..color = look.stroke,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CarBodyPainter oldDelegate) =>
      oldDelegate.looks != looks ||
      oldDelegate.transform.viewport != transform.viewport;
}
