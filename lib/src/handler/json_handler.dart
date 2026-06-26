import 'dart:convert';
import 'dart:io';

import 'package:ctx/ctx.dart';
import 'package:sl/sl.dart';
import 'package:sl/src/stack_trace.dart';

/// Formats [LogRecord] entries as line-delimited JSON
/// and writes them to [sink].
final class LogJsonHandler implements LogHandler {
  /// Creates a JSON-formatting handler.
  LogJsonHandler({
    this.level = .info,
    IOSink? sink,
    this.attrs = const [],
    this.middlewares = const [],
    this.addSource = false,
  }) : sink = sink ?? stdout;

  /// Minimum level required for logs to be emitted.
  final LogLevel level;

  /// Output destination for logs.
  final IOSink sink;

  /// Persistent attributes appended to all records.
  final List<LogAttr> attrs;

  /// Middlewares to transform the [LogRecord] before it is written.
  final List<LogHandlerMiddleware> middlewares;

  /// Whether to include the source code location in logs.
  final bool addSource;

  @override
  bool enabled(Context ctx, LogLevel level) => level >= this.level;

  @override
  void handle(Context ctx, LogRecord record) {
    var resolvedRecord = record;
    for (final middleware in middlewares) {
      resolvedRecord = middleware(ctx, resolvedRecord);
    }
    final map = <String, Object>{
      'time': resolvedRecord.time.toUtc().toIso8601String(),
      'level': resolvedRecord.level.label,
      'msg': resolvedRecord.message,
    };

    resolvedRecord.attrs._addToMap(map);
    attrs._addToMap(map);

    if (addSource) {
      if (findCallerFrame() case final callerFrame?) {
        map['source'] = {
          'file': callerFrame.callerLocation,
          'line': callerFrame.line,
          'function': callerFrame.member,
        };
      }
    }

    sink.writeln(jsonEncode(map));
  }

  @override
  LogHandler withAttrs(List<LogAttr> attrs) {
    return LogJsonHandler(
      level: level,
      sink: sink,
      attrs: [...this.attrs, ...attrs],
      middlewares: middlewares,
      addSource: addSource,
    );
  }
}

extension on List<LogAttr> {
  void _addToMap(Map<String, Object> map) {
    for (final attr in this) {
      map[attr.key] = switch (attr) {
        LogStringAttr(:final value) => value,
        LogIntAttr(:final value) => value,
        LogDoubleAttr(:final value) => value,
        LogBoolAttr(:final value) => value,
        LogGroupAttr(:final values) => () {
          final nested = <String, Object>{};
          values._addToMap(nested);
          return nested;
        }(),
      };
    }
  }
}
