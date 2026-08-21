import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('id_generator_test');
    Hive.init(tempDir.path);
    await Hive.openBox<int>('id_counters');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    await IdGenerator.resetCache();
    await Hive.box<int>('id_counters').clear();
  });

  test('generates prefixed, zero-padded ids', () async {
    final id = await IdGenerator.nextId('INS');
    expect(
      RegExp(
        r'^INS-[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      ).hasMatch(id),
      isTrue,
    );
  });

  test('generates collision-resistant ids instead of local counters', () async {
    final a = await IdGenerator.nextId('JC');
    final b = await IdGenerator.nextId('JC');
    expect(a, isNot(b));
    expect(a, isNot(contains(RegExp(r'\d{4}-\d{2}-\d{2}-\d{4}$'))));
    expect(b, isNot(contains(RegExp(r'\d{4}-\d{2}-\d{2}-\d{4}$'))));
  });

  test('counters are separate per prefix', () async {
    final a = await IdGenerator.nextId('REM');
    final b = await IdGenerator.nextId('ATT');
    expect(a.split('-').first, 'REM');
    expect(b.split('-').first, 'ATT');
  });
}
