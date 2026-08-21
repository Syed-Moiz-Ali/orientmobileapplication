import 'dart:math';

class IdGenerator {
  static final Random _secureRandom = Random.secure();

  static Future<String> nextId(String prefix) async {
    return '$prefix-${_uuidV4()}';
  }

  static Future<void> resetCache() async {
    // Kept for backwards compatibility with older tests/callers. UUID based
    // generation has no process-local cache to reset.
  }

  static String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
