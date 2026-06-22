/// Logging levels with comparison operators.
enum LogLevel implements Comparable<LogLevel> {
  debug('DEBUG'),
  info('INFO'),
  warn('WARN'),
  error('ERROR');

  const LogLevel(this.label);

  /// Display label for the log level.
  final String label;

  bool operator <(LogLevel other) => index < other.index;

  bool operator <=(LogLevel other) => index <= other.index;

  bool operator >(LogLevel other) => index > other.index;

  bool operator >=(LogLevel other) => index >= other.index;

  @override
  int compareTo(LogLevel other) => index.compareTo(other.index);

  @override
  String toString() => name;
}
