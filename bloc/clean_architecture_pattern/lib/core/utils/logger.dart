/// Simple Logger utility for debugging
class Logger {
  /// Log info messages
  static void info(String message, {String tag = 'INFO'}) {
    print('[$tag] $message');
  }

  /// Log error messages
  static void error(String message, {String tag = 'ERROR', Object? error}) {
    print('[$tag] $message');
    if (error != null) {
      print('Error details: $error');
    }
  }

  /// Log debug messages
  static void debug(String message, {String tag = 'DEBUG'}) {
    print('[$tag] $message');
  }

  /// Log warning messages
  static void warning(String message, {String tag = 'WARNING'}) {
    print('[$tag] $message');
  }
}
