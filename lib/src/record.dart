import 'package:sl/src/attr.dart';
import 'package:sl/src/level.dart';

/// A single log entry with its severity, message, timestamp, and metadata.
final class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.time,
    required this.attrs,
  });

  /// Severity of the log record.
  final LogLevel level;

  /// The log message.
  final String message;

  /// Timestamp when the record was created.
  final DateTime time;

  /// Key-value metadata attributes.
  final List<LogAttr> attrs;

  /// Creates a copy of this [LogRecord] with the given fields replaced by
  /// the new values.
  LogRecord copyWith({
    LogLevel? level,
    String? message,
    DateTime? time,
    List<LogAttr>? attrs,
  }) {
    return LogRecord(
      level: level ?? this.level,
      message: message ?? this.message,
      time: time ?? this.time,
      attrs: attrs ?? this.attrs,
    );
  }
}
