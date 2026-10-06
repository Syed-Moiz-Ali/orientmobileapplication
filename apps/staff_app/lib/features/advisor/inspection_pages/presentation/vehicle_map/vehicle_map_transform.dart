import 'dart:ui';

class VehicleMapTransform {
  final Rect viewBox;
  final Size viewport;
  late final double scale = _scale();
  late final Rect renderedRect = Rect.fromLTWH(
    (viewport.width - viewBox.width * scale) / 2,
    (viewport.height - viewBox.height * scale) / 2,
    viewBox.width * scale,
    viewBox.height * scale,
  );

  VehicleMapTransform({required this.viewBox, required this.viewport});

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

  Offset mapToNormalized(Offset map) => Offset(
    ((map.dx - viewBox.left) / viewBox.width).clamp(0, 1),
    ((map.dy - viewBox.top) / viewBox.height).clamp(0, 1),
  );

  Offset normalizedToMap(Offset normalized) => Offset(
    viewBox.left + normalized.dx.clamp(0, 1) * viewBox.width,
    viewBox.top + normalized.dy.clamp(0, 1) * viewBox.height,
  );

  Offset normalizedToDisplay(Offset normalized) =>
      mapToDisplay(normalizedToMap(normalized));
}
