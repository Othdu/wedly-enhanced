import 'package:flutter/foundation.dart';

/// App-wide logging utility that only logs in debug mode
/// Replaces debugPrint() statements throughout the codebase
class AppLogger {
  static const String _tag = 'Wedly';

  /// Log debug information (blue)
  static void debug(String message, {String? tag}) {
    _log('🔵 DEBUG', tag ?? _tag, message);
  }

  /// Log info (green)
  static void info(String message, {String? tag}) {
    _log('🟢 INFO', tag ?? _tag, message);
  }

  /// Log warning (yellow)
  static void warning(String message, {String? tag}) {
    _log('🟡 WARNING', tag ?? _tag, message);
  }

  /// Log error (red)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('🔴 ERROR', tag ?? _tag, message);
    if (error != null) {
      _log('🔴 ERROR', tag ?? _tag, 'Error: $error');
    }
    if (stackTrace != null && kDebugMode) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log success (green checkmark)
  static void success(String message, {String? tag}) {
    _log('✅ SUCCESS', tag ?? _tag, message);
  }

  /// Log network request
  static void network(String method, String url, {String? tag}) {
    _log('🌐 NETWORK', tag ?? _tag, '$method: $url');
  }

  /// Log authentication events
  static void auth(String message, {String? tag}) {
    _log('🔐 AUTH', tag ?? _tag, message);
  }

  /// Log API response
  static void response(String message, {String? tag, int? statusCode}) {
    final status = statusCode != null ? '[$statusCode]' : '';
    _log('📥 RESPONSE', tag ?? _tag, '$status $message');
  }

  /// Log token operations (masked for security)
  static void token(String message, {String? tokenPreview}) {
    if (tokenPreview != null && tokenPreview.length > 20) {
      final masked = '${tokenPreview.substring(0, 8)}...${tokenPreview.substring(tokenPreview.length - 8)}';
      _log('🎫 TOKEN', _tag, '$message: $masked');
    } else {
      _log('🎫 TOKEN', _tag, message);
    }
  }

  /// Internal log method - only logs in debug mode
  static void _log(String level, String tag, String message) {
    if (kDebugMode) {
      debugPrint('$level [$tag] $message');
    }
  }
}
