import 'package:logging/logging.dart' as logging;
import 'package:sl/sl.dart';

LogLevel _mapLevel(logging.Level level) {
  if (level >= logging.Level.SEVERE) return LogLevel.error;
  if (level >= logging.Level.WARNING) return LogLevel.warn;
  if (level >= logging.Level.INFO) return LogLevel.info;
  return LogLevel.debug;
}

/// Bridges logs from Dart's standard [logging.Logger] to [Logger].
final class StdLoggerBridge implements LogBridge {
  /// Creates a standard logging bridge.
  ///
  /// By default, it captures logs from the root logger ([logging.Logger.root]).
  /// Set [source] to listen to a specific standard logger instead.
  ///
  /// [nameKey] defines the key under which the standard logger's name
  /// is stored as a [LogAttr]. Defaults to `'component'`.
  /// Set [nameKey] to `null` to ignore the standard logger's name.
  const StdLoggerBridge({
    this.source,
    this.nameKey = 'component',
  });

  /// The standard logger to listen to.
  final logging.Logger? source;

  /// The attribute key for the standard logger name.
  final String? nameKey;

  @override
  void Function() attach(Logger logger) {
    final src = source ?? logging.Logger.root;
    final nameKey = this.nameKey;

    final subscription = src.onRecord.listen((record) {
      final level = _mapLevel(record.level);
      final attrs = <LogAttr>[
        if (nameKey != null && record.loggerName.isNotEmpty)
          .string(nameKey, record.loggerName),
        if (record.error != null) .error(record.error!),
        if (record.stackTrace != null) .stackTrace(record.stackTrace!),
      ];
      logger.log(level, record.message, attrs: attrs);
    });

    return subscription.cancel;
  }
}
