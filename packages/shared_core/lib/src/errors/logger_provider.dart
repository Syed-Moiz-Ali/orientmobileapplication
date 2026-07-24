import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

Logger createLogger() {
  return Logger(
    level: kDebugMode ? Level.trace : Level.warning,
    printer: PrettyPrinter(
      errorMethodCount: kDebugMode ? 5 : 3,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}

final loggerProvider = Provider<Logger>((_) => createLogger());
