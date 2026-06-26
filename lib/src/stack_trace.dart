import 'package:stack_trace/stack_trace.dart';

/// Finds the first calling frame outside of package:sl and package:stack_trace.
Frame? findCallerFrame() {
  final stackTraceTrace = Trace.current();
  for (final stackFrame in stackTraceTrace.frames) {
    final frameUriString = stackFrame.uri.toString();
    if (frameUriString.startsWith('package:sl/') ||
        frameUriString.startsWith('package:stack_trace/')) {
      continue;
    }
    return stackFrame;
  }
  return null;
}

extension FrameLocation on Frame {
  String get callerLocation {
    final frameUri = uri;
    if (frameUri.scheme == 'file') {
      return frameUri.toFilePath();
    }
    return library;
  }
}
