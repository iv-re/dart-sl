import 'package:ctx/ctx.dart';
import 'package:sl/src/attr.dart';
import 'package:sl/src/level.dart';
import 'package:sl/src/record.dart';

/// Middleware function signature for transforming a [LogRecord] before it
/// is processed.
typedef LogHandlerMiddleware =
    LogRecord Function(Context ctx, LogRecord record);

/// Interface for processing and writing [LogRecord] entries.
abstract class LogHandler {
  /// Returns true if the handler is enabled for the given [level].
  bool enabled(Context ctx, LogLevel level);

  /// Processes and writes the [record].
  void handle(Context ctx, LogRecord record);

  /// Returns a new handler instance with additional persistent [attrs].
  LogHandler withAttrs(List<LogAttr> attrs);
}
