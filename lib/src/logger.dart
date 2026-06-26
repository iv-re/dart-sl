import 'package:ctx/ctx.dart';
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
  void debug(
    String message, {
    List<LogAttr> attrs = const [],
    Context? ctx,
  }) {
    log(.debug, message, attrs: attrs, ctx: ctx);
  }

  /// Logs a message at [LogLevel.info] with optional attributes.
  void info(
    String message, {
    List<LogAttr> attrs = const [],
    Context? ctx,
  }) {
    log(.info, message, attrs: attrs, ctx: ctx);
  }

  /// Logs a message at [LogLevel.warn] with optional attributes.
  void warn(
    String message, {
    List<LogAttr> attrs = const [],
    Context? ctx,
  }) {
    log(.warn, message, attrs: attrs, ctx: ctx);
  }

  /// Logs a message at [LogLevel.error] with optional attributes.
  void error(
    String message, {
    List<LogAttr> attrs = const [],
    Context? ctx,
  }) {
    log(.error, message, attrs: attrs, ctx: ctx);
  }

  /// Logs a message at a specific [level] with optional [attrs].
  void log(
    LogLevel level,
    String message, {
    List<LogAttr> attrs = const [],
    Context? ctx,
  }) {
    if (!_handler.enabled(ctx ?? const .empty(), level)) return;
    _handler.handle(
      ctx ?? const .empty(),
      LogRecord(
        level: level,
        message: message,
        time: .now(),
        attrs: attrs,
      ),
    );
  }
}
