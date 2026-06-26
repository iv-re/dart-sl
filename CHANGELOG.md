## 0.0.4

- Added `addSource` option to `LogJsonHandler` and `LogTextHandler`
  to include caller location in logs.
- Added `LogMultiHandler` to route logs to multiple handlers.

## 0.0.3

- Introduced context-aware logging using `ctx`/`attrs` named parameters and `middlewares` support.

## 0.0.2

- Switched context logger key from `String` to `Object` to prevent name collisions.

## 0.0.1

- Initial version.
