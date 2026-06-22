import 'package:sl/sl.dart';

/// Interface for plugins that bridge external logging libraries to [Logger].
abstract interface class LogBridge {
  /// Attaches the bridge to a [Logger] and returns a function to detach it.
  void Function() attach(Logger logger);
}
