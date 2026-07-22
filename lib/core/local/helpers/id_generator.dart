import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class IdGenerator {
  static int _lastCounter = -1;
  static String _lastPrefix = '';
  static String _lastDate = '';

  static Future<String> nextId(String prefix) async {
    final box = Hive.box('id_counters');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final key = '${prefix}_$today';

    int next;
    if (_lastPrefix == prefix && _lastDate == today && _lastCounter > 0) {
      next = _lastCounter + 1;
    } else {
      next = (box.get(key, defaultValue: 0) as int) + 1;
    }

    await box.put(key, next);
    _lastCounter = next;
    _lastPrefix = prefix;
    _lastDate = today;

    return '$prefix-$today-${next.toString().padLeft(4, '0')}';
  }

  static Future<void> resetCache() async {
    _lastCounter = -1;
    _lastPrefix = '';
    _lastDate = '';
  }
}
