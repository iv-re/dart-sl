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
logger.info('user profile updated', attrs: [
  .string('username', 'alice'),
  .int('age', 30),
  .double('height', 1.75),
  .bool('verified', true),
]);
```

### Attribute Groups

```dart
logger.info('request metadata', attrs: [
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
  logger.error('database operation failed', attrs: [
    .error(e),
    .stackTrace(stack),
  ]);
}
```

## Contextual Loggers

Create child loggers that inherit and merge parent attributes:

```dart
final dbLogger = logger.withAttrs([
  .string('component', 'database'),
]);

dbLogger.info('executing query'); 
// Output: INFO  [database] executing query
```

## Bridging Standard Logging

To capture and proxy logs from Dart's standard `logging` package:

```dart
import 'package:logging/logging.dart' as logging;
import 'package:sl/sl.dart';

// Captures root logger logs and forwards them to our logger
final detach = StdLoggerBridge().attach(logger);

// Stop bridging later:
detach();
```

## Middlewares

Handlers accept an optional list of `middlewares` to transform log records before they are formatted and written. This is useful for extracting values from a context (using `package:ctx`) and appending them as attributes:

```dart
final logger = Logger(
  handler: LogTextHandler(
    middlewares: [
      (context, record) {
        if (context.value('trace_id') case final String traceId) {
          return record.copyWith(
            attrs: [...record.attrs, .string('trace_id', traceId)],
          );
        }
        return record;
      },
    ],
  ),
);
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
