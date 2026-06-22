import 'package:sl/src/attr.dart';
import 'package:sl/src/handler.dart';
import 'package:sl/src/level.dart';
import 'package:sl/src/record.dart';

/// Controller that coordinates logging calls and delegates to a [LogHandler].
final class Logger {
  /// Creates a logger using the provided [_handler].
  const Logger({
    required this._handler,
  });

  final LogHandler _handler;

  /// Spawns a child logger with additional persistent [attrs].
  Logger withAttrs(List<LogAttr> attrs) {
    return Logger(handler: _handler.withAttrs(attrs));
  }

  /// Logs a message at [LogLevel.debug] with optional attributes.
  void debug(String message, [List<LogAttr> attrs = const []]) {
    log(.debug, message, attrs);
  }

  /// Logs a message at [LogLevel.info] with optional attributes.
  void info(String message, [List<LogAttr> attrs = const []]) {
    log(.info, message, attrs);
  }

  /// Logs a message at [LogLevel.warn] with optional attributes.
  void warn(String message, [List<LogAttr> attrs = const []]) {
    log(.warn, message, attrs);
  }

  /// Logs a message at [LogLevel.error] with optional attributes.
  void error(String message, [List<LogAttr> attrs = const []]) {
    log(.error, message, attrs);
  }

  /// Logs a message at a specific [level] with optional [attrs].
  void log(LogLevel level, String message, [List<LogAttr> attrs = const []]) {
    if (!_handler.enabled(level)) return;
    _handler.handle(
      LogRecord(
        level: level,
        message: message,
        time: .now(),
        attrs: attrs,
      ),
    );
  }
}
