/// A structured key-value attribute associated with a log entry.
sealed class LogAttr {
  const LogAttr(this.key);

  /// Creates a string attribute.
  const factory LogAttr.string(String key, String value) = LogStringAttr;

  /// Creates an integer attribute.
  const factory LogAttr.int(String key, int value) = LogIntAttr;

  /// Creates a double attribute.
  const factory LogAttr.double(String key, double value) = LogDoubleAttr;

  /// Creates a boolean attribute.
  const factory LogAttr.bool(String key, bool value) = LogBoolAttr;

  /// Creates a group attribute nesting a list of other attributes.
  const factory LogAttr.group(String key, List<LogAttr> attrs) = LogGroupAttr;

  /// Creates a string attribute for an error with key 'error'.
  factory LogAttr.error(Object error) {
    return LogStringAttr('error', error.toString());
  }

  /// Creates a string attribute for a stack trace with key 'stack_trace'.
  factory LogAttr.stackTrace(StackTrace stackTrace) {
    return LogStringAttr('stack_trace', stackTrace.toString());
  }

  /// The attribute key name.
  final String key;
}

/// An attribute holding a [String] value.
final class LogStringAttr extends LogAttr {
  const LogStringAttr(super.key, this.value);

  final String value;
}

/// An attribute holding an [int] value.
final class LogIntAttr extends LogAttr {
  const LogIntAttr(super.key, this.value);

  final int value;
}

/// An attribute holding a [double] value.
final class LogDoubleAttr extends LogAttr {
  const LogDoubleAttr(super.key, this.value);

  final double value;
}

/// An attribute holding a [bool] value.
final class LogBoolAttr extends LogAttr {
  const LogBoolAttr(super.key, this.value);

  final bool value;
}

/// An attribute grouping multiple [LogAttr] values under a single key.
final class LogGroupAttr extends LogAttr {
  const LogGroupAttr(super.key, this.values);

  final List<LogAttr> values;
}
