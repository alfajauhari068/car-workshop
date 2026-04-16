import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Central logging utility for the application
/// All logging must go through this class
class Logger {
  static const String _tag = '🚗CarWorkshop';

  /// Log info level
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ℹ️ INFO', message, error, stackTrace);
  }

  /// Log warning level
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('⚠️ WARNING', message, error, stackTrace);
  }

  /// Log error level
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('❌ ERROR', message, error, stackTrace);
  }

  /// Log success level
  static void success(String message) {
    _log('✅ SUCCESS', message, null, null);
  }

  /// Log debug level
  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      _log('🐛 DEBUG', message, data, null);
    }
  }

  /// Internal logging method
  static void _log(
    String level,
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    final timestamp = DateTime.now().toString();
    final fullMessage = '[$timestamp] $_tag $level: $message';

    // Print to console
    if (kDebugMode) {
      print(fullMessage);
      if (error != null) {
        print('  Error: $error');
      }
      if (stackTrace != null) {
        print('  StackTrace: $stackTrace');
      }
    }

    // Log to native log (Android Logcat / iOS Console)
    developer.log(
      fullMessage,
      error: error,
      stackTrace: stackTrace,
      name: _tag,
    );
  }

  /// Log feature entry
  static void featureEntry(String feature, Map<String, dynamic>? params) {
    final paramStr = params?.entries.map((e) => '${e.key}=${e.value}').join(', ');
    info('→ ENTER: $feature ${paramStr ?? ''}');
  }

  /// Log feature exit
  static void featureExit(String feature, dynamic result) {
    info('← EXIT: $feature | Result: $result');
  }

  /// Log repository operation
  static void repository(String operation, String collection, Map<String, dynamic>? data) {
    final dataStr = data?.toString() ?? '';
    info('📦 REPOSITORY: $operation($collection) $dataStr');
  }
}
