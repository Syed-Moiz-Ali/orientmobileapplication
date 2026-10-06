import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/features/advisor/inspection_pages/data/models/vehicle_damage_map_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads all 25 mapped vector regions', () async {
    final map = await VehicleMapLoader.load();
    expect(map.viewBox.width, 1254);
    expect(map.viewBox.height, 1254);
    expect(map.parts, hasLength(25));
    expect(map.partById('hood')?.path.computeMetrics(), isNotEmpty);
  });

  test('canonical points hit expected panels and background misses', () async {
    final map = await VehicleMapLoader.load();
    expect(map.hitTest(const Offset(627, 200))?.id, 'hood');
    expect(map.hitTest(const Offset(627, 350))?.id, 'front_windshield');
    expect(map.hitTest(const Offset(340, 480))?.id, 'front_left_door');
    expect(map.hitTest(const Offset(914, 480))?.id, 'front_right_door');
    expect(map.hitTest(const Offset(340, 700))?.id, 'rear_left_door');
    expect(map.hitTest(const Offset(914, 700))?.id, 'rear_right_door');
    expect(map.hitTest(const Offset(10, 10)), isNull);
  });
}
