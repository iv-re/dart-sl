import 'package:sl/src/attr.dart';
import 'package:sl/src/level.dart';
import 'package:sl/src/record.dart';

/// Interface for processing and writing [LogRecord] entries.
abstract class LogHandler {
  /// Returns true if the handler is enabled for the given [level].
  bool enabled(LogLevel level);

  /// Processes and writes the [record].
  void handle(LogRecord record);

  /// Returns a new handler instance with additional persistent [attrs].
  LogHandler withAttrs(List<LogAttr> attrs);
}
