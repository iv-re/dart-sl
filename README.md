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

### Logger Groups

```dart
final groupedLogger = logger.withGroup('request').withAttrs([
  .string('id', '123'),
]);

groupedLogger.info('processing', attrs: [
  .string('path', '/users'),
]);
```

- **`LogJsonHandler`** output:
  ```json
  {
    "time": "2026-06-28T12:00:00.000Z",
    "level": "INFO",
    "msg": "processing",
    "request": {
      "id": "123",
      "path": "/users"
    }
  }
  ```

- **`LogTextHandler`** output:
  ```text
  INFO  processing request.id=123 request.path=/users
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

## Source Locations

To automatically capture and include the calling source code location:

```dart
final logger = Logger(
  handler: LogTextHandler(addSource: true),
);
```

`LogTextHandler` output:
```text
INFO  application started source=package:my_app/main.dart:42
```

`LogJsonHandler` output:
```json
{
  "time": "2026-06-27T02:00:00.000Z",
  "level": "INFO",
  "msg": "started",
  "source": {
    "file": "package:my_app/main.dart",
    "line": 42,
    "function": "main"
  }
}
```

> **Warning**
> Capturing stack traces is relatively expensive. It is not recommended
> for production environments where logging performance is critical.

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

### Multi Handler (`LogMultiHandler`)

Duplicates and routes log records to multiple downstream handlers:

```dart
final logger = Logger(
  handler: LogMultiHandler([
    LogJsonHandler(level: .info),
    externalHandler, // e.g. sending logs to a file or a remote service
  ]),
);
```
