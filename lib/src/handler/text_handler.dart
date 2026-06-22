import 'dart:io';

import 'package:sl/sl.dart';

/// Color theme configuration for [LogTextHandler] using ANSI escape codes.
final class LogTextTheme {
  /// Creates an ANSI color theme for formatting text logs.
  const LogTextTheme({
    this.key = '\x1b[36m',
    this.scope = '\x1b[90m',
    this.reset = '\x1b[0m',
    this.level = _defaultLevelColor,
  });

  /// ANSI code for attribute keys.
  final String key;

  /// ANSI code for the scope component bracket.
  final String scope;

  /// ANSI code to reset formatting.
  final String reset;

  /// Function returning the ANSI code for a given [LogLevel].
  final String Function(LogLevel) level;

  static String _defaultLevelColor(LogLevel level) {
    return switch (level) {
      .error => '\x1b[1;31m',
      .warn => '\x1b[1;33m',
      _ => '\x1b[1;32m',
    };
  }

  /// Default ANSI color theme.
  static const ansi = LogTextTheme();
}

/// Formats [LogRecord] entries as space-separated text
/// and writes them to [sink].
final class LogTextHandler implements LogHandler {
  /// Creates a text-formatting handler.
  LogTextHandler({
    this.level = .info,
    this.scopeKey = 'component',
    this.theme,
    IOSink? sink,
    this.attrs = const [],
  }) : sink = sink ?? stdout;

  /// Minimum level required for logs to be emitted.
  final LogLevel level;

  /// Attribute key whose value is formatted in brackets
  /// at the start of the message.
  final String? scopeKey;

  /// Optional ANSI color theme configuration.
  final LogTextTheme? theme;

  /// Output destination for logs.
  final IOSink sink;

  /// Persistent attributes appended to all records.
  final List<LogAttr> attrs;

  @override
  bool enabled(LogLevel level) => level >= this.level;

  @override
  void handle(LogRecord record) {
    final theme = this.theme;
    final buf = StringBuffer();

    if (theme != null) {
      buf
        ..write(theme.level(record.level))
        ..write(record.level.label.padRight(5))
        ..write(theme.reset)
        ..write(' ');
    } else {
      buf
        ..write(record.level.label.padRight(5))
        ..write(' ');
    }

    if (scopeKey != null) {
      LogAttr? scopeAttr;
      for (final attr in [...attrs, ...record.attrs]) {
        if (attr.key == scopeKey) {
          scopeAttr = attr;
          break;
        }
      }
      if (scopeAttr case LogStringAttr(:final value) when value.isNotEmpty) {
        if (theme != null) {
          buf
            ..write(theme.scope)
            ..write('[')
            ..write(value)
            ..write(']')
            ..write(theme.reset)
            ..write(' ');
        } else {
          buf
            ..write('[')
            ..write(value)
            ..write('] ');
        }
      }
    }

    buf.write(record.message);

    void appendAttr(LogAttr attr) {
      if (scopeKey != null && attr.key == scopeKey) return;
      buf.write(' ');
      if (theme != null) {
        buf
          ..write(theme.key)
          ..write(attr.key)
          ..write(theme.reset)
          ..write('=')
          ..write(_formatValue(attr));
      } else {
        buf
          ..write(attr.key)
          ..write('=')
          ..write(_formatValue(attr));
      }
    }

    attrs.forEach(appendAttr);
    record.attrs.forEach(appendAttr);

    sink.writeln(buf.toString());
  }

  @override
  LogHandler withAttrs(List<LogAttr> attrs) {
    return LogTextHandler(
      level: level,
      scopeKey: scopeKey,
      theme: theme,
      sink: sink,
      attrs: [...this.attrs, ...attrs],
    );
  }

  static String _formatValue(LogAttr attr) {
    return switch (attr) {
      LogStringAttr(:final value) => value,
      LogIntAttr(:final value) => value.toString(),
      LogDoubleAttr(:final value) => value.toString(),
      LogBoolAttr(:final value) => value.toString(),
      LogGroupAttr(:final values) => '{${values.map(_formatAttr).join(', ')}}',
    };
  }

  static String _formatAttr(LogAttr attr) {
    return '${attr.key}=${_formatValue(attr)}';
  }
}
