import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockHandler extends Mock implements LogHandler {}

Matcher recordWith({
  LogLevel? level,
  String? message,
  int? attrsLength,
}) {
  var matcher = isA<LogRecord>();

  if (level != null) {
    matcher = matcher.having((r) => r.level, 'level', level);
  }
  if (message != null) {
    matcher = matcher.having((r) => r.message, 'message', message);
  }
  if (attrsLength != null) {
    matcher = matcher.having(
      (r) => r.attrs.length,
      'attrs length',
      attrsLength,
    );
  }
  return matcher;
}

void main() {
  late _MockHandler handler;
  late Logger logger;

  setUpAll(() {
    registerFallbackValue(
      LogRecord(
        level: .debug,
        message: '',
        time: .utc(2000, 11, 15),
        attrs: [],
      ),
    );
    registerFallbackValue(LogLevel.debug);
    registerFallbackValue(const LogAttr.string('', ''));
  });

  setUp(() {
    handler = _MockHandler();
    when(() => handler.enabled(any())).thenReturn(true);

    logger = Logger(handler: handler);
  });

  group('log methods', () {
    test('debug calls handle with debug level', () {
      logger.debug('msg');

      verify(
        () => handler.handle(
          any(
            that: recordWith(level: .debug, message: 'msg'),
          ),
        ),
      ).called(1);
    });

    test('info calls handle with info level', () {
      logger.info('msg');

      verify(
        () => handler.handle(
          any(that: recordWith(message: 'msg')),
        ),
      ).called(1);
    });

    test('warn calls handle with warn level', () {
      logger.warn('msg');

      verify(
        () => handler.handle(
          any(
            that: recordWith(level: .warn, message: 'msg'),
          ),
        ),
      ).called(1);
    });

    test('error calls handle with error level', () {
      logger.error('msg');

      verify(
        () => handler.handle(
          any(
            that: recordWith(level: .error, message: 'msg'),
          ),
        ),
      ).called(1);
    });

    test('skips handle when disabled', () {
      when(() => handler.enabled(.debug)).thenReturn(false);

      logger.debug('skip');

      verifyNever(() => handler.handle(any()));
    });

    test('withAttrs forwards to handler.withAttrs', () {
      when(() => handler.withAttrs(any())).thenReturn(handler);

      final scoped = logger.withAttrs(const [.string('tag', 'db')]);

      verify(() => handler.withAttrs(const [.string('tag', 'db')])).called(1);
      expect(scoped, isA<Logger>());
    });

    test('log passes attrs to handle', () {
      logger.log(.info, 'msg', const [.int('n', 1)]);

      verify(
        () => handler.handle(
          any(that: recordWith(attrsLength: 1)),
        ),
      ).called(1);
    });
  });
}
