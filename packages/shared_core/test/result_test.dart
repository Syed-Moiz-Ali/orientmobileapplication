import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart';

void main() {
  group('Result', () {
    test('Success carries data through when()', () {
      const result = Success<int>(42);
      final value = result.when(
        success: (data) => data * 2,
        failure: (e) => -1,
      );
      expect(value, 84);
    });

    test('Failure carries the error through when()', () {
      const result = Failure<int>(NetworkException('boom'));
      final message = result.when(
        success: (_) => 'ok',
        failure: (e) => e.message,
      );
      expect(message, 'boom');
    });

    test('Exception subtypes keep their message', () {
      expect(const CacheException('c').message, 'c');
      expect(const ValidationException('v').message, 'v');
      expect(const UnknownException('u').message, 'u');
    });
  });
}
