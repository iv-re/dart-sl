import 'package:ctx/ctx.dart';
import 'package:sl/src/logger.dart';

const _ctxLoggerKey = Object();

/// Extension to integrate [Logger] with [Context].
extension ContextLoggerExtension on Context {
  /// Returns a new context containing the specified [logger].
  Context withLogger(Logger logger) {
    return withValue(_ctxLoggerKey, logger);
  }

  /// Retrieves the [Logger] associated with this context.
  ///
  /// Throws an assertion error if no logger is present.
  Logger get logger {
    final logger = this[_ctxLoggerKey];
    assert(logger != null, 'No Logger found in Context');
    return logger! as Logger;
  }
}
