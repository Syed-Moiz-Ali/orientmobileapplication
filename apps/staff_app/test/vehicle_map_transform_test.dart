import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/advisor/inspection_pages/presentation/vehicle_map/vehicle_map_transform.dart';

void main() {
  const box = Rect.fromLTWH(0, 0, 1254, 1254);

  for (final size in const [
    Size(1254, 1254),
    Size(627, 627),
    Size(360, 360),
    Size(320, 320),
    Size(900, 900),
    Size(700, 500),
    Size(500, 700),
    Size(1000, 500),
    Size(600, 900),
  ]) {
    test('round trips map and normalized coordinates at $size', () {
      final transform = VehicleMapTransform(viewBox: box, viewport: size);
      const original = Offset(356, 612);
      final displayed = transform.mapToDisplay(original);
      final restored = transform.displayToMap(displayed)!;
      expect(restored.dx, closeTo(original.dx, 0.001));
      expect(restored.dy, closeTo(original.dy, 0.001));
      final normalized = transform.mapToNormalized(original);
      final normalizedDisplay = transform.normalizedToDisplay(normalized);
      expect(normalizedDisplay.dx, closeTo(displayed.dx, 0.001));
      expect(normalizedDisplay.dy, closeTo(displayed.dy, 0.001));
    });
  }

  test('BoxFit contain margins are outside the canonical map', () {
    final transform = VehicleMapTransform(
      viewBox: box,
      viewport: const Size(700, 500),
    );
    expect(transform.renderedRect, const Rect.fromLTWH(100, 0, 500, 500));
    expect(transform.displayToMap(const Offset(50, 250)), isNull);
    expect(transform.displayToMap(const Offset(650, 250)), isNull);
  });
}
