import 'package:ctx/ctx.dart';
import 'package:sl/src/attr.dart';
import 'package:sl/src/handler.dart';
import 'package:sl/src/level.dart';
import 'package:sl/src/record.dart';

/// A log handler that duplicates and routes [LogRecord] entries
/// to multiple downstream handlers.
final class LogMultiHandler implements LogHandler {
  /// Creates a multi-handler with the given list of downstream [handlers].
  const LogMultiHandler(this.handlers);

  /// The downstream handlers to route records to.
  final List<LogHandler> handlers;

  @override
  bool enabled(Context ctx, LogLevel level) {
    return handlers.any((handler) => handler.enabled(ctx, level));
  }

  @override
  void handle(Context ctx, LogRecord record) {
    for (final handler in handlers) {
      if (handler.enabled(ctx, record.level)) {
        handler.handle(ctx, record);
      }
    }
  }

  @override
  LogHandler withAttrs(List<LogAttr> attrs) {
    return LogMultiHandler(
      handlers.map((handler) => handler.withAttrs(attrs)).toList(),
    );
  }

  @override
  LogHandler withGroup(String name) {
    return LogMultiHandler(
      handlers.map((handler) => handler.withGroup(name)).toList(),
    );
  }
}
