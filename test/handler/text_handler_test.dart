import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockSink extends Mock implements IOSink {}

void main() {
  group('LogTextHandler', () {
    test('enabled filters by level', () {
      final h = LogTextHandler(level: .warn);

      expect(h.enabled(.warn), isTrue);
      expect(h.enabled(.error), isTrue);
      expect(h.enabled(.info), isFalse);
    });

    test('handle writes level label and message', () {
      final sink = _MockSink();
      final h = LogTextHandler(sink: sink, scopeKey: null);

      h.handle(
        LogRecord(
          level: .info,
          message: 'hello',
          time: .utc(2000, 11, 15),
          attrs: [],
        ),
      );

      verify(() => sink.writeln('INFO  hello')).called(1);
    });

    test('handle shows [scope] when scopeKey attr exists', () {
      final sink = _MockSink();
      final h = LogTextHandler(sink: sink);

      h.handle(
        LogRecord(
          level: .error,
          message: 'fail',
          time: .utc(2000, 11, 15),
          attrs: const [.string('component', 'api')],
        ),
      );

      verify(() => sink.writeln('ERROR [api] fail')).called(1);
    });

    test('handle omits [scope] when scopeKey attr is missing', () {
      final sink = _MockSink();
      final h = LogTextHandler(sink: sink);

      h.handle(
        LogRecord(
          level: .warn,
          message: 'warn',
          time: .utc(2000, 11, 15),
          attrs: [],
        ),
      );

      verify(() => sink.writeln('WARN  warn')).called(1);
    });

    test('handle formats attr types and excludes scopeKey from append', () {
      final sink = _MockSink();
      final h = LogTextHandler(sink: sink, scopeKey: 'cmp');

      h.handle(
        LogRecord(
          level: .info,
          message: 'ok',
          time: .utc(2000, 11, 15),
          attrs: const [
            .string('cmp', 'db'),
            .int('rows', 5),
            .double('ms', 1.2),
            .bool('cached', true),
          ],
        ),
      );

      verify(
        () => sink.writeln('INFO  [db] ok rows=5 ms=1.2 cached=true'),
      ).called(1);
    });

    test('handle formats group attr', () {
      final sink = _MockSink();
      final h = LogTextHandler(sink: sink, scopeKey: null);

      h.handle(
        LogRecord(
          level: .debug,
          message: 'query',
          time: .utc(2000, 11, 15),
          attrs: const [
            .group('db', [
              .string('sql', 'SELECT 1'),
              .int('dur', 42),
            ]),
          ],
        ),
      );

      verify(
        () => sink.writeln('DEBUG query db={sql=SELECT 1, dur=42}'),
      ).called(1);
    });

    test('handle formats using LogTextTheme', () {
      final sink = _MockSink();
      final h = LogTextHandler(
        sink: sink,
        theme: const LogTextTheme(
          key: '<key>',
          scope: '<scope>',
          reset: '<reset>',
          level: _customLevelColor,
        ),
      );

      h.handle(
        LogRecord(
          level: .warn,
          message: 'msg',
          time: .utc(2000, 11, 15),
          attrs: const [
            .string('component', 'api'),
            .int('code', 200),
          ],
        ),
      );

      verify(
        () => sink.writeln(
          '<lvl_warn>WARN <reset> <scope>[api]<reset> msg <key>code<reset>=200',
        ),
      ).called(1);
    });

    test('default LogTextTheme levels return correct ANSI codes', () {
      const theme = LogTextTheme.ansi;
      expect(theme.level(.error), '\x1b[1;31m');
      expect(theme.level(.warn), '\x1b[1;33m');
      expect(theme.level(.info), '\x1b[1;32m');
      expect(theme.level(.debug), '\x1b[1;32m');
    });

    test('withAttrs combines attrs in output', () {
      final sink = _MockSink();

      final h = LogTextHandler(
        sink: sink,
        attrs: const [.string('a', '1')],
      ).withAttrs(const [.string('b', '2')]);

      h.handle(
        LogRecord(
          level: .info,
          message: 'm',
          time: .utc(2000, 11, 15),
          attrs: const [.string('c', '3')],
        ),
      );

      verify(() => sink.writeln('INFO  m a=1 b=2 c=3')).called(1);
    });
  });
}

String _customLevelColor(LogLevel level) => '<lvl_${level.name}>';
