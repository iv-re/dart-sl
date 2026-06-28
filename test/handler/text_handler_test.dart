import 'dart:io';

import 'package:ctx/ctx.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sl/sl.dart';
import 'package:test/test.dart';

class _MockSink extends Mock implements IOSink {}

void main() {
  group('LogTextHandler', () {
    test('enabled filters by level', () {
      final handler = LogTextHandler(level: .warn);

      expect(handler.enabled(const .empty(), .warn), isTrue);
      expect(handler.enabled(const .empty(), .error), isTrue);
      expect(handler.enabled(const .empty(), .info), isFalse);
    });

    test('handle writes level label and message', () {
      final sink = _MockSink();
      final handler = LogTextHandler(sink: sink, scopeKey: null);

      handler.handle(
        const .empty(),
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
      final handler = LogTextHandler(sink: sink);

      handler.handle(
        const .empty(),
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
      final handler = LogTextHandler(sink: sink);

      handler.handle(
        const .empty(),
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
      final handler = LogTextHandler(sink: sink, scopeKey: 'cmp');

      handler.handle(
        const .empty(),
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
      final handler = LogTextHandler(sink: sink, scopeKey: null);

      handler.handle(
        const .empty(),
        LogRecord(
          level: .debug,
          message: 'query',
          time: .utc(2000, 11, 15),
          attrs: const [
            .group(
              'db',
              [
                .string('sql', 'SELECT 1'),
                .int('dur', 42),
              ],
            ),
          ],
        ),
      );

      verify(
        () => sink.writeln('DEBUG query db.sql=SELECT 1 db.dur=42'),
      ).called(1);
    });

    test('handle formats using LogTextTheme', () {
      final sink = _MockSink();
      final handler = LogTextHandler(
        sink: sink,
        theme: const LogTextTheme(
          key: '<key>',
          scope: '<scope>',
          reset: '<reset>',
          level: _customLevelColor,
        ),
      );

      handler.handle(
        const .empty(),
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

      final handler = LogTextHandler(
        sink: sink,
        attrs: const [.string('a', '1')],
      ).withAttrs(const [.string('b', '2')]);

      handler.handle(
        const .empty(),
        LogRecord(
          level: .info,
          message: 'm',
          time: .utc(2000, 11, 15),
          attrs: const [.string('c', '3')],
        ),
      );

      verify(() => sink.writeln('INFO  m a=1 b=2 c=3')).called(1);
    });

    test('middleware modifies record based on context', () {
      final sink = _MockSink();

      final handler = LogTextHandler(
        sink: sink,
        middlewares: [
          (ctx, record) {
            if (ctx.value('trace_id') case final String traceId) {
              return record.copyWith(
                attrs: [...record.attrs, .string('trace_id', traceId)],
              );
            }
            return record;
          },
          (ctx, record) {
            return record.copyWith(message: '${record.message}_suffix');
          },
        ],
      );

      final context = const Context.empty().withValue('trace_id', 'abc-123');

      handler.handle(
        context,
        LogRecord(
          level: .info,
          message: 'm',
          time: .utc(2000, 11, 15),
          attrs: const [],
        ),
      );

      verify(() => sink.writeln('INFO  m_suffix trace_id=abc-123')).called(1);
    });

    test('addSource includes source field in output', () {
      final sink = _MockSink();
      final handler = LogTextHandler(
        sink: sink,
        addSource: true,
      );

      handler.handle(
        const .empty(),
        LogRecord(
          level: .info,
          message: 'hello',
          time: .utc(2000, 11, 15),
          attrs: const [],
        ),
      );

      final captured =
          verify(() => sink.writeln(captureAny())).captured.first as String;

      expect(captured, contains('source='));
      expect(captured, contains('text_handler_test.dart'));
    });

    test('withGroup formats group flat with dots', () {
      final sink = _MockSink();
      final handler = LogTextHandler(sink: sink, scopeKey: null)
          .withGroup('g1')
          .withAttrs(const [.string('a', '1')])
          .withGroup('g2')
          .withAttrs(const [.string('b', '2')]);

      handler.handle(
        const .empty(),
        LogRecord(
          level: .info,
          message: 'msg',
          time: .utc(2000, 11, 15),
          attrs: const [.string('c', '3')],
        ),
      );

      verify(
        () => sink.writeln('INFO  msg g1.a=1 g1.g2.b=2 g1.g2.c=3'),
      ).called(1);
    });

    test('withGroup ignores empty groups', () {
      final sink = _MockSink();
      final handler = LogTextHandler(
        sink: sink,
        scopeKey: null,
      ).withGroup('g1');

      handler.handle(
        const .empty(),
        LogRecord(
          level: .info,
          message: 'msg',
          time: .utc(2000, 11, 15),
          attrs: const [],
        ),
      );

      verify(() => sink.writeln('INFO  msg')).called(1);
    });
  });
}

String _customLevelColor(LogLevel level) => '<lvl_${level.name}>';
