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
    expect(RegExp(r'^INS-\d{4}-\d{2}-\d{2}-\d{4}$').hasMatch(id), isTrue);
  });

  test('increments within the same day', () async {
    final a = await IdGenerator.nextId('JC');
    final b = await IdGenerator.nextId('JC');
    final suffixA = int.parse(a.split('-').last);
    final suffixB = int.parse(b.split('-').last);
    expect(suffixB, suffixA + 1);
  });

  test('counters are separate per prefix', () async {
    final a = await IdGenerator.nextId('REM');
    final b = await IdGenerator.nextId('ATT');
    expect(a.split('-').first, 'REM');
    expect(b.split('-').first, 'ATT');
  });
}
