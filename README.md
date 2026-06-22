# sl

A structured logging library.

## Setup

```dart
import 'package:sl/sl.dart';

final logger = Logger(
  handler: LogTextHandler(level: .debug),
);
```

## Basic Logging

```dart
logger.debug('connecting to database...');
logger.info('application started');
logger.warn('memory usage is high');
logger.error('failed to process request');
```

## Structured Attributes

```dart
logger.info('user profile updated', const [
  .string('username', 'alice'),
  .int('age', 30),
  .double('height', 1.75),
  .bool('verified', true),
]);
```

### Attribute Groups

```dart
logger.info('request metadata', const [
  .group('http', [
    .string('method', 'POST'),
    .int('status', 201),
  ]),
]);
```

### Errors and Stack Traces

```dart
try {
  throw StateError('connection timed out');
} catch (e, stack) {
  logger.error('database operation failed', [
    .error(e),
    .stackTrace(stack),
  ]);
}
```

## Contextual Loggers

Create child loggers that inherit and merge parent attributes:

```dart
final dbLogger = logger.withAttrs(const [
  .string('component', 'database'),
]);

dbLogger.info('executing query'); 
// Output: INFO  [database] executing query
```

## Context Integration

If you use the `ctx` package, you can pass and retrieve the logger from the `Context`:

```dart
import 'package:ctx/ctx.dart';
import 'package:sl/sl.dart';

final context = const Context.empty().withLogger(logger);
context.logger.info('hello from context');
```

## Bridging Standard Logging

To capture and proxy logs from Dart's standard `logging` package:

```dart
import 'package:logging/logging.dart' as logging;
import 'package:sl/sl.dart';

// Captures root logger logs and forwards them to our logger
final detach = const StdLoggerBridge().attach(logger);

// Stop bridging later:
detach();
```

## Handlers

### Text Output (`LogTextHandler`)

```dart
final logger = Logger(
  handler: LogTextHandler(
    level: .debug,
    scopeKey: 'component', // optional, formats value in brackets [value]
    theme: .ansi, // optional, enables ANSI colors
  ),
);
```

Output:
```text
INFO  [database] query completed duration_ms=45
```

### JSON Output (`LogJsonHandler`)

```dart
final logger = Logger(
  handler: LogJsonHandler(level: .info),
);
```

Output:
```json
{"time":"2026-06-17T18:45:00.000Z","level":"INFO","msg":"query completed","duration_ms":45}
```
