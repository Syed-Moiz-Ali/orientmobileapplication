import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final class AppErrorHandler {
  AppErrorHandler._();

  static void init(Logger logger) {
    _handlePlatformErrors(logger);
    _handleFlutterErrors(logger);
    _overrideErrorWidget(logger);
  }

  static void _handlePlatformErrors(Logger logger) {
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e('Unhandled platform error', error: error, stackTrace: stack);
      return true;
    };
  }

  static void _handleFlutterErrors(Logger logger) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logger.e(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
  }

  static void _overrideErrorWidget(Logger logger) {
    ErrorWidget.builder = (details) {
      logger.e(
        'Widget build error',
        error: details.exception,
        stackTrace: details.stack,
      );
      return _buildErrorScreen(details);
    };
  }

  static Widget _buildErrorScreen(FlutterErrorDetails details) {
    return Material(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode ? details.exceptionAsString() : 'Please restart the application.',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
