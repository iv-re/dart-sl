import 'dart:async';
import 'package:logging/logging.dart' as logging;
import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockHandler extends Mock implements LogHandler {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      LogRecord(
        level: .debug,
        message: '',
        time: DateTime.now(),
        attrs: [],
      ),
    );
    registerFallbackValue(LogLevel.debug);
  });

  group('StdLoggerBridge', () {
    late _MockHandler handler;
    late Logger target;

    setUp(() {
      logging.hierarchicalLoggingEnabled = true;
      logging.Logger.root.level = logging.Level.ALL;
      handler = _MockHandler();
      when(() => handler.enabled(any())).thenReturn(true);
      target = Logger(handler: handler);
    });

    Future<void> pump() => Future.delayed(Duration.zero);

    test('bridges level severities correctly', () async {
      final detach = const StdLoggerBridge().attach(target);

      final levels = {
        logging.Level.FINEST: LogLevel.debug,
        logging.Level.FINER: LogLevel.debug,
        logging.Level.FINE: LogLevel.debug,
        logging.Level.CONFIG: LogLevel.debug,
        logging.Level.INFO: LogLevel.info,
        logging.Level.WARNING: LogLevel.warn,
        logging.Level.SEVERE: LogLevel.error,
        logging.Level.SHOUT: LogLevel.error,
      };

      for (final entry in levels.entries) {
        logging.Logger.root.log(entry.key, 'msg');
        await pump();

        verify(
          () => handler.handle(
            any(
              that: isA<LogRecord>()
                  .having((r) => r.level, 'level', entry.value)
                  .having((r) => r.message, 'message', 'msg'),
            ),
          ),
        ).called(1);
      }

      detach();
    });

    test('attaches logger name as component by default', () async {
      final detach = const StdLoggerBridge().attach(target);

      final standardLogger = logging.Logger('auth_service');
      standardLogger.info('user logged in');
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.attrs,
              'attrs',
              contains(isA<LogStringAttr>()
                  .having((a) => a.key, 'key', 'component')
                  .having((a) => a.value, 'value', 'auth_service')),
            ),
          ),
        ),
      ).called(1);

      detach();
    });

    test('attaches logger name to custom key if configured', () async {
      final detach =
          const StdLoggerBridge(nameKey: 'log_name').attach(target);

      final standardLogger = logging.Logger('database');
      standardLogger.info('query executed');
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.attrs,
              'attrs',
              contains(isA<LogStringAttr>()
                  .having((a) => a.key, 'key', 'log_name')
                  .having((a) => a.value, 'value', 'database')),
            ),
          ),
        ),
      ).called(1);

      detach();
    });

    test('ignores logger name if nameKey is null', () async {
      final detach = const StdLoggerBridge(nameKey: null).attach(target);

      final standardLogger = logging.Logger('network');
      standardLogger.info('packet sent');
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having((r) => r.attrs, 'attrs', isEmpty),
          ),
        ),
      ).called(1);

      detach();
    });

    test('bridges error and stackTrace if present', () async {
      final detach = const StdLoggerBridge().attach(target);

      final error = StateError('timeout');
      final stackTrace = StackTrace.current;

      logging.Logger.root.severe('request failed', error, stackTrace);
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.attrs,
              'attrs',
              allOf(
                contains(isA<LogStringAttr>()
                    .having((a) => a.key, 'key', 'error')
                    .having((a) => a.value, 'value', contains('timeout'))),
                contains(isA<LogStringAttr>()
                    .having((a) => a.key, 'key', 'stack_trace')
                    .having((a) => a.value, 'value', isNotEmpty)),
              ),
            ),
          ),
        ),
      ).called(1);

      detach();
    });

    test('listens only to custom source logger if provided', () async {
      final customSource = logging.Logger('custom_source');
      final detach =
          StdLoggerBridge(source: customSource).attach(target);

      logging.Logger.root.info('root message');
      await pump();

      customSource.info('custom message');
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.message,
              'message',
              'custom message',
            ),
          ),
        ),
      ).called(1);

      verifyNever(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.message,
              'message',
              'root message',
            ),
          ),
        ),
      );

      detach();
    });

    test('detaching cancels subscription and stops bridging', () async {
      final detach = const StdLoggerBridge().attach(target);

      logging.Logger.root.info('message 1');
      await pump();

      detach();

      logging.Logger.root.info('message 2');
      await pump();

      verify(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.message,
              'message',
              'message 1',
            ),
          ),
        ),
      ).called(1);

      verifyNever(
        () => handler.handle(
          any(
            that: isA<LogRecord>().having(
              (r) => r.message,
              'message',
              'message 2',
            ),
          ),
        ),
      );
    });
  });
}
