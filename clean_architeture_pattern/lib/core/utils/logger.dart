/// Simple logger for debugging
class Logger {
  static void log(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag]' : '[LOG]';
    print('$prefix $message');
  }

  static void error(String message, {String? tag, Object? error}) {
    final prefix = tag != null ? '[$tag]' : '[ERROR]';
    print('$prefix $message');
    if (error != null) print('Error details: $error');
  }

  static void info(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag]' : '[INFO]';
    print('$prefix $message');
  }
}
