// Platform-agnostic file helpers so widgets compile on web (where
// dart:io is unavailable). On web these are all no-ops.
export 'file_ops_stub.dart' if (dart.library.io) 'file_ops_io.dart';
